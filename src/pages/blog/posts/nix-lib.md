---
layout: "../../../layouts/Blogpost.astro"
title: making an intuitive, modular nix flake configuration
description: an explanation of my journey through making a modular nix flake configuration
---

# making an intuitive, modular nix flake configuration

<div id="blogText">

as some of my friends may know, recently i've gone off the nixos "deep end" so to speak, moving almost all of my systems and projects to it. i have a lot of reasons for this, but i think all of them might be better told in a different post. for this one, i'm going to go over my approach to making nix flake configurations that scale across multiple systems and users

</div>

## first things first

<div id="blogText">

i started out with [nixos on wsl](https://github.com/nix-community/NixOS-WSL) (heresy i know), mainly because i was on my windows partition when i first thought about it, but also because i wasn't really sure if i liked it yet. similar to a lot of nix beginners, i quickly got a bit overwhelmed by options.

<br />

i kept hearing about custom modules, overlays, and this thing called a "flake." after a quick search, i came across [this](https://nixos.wiki/wiki/Flakes) page. "oh cool, a way to manage dependencies!" i thought, but seeing as nixos-wsl was already installed on my system and me not thinking i was ever going to use a lot of libraries, utils, etc. i didn't pay much attention -- that is, until i wanted to try out native systemd support in nixos-wsl.

</div>

## dipping my toe in

<div id="blogText">

at the time, in order to use native systemd support i needed to follow the `main` branch of nixos-wsl. since i had been interested in flakes, with some friends using them and the name itself being cool, i decided this might be a good time to learn how to use them!

<br />

...it didn't turn out the way i wanted.

<br />

at first, i couldn't even understand the syntax of the inputs or what they were for, and sadly i couldn't find much on the wiki page to help me there. i tried different formats, but eventually i got `git+https://github.com/nix-community/nixos-wsl?ref=main` to work.

<br />

now another issue: i wasn't really sure how modules worked here. some ideas went through my head like "can i pass them to my config somehow and import them there like i did before?", "can i call the input from the arguments of the file?", "maybe i'm supposed to only use the options since it's already in `inputs`?". all of these could be half correct i guess, but far from the best option. i must have done a few dozen rebuilds in a few hours, but eventually i got to a point where things _mostly_ worked. in the end, i put the `nixos-wsl` module and the attrs i used for it in the `modules` argument for `nixosSystem`. that seemed to work

</div>

## enter: pain

<div id="blogText">

i felt pretty good now. throughout this, i had been moving a lot of the configs for programs to nix -- which was a much better time than gluing things together -- and started considering it as a replacement to my bare git repo of traditional dotfiles. i had also heard of something called home-manager, and with [great instructions](https://nix-community.github.io/home-manager/index.html#sec-flakes-nixos-module) and not a lot of effort, i was able to get that setup and move even more configurations to nix.

<br />

now i realized a problem: i want to start using this on bare metal. i already have a lot of programs and services configured that i would use there too, so how can i share them?

<br />

a quick solution i came up with (and totally didn't take inspiration from my friend [replaycoding](https://github.com/ReplayCoding) with) was making a common folder that i could import files from in the main machine configurations. this would made it trivial for me to share these (basic) configurations across systems, as well as manage all of them in one place. without even realizing it i think this is when i found main benefit of nixos modules: great composability with minimal effort.

<br />

i failed to do at this first, miserably. my configurations became filled with **a lot** of conditionals, entries in `let; in` expressions, and **_hours_** of mysterious `infinite recursion detected` errors. looking back now, this could have been solved with a bit of docs reading (maybe then i would've known you can't use things from `lib` when declaring `imports`), but it was harder for me to find back then, let alone understand. i was basically just writing stuff blind, but somehow -- and i don't know how -- i got it to work.

<br />

i didn't stop here, though. i realized i was repeating a lot of expressions, primarily when declaring the system configurations themselves with `nixosSystem`. this is when the idea of making my own wrappers and utility functions came to mind. i made one called `mkHost`. All it did was take in the system name, modules, system arch, and instance of `pkgs`, but it took me quite a bit of trial and error (like a lot of things so far) due to not understanding how functions were even made.

<br />

> thanks again to replaycoding here for helping me actually import the file containing `mkHost` correctly, i probably would've given up otherwise.

<br />

i was really proud of myself for pulling this off, and i even made some small improvements like concatenating the attrs for each system to `nixosConfigurations`. i was getting somewhere!

</div>

## diving deeper...

<div id="blogText">

`mkHost` was awesome, but i still felt like i could improve more for the future. the next step from `mkHost` was `mkUser`, naturally. this was similar: a very basic function giving me slightly less to type and declaring slightly annoying options. i quickly followed this up with `mkHMUser`, which was again similar, and made portable home-manager configurations trivial.

<br />

this was a really good setup so far, but i still felt like i could make it easier. i saw dotfiles from others such as [hlissner's](https://github.com/hlissner/dotfiles) and projects like [digga](https://github.com/divnix/digga) that seemed to also be accomplishing the same goal i had in mine. being the "diy-er" i am, i of course started going through hlissner's first, and being the "nix noob" i was, i didn't understand almost any of it besides the general concept of automatically importing a lot of files. digga was a bit more interesting, and i was able to start using it without many changes to pre-existing config. i had a few problems with it though, but mainly it was the feeling of not knowing everything that's going on in the background, along with the random (non-standard) outputs it would bring to my flake.

<br />

after a bit of experimenting, i tried to combine ideas from both, but with all of my own home-grown tools. out of this came a function i am still using called `mapFilterDir`. things get a bit advanced here so i think a codeblock might be necessary:

<br />

```nix
{
	mapFilterDir = dir: filter: map: let
		dirs = filterAttrs filter (readDir dir);
	in
		mapAttrs map dirs;
}
```

<br />

for those of you who are not familiar with nix, this function takes in a path to a directory, a function to filter through a list of files from the previously given directory, and a function who's returned value will be assigned to a variable named after each file in the filtered list. it's short and sweet, but can scale pretty well in my experience (though it could probably use a better name :p).

<br />

this, when combined with `mkHost` and `mkHMUser` (i had dropped `mkUser` at this point since i was declaring things manually somewhere else) allowed me to automagically import all host and home-manager configurations in a folder (assuming the host/user was the same as folder of course). this where i really felt like i had done something, and is mostly what i'm still using today

</div>

## enter: happiness and a near completed product

<div id="blogText">
this is the most recent part of the story, where i started thinking of making these expressions a bit more generalized, as some people i know have shown a bit of interest in nix (hi sake and hisashi). my first idea was to expand everything i had by a lot, maybe even going full `digga` with a `mkFlake` function! quickly though, i realized even that would be a lot of work; but more interestingly, i also realized that it's not what i needed anyways. i looked back at my old attempt at digga and found it was pretty close to what i'm doing now, except my own solutions fit my needs a lot better. sure, i haven't gotten to the level of hlissner's dotfiles yet, but i think what i have right now is good, so why not go after my original goal of only generalizing everything?

<br />

so that's what i did: i planned out exactly what i want, and what others may want too. i didn't want to make expressions that would change how you write a flake, as i think a big part of them is the standardization, both when interacting with them and hacking at them. instead, i only wanted to make things a bit easier, a la [flake-utils](https://github.com/numtide/flake-utils).

</div>

### quick explanation

<div id="blogText">
the idea i had for these expressions might be a little bit complicated, so i feel a need to explain it here. given a directory structure like so:

<br />

```shell
|	- hosts/
|	- default.nix
|	- glados/
|		- default.nix
|	- flake.nix
|	- users/
|		- default.nix
|		- seth/
|			- home.nix
|			- default.nix
```

<br />

in `flake.nix`, you can use this:

<br />

```nix
{
	homeConfigurations = forAllSystems (system: mapHMUsers system ./users);
	nixosConfiguration = mapHosts ./hosts;
}
```

<br />

this will collect basic information from the default.nix file in `hosts/` and `users/`, such as the name of the system/user, `pkgs` instance, state version, modules, etc. these values are then put into `mkHost` and `mkHMUser`, where the `default.nix` file is sourced from `hosts/glados`, along with the `home.nix` in `users/seth`. this can scale to any number of users or hosts, given that some attrs are set in the `default.nix` file of the parent folder. the defaults are pretty minimal and extensible, avoiding the feeling of being locked into doing something that i've felt with similar projects.

<br />

in layman's terms: you can declare what actually matters for your system instead of worrying about gluing them all together as flake outputs :)

</div>

## leaping from the depths of `nix repl`

<div id="blogText">

surprisingly, very little changes needed to be made to make everything non-specific to my configuration (thanks past me!). by the time i was done, all i really did was add my previous defaults in `mkHost` and `mkUser` to a [common](https://github.com/getchoo/flake/blob/3066f766ece62acd9b9897082dba28be87889dc1/hosts/default.nix#L3) attrset i use for all hosts in `hosts/default.nix`. there are still some [issues](https://github.com/getchoo/nix-exprs/issues/2), but i think i'm on a good path to having a fully complete "product."

<br />

overall, i feel like i have a sustainable and scalable set of expressions, that along with the _actual_ nixos modules i've made, will give me a nice experience for the long term, with no more worrying about `infinite recursion detected` errors. i just hope that maybe my work can do the same for others :)

</div>
