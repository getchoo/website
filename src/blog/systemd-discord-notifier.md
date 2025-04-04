---
title: "Discord notifications on service failures with systemd and NixOS"
description: "Using modules and template units to replace Grafana"
publishedDate: 2025-04-06
draft: false 
image:
    name: service-monitoring-at-home.webp
    alt: |
        The text "Mom, can we have service monitoring at home?" next to the Grafana, Prometheus, and Loki logos
        "No. There is service monitoring at home"
        "Service alerting at home: `systemd-creds cat webhook-url | xargs curl -X POST -F "content=$CONTENT"`"
---

For a while I have been using the [Victoria Stack](https://victoriametrics.com/) and [Grafana's alerting feature](https://grafana.com/docs/grafana/latest/alerting/) to notify of me of service failures on my servers. While having an alerting *and* monitoring solution was fun, I quickly realized I wasn't really using the monitoring part all that often; alerting was the main feature I was looking for.

I started exploring some other options, like running Promtheus' [AlertManager](https://prometheus.io/docs/alerting/latest/alertmanager/) by itself, but generally I found that they ended up using a lot of resources and took a lot of setup for something I wasn't asking that much from.

So, I tried to see how I could leverage a bit of Systemd magic and NixOS to handle it myself. Here's how I did it:

## Systemd's `OnFailure`

[`systemd.unit(5)`](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html) tells us that `OnFailure` is a unit option consisting of

> A space-separated list of one or more units that are activated when this unit enters the 'failed' state.

In practice, this allows you to define specific follow ups to unit (service) failures -- like a notification hook!

The only problem with this option is that it needs to be defined for _each_ service. On most servers, this will likely be in the dozens, if not hundreds. Let's save that problem for later though, and try to define a follow up unit.

## Systemd template units

Reading from [`systemd.unit(5)`](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html) again can tell us that

> Unit names can be parameterized by a single argument called the 'instance name'. The unit is then constructed based on a 'template file' which serves as the definition of multiple services or other units. A template unit must have a single '@' at the end of the unit name prefix (right before the type suffix). The name of the full unit is formed by inserting the instance name between '@' and the unit type suffix. In the unit file itself, the instance parameter may be referred to using '%i'

This is a bit of a super power for systemd. It allows administrators to create reusable, parameterized unit files to call on the fly, or declare in other units. Considering our goal is to send a similar webhook for any given service, this is a great option. All we need to do is pass the service name between the "@" and unit type suffix!

Let's create a basic service file called `discord-notify-failure@.service`

```ini
[Unit]
Description=Notify of service failures on Discord
After=network.target

[Service]
Type=oneshot
```

This service is a "oneshot" unit, meaning that it will run a command and immediately exit once it's complete. After taking a look at [Discord's developer documentation](https://discord.com/developers/docs/resources/webhook#execute-webhook), we can find that all we need is to pass to the webhook is a `content` parameter. Let's add an `ExecStart` line that does it:

```diff
 [Service]
 Type=oneshot
+ExecStart=curl -X POST -F "content='Alert!'" https://discord.com/api/webhooks/webhook_id/webhook_token
```

Triggering `discord-notify-failure@test.service` should now result in a webhook payload being sent. Nice!

Having a totally static payload isn't great, though. We want to include what service failed in the message after all.
So, let's make it a bit configurable with an environment variable, and set some nice default text.

```diff
 [Service]
 Type=oneshot
-ExecStart=curl -X POST -F "content='Alert!'" https://discord.com/api/webhooks/webhook_id/webhook_token
+Environment="CONTENT=# 🚨 %i.service failed! 🚨"
+ExecStart=curl -X POST -F "content=$CONTENT" https://discord.com/api/webhooks/webhook_id/webhook_token
```

The webhook URL we're using is also considered to be senstitive. [`systemd-creds`](https://systemd.io/CREDENTIALS/) can help us load it securely from a non-publicly accessible (or even completely encrypted) file instead of this world-readable one:

```diff
 [Service]
 Type=oneshot
+LoadCredential=webhook-url:/etc/discord-webhook-url.txt
 Environment="CONTENT=# 🚨 %i.service failed! 🚨"
-ExecStart=curl -X POST -F "content=$CONTENT" https://discord.com/api/webhooks/webhook_id/webhook_token
+ExecStart=/bin/sh -c 'systemd-creds cat webhook-url | xargs curl -X POST -F "content=$CONTENT"'
```

Now we have a pretty good looking service file

```ini
[Unit]
Description=Notify of service failures on Discord
After=network.target

[Service]
Type=oneshot
LoadCredential=webhook-url:/etc/discord-webhook-url.txt
Environment="CONTENT=# 🚨 %i.service failed! 🚨"
ExecStart=/bin/sh -c 'systemd-creds cat webhook-url | xargs curl -X POST -F "content=$CONTENT"'
```

So how can we apply it globally?

## Systemd drop-ins

According to [`systemd.unit(5)`](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html):

> Along with a unit file foo.service, a 'drop-in' directory foo.service.d/ may exist. All files with the suffix '.conf' from this directory will be merged in the alphanumeric order and parsed after the main unit file itself has been parsed. This is useful to alter or add configuration settings for a unit, without having to modify unit files. [...] Units also support a top-level drop-in with type.d/, where type may be e.g. 'service' or 'socket', that allows altering or adding to the settings of all corresponding unit files on the system.

Based on this, to override all services with a default `OnFailure` option, we can create a file at `/etc/systemd/system/service.d/discord-notify-failure.conf` with the following contents:

```ini
[Unit]
OnFailure=discord-notify-failure@%N.service
```

And if a service wishes to opt-out, an empty file can be created at `/etc/systemd/service/<service>.d/discord-notify-failure.conf`. Cool!

## Nix-ification

With an implementation in mind, let's figure out how to actually deploy this on our machines. In this case, it's NixOS ;)

