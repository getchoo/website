import lume from "lume/mod.ts";
import attributes from "lume/plugins/attributes.ts";
import base_path from "lume/plugins/base_path.ts";
import code_highlight from "lume/plugins/code_highlight.ts";
import date from "lume/plugins/date.ts";
import remark from "lume/plugins/remark.ts";
import sass from "lume/plugins/sass.ts";
import sitemap from "lume/plugins/sitemap.ts";

const site = lume({
  src: "./src",
  location: new URL("https://getchoo.github.io"),
});

site.use(attributes());
site.use(base_path());
site.use(code_highlight());
site.use(date());
site.use(remark());
site.use(sass());
site.use(sitemap());

const getGitRevision = async () => {
  const p = Deno.run({
    cmd: ["git", "rev-parse", "HEAD"],
    stdout: "piped",
  });
  const [status, output] = await Promise.all([p.status(), p.output()]);

  if (status.success) {
    return new TextDecoder().decode(output).trim();
  }

  return null;
};

site.data(
  "gitRevision",
  await getGitRevision(),
);

site.ignore("README.md", "LICENSE", ".gitignore", ".gitattributes");

site.copy("imgs");
site.copy("files");
site.copy("js");
site.copy("favicon.ico");

export default site;