The first step in putting this on a NixOS system is declaring the service in the configuration. Thankfully, the `systemd.services` module is mostly 1:1 with service files themselves -- give or take different casing and some niceities. Here's how our example ends up:

```nix
{ pkgs, ... }:

{
  config = {
    systemd.services."discord-notify-failure@" = {
      description = "Notify of service failures on Discord.";

      after = [ "network.target" ];

      path = [ pkgs.curl ];

      script = ''
        systemd-creds cat webhook-url | xargs curl -X POST -F "content=$CONTENT"
      '';

      environment = {
        CONTENT = "# 🚨 %i.service failed! 🚨";
      };

      serviceConfig = {
        Type = "oneshot";
        LoadCredential = "webhook-url:/etc/discord-webhook-url.txt";
      };
    };
  };
}
```

Let's make some of these variables customizable too. We can start by creating an option for the content sent to the webhook

```nix
{
  options.services.systemd-discord-notifier = {
    content = lib.mkOption {
      type = lib.types.str;
      default = "# 🚨 %i.service failed! 🚨";
      example = "%i.service failed :(";
    };
  };
}
```

And we can add it to our current implementation like so

```diff
-{ pkgs, ... }:
+{
+  config,
+  lib,
+  pkgs,
+  ...
+}:
+
+let
+  cfg = config.services.systemd-discord-notifier;
+in

 {
+  options.services.systemd-discord-notifier = {
+    content = lib.mkOption {
+      type = lib.types.str;
+      default = "# 🚨 %i.service failed! 🚨";
+      example = "%i.service failed :(";
+    };
+  };
+
   config = {
     systemd.services."discord-notify-failure@" = {
       description = "Notify of service failures on Discord.";

       after = [ "network.target" ];

       path = [ pkgs.curl ];

       script = ''
         systemd-creds cat webhook-url | xargs curl -X POST -F "content=$CONTENT"
       '';

       environment = {
-        CONTENT = "# 🚨 %i.service failed! 🚨";
+        CONTENT = cfg.content;
       };

       serviceConfig = {
         Type = "oneshot";
         LoadCredential = "webhook-url:/etc/discord-webhook-url.txt";
       };
     };
   };
 }
```

We should have an option for that credential file too, so the user can pass their own file:

```diff
 {
   config,
   lib,
   pkgs,
   ...
 }:

 let
   cfg = config.services.systemd-discord-notifier;
 in

 {
   options.services.systemd-discord-notifier = {
     content = lib.mkOption {
       type = lib.types.str;
       default = "# 🚨 %i.service failed! 🚨";
       example = "%i.service failed :(";
     };
+
+    webhookURLFile = lib.mkOption {
+      type = lib.types.path;
+      default = "/etc/discord-webhook-url.txt";
+      description = "URL of the webhook.";
+    };
   };

   config = {
     systemd.services."discord-notify-failure@" = {
       description = "Notify of service failures on Discord.";

       after = [ "network.target" ];

       path = [ pkgs.curl ];

       script = ''
         systemd-creds cat webhook-url | xargs curl -X POST -F "content=$CONTENT"
       '';

       environment = {
         CONTENT = cfg.content;
       };

       serviceConfig = {
         Type = "oneshot";
-        LoadCredential = "webhook-url:/etc/discord-webhook-url.txt";
+        LoadCredential = "webhook-url:${cfg.webhookURLFile}";
       };
     };
   };
 }
```

Finally, let's make an `enable` option to toggle all of this

```diff
 {
   config,
   lib,
   pkgs,
   ...
 }:

 let
   cfg = config.services.systemd-discord-notifier;
 in

 {
   options.services.systemd-discord-notifier = {
+    enable = lib.mkEnableOption "discord-notify-failure";
+
     content = lib.mkOption {
       type = lib.types.str;
       default = "# 🚨 %i.service failed! 🚨";
       example = "%i.service failed :(";
     };

     webhookURLFile = lib.mkOption {
       type = lib.types.path;
       default = "/etc/discord-webhook-url.txt";
       description = "URL of the webhook.";
     };
   };

-  config = {
+  config = lib.mkIf cfg.enable {
     systemd.services."discord-notify-failure@" = {
       description = "Notify of service failures on Discord.";

       after = [ "network.target" ];

       path = [ pkgs.curl ];

       script = ''
         systemd-creds cat webhook-url | xargs curl -X POST -F "content=$CONTENT"
       '';

       environment = {
         CONTENT = cfg.content;
       };

       serviceConfig = {
         Type = "oneshot";
         LoadCredential = "webhook-url:${cfg.webhookURLFile}";
       };
     };
   };
 }
```

Now with our main module ready, we can move on to the next step: apply the module to all services.

The `systemd` module in NixOS doesn't have an exact way to only specify overrides, so I found the best way to do this was creating a small "package" with `pkgs.linkFarm`. It's a [sorta documented](https://github.com/NixOS/nixpkgs/blob/29e427b5c7b202234a5269a44b8f80b9cd155d05/pkgs/build-support/trivial-builders/default.nix#L637-L664) "trivial builder" in Nixpkgs that takes in a name-value pair of relative (to the package directory) paths and the files they should link to.

```nix
{ pkgs, ... }:

let
  # We can write the unit with only Nix, btw ;)
  unitFormat = pkgs.formats.systemd;
  # This is just the directory Nix expects systemd files to be
  systemVendorDir = "lib/systemd/system";

  systemdPackage = pkgs.linkFarm "systemd-discord-notifier-unit-overrides" {
    "${systemVendorDir}/service.d/discord-notify-failure.conf" =
      unitFormat.generate "systemd-discord-notifier.conf"
        {
          Unit = {
            OnFailure = [ "discord-notify-failure@%N.service" ];
          };
        };
  };
in

{ }
```

As said before, we also need to ensure `discord-notify-failure@.service` itself doesn't run by creating an empty file in it's drop-in directory. `pkgs.emptyFile` does that job well

```diff
 { pkgs, ... }:

 let
   # We can write the unit with only Nix, btw ;)
   unitFormat = pkgs.formats.systemd;
   # This is just the directory Nix expects systemd files to be
   systemVendorDir = "lib/systemd/system";

   systemdPackage = pkgs.linkFarm "systemd-discord-notifier-unit-overrides" {
     "${systemVendorDir}/service.d/discord-notify-failure.conf" =
       unitFormat.generate "systemd-discord-notifier.conf"
         {
           Unit = {
             OnFailure = [ "discord-notify-failure@%N.service" ];
           };
         };
+
+    "${systemVendorDir}/discord-notify-failure@.service.d/discord-notify-failure.conf" = pkgs.emptyFile;
   };
 in
```

We can now apply this to the rest of our implementation like so:

```diff
 let
   cfg = config.services.systemd-discord-notifier;
+
+  # We can write the unit with only Nix, btw ;)
+  unitFormat = pkgs.formats.systemd;
+  # This is just the directory Nix expects systemd files to be
+  systemVendorDir = "lib/systemd/system";
+
+  systemdPackage = pkgs.linkFarm "systemd-discord-notifier-unit-overrides" {
+    "${systemVendorDir}/service.d/discord-notify-failure.conf" =
+      unitFormat.generate "systemd-discord-notifier.conf"
+        {
+          Unit = {
+            OnFailure = [ "discord-notify-failure@%N.service" ];
+          };
+        };
+
+    "${systemVendorDir}/discord-notify-failure@.service.d/discord-notify-failure.conf" = pkgs.emptyFile;
+  };
 in

 {
   options.services.systemd-discord-notifier = {
     enable = lib.mkEnableOption "discord-notify-failure";

     content = lib.mkOption {
       type = lib.types.str;
       default = "# 🚨 %i.service failed! 🚨";
       example = "%i.service failed :(";
     };

     webhookURLFile = lib.mkOption {
       type = lib.types.path;
       default = "/etc/discord-webhook-url.txt";
       description = "URL of the webhook.";
     };
   };

   config = lib.mkIf cfg.enable {
+    systemd.packages = [ systemdPackage ];
+
     systemd.services."discord-notify-failure@" = {
       description = "Notify of service failures on Discord.";

       after = [ "network.target" ];
```

## ---> 🚨 Complete me! 🚨 <---

Then to enable enable it all in a system configuration:

```nix
{
  imports = [ ./systemd-discord-notifier.nix ];

  services.systemd-discord-notifier = {
    enable = true;

    webhookURLFile = /etc/discord-webhook-url.txt;
  };
}
```

After running `nixos-rebuild switch`, you can make sure it works with `systemctl start discord-notify-failure@test.service`.
