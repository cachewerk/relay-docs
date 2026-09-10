# Relay documentation: agent guide

## Repository map

This repository documents the Relay PHP extension (`relay.so`).

- `docs/1.x/`: Markdown guides published at `https://relay.so/docs`. The website renderer and its deployment tooling are not included here; there is no local build command for these guides.
- `docs/1.x/index.md`: guide navigation. Add new pages here and update links when moving pages.
- `doctum/config.php`: API generation configuration, source selection, versions, and output paths.
- `doctum/theme/`: custom Twig theme extending Doctum's default theme.
- `bin/stubs-doctum.sh`: downloads published Relay stubs used to generate API documentation.
- `dist/`: GitHub Pages site for `https://docs.relay.so`. The tracked `index.html` and `api/index.html` redirect to the development API. Generated pages live in ignored `dist/api/<version>/` directories.
- `.github/workflows/docs.yml`: API build and deployment; `.github/workflows/lint.yml`: spelling checks.

An optional local `relay` symlink may point to a separate extension checkout. It is not a tracked dependency and the API build does not read it. Use it as a reference for feature behavior when available; keep documentation changes in this repository and do not commit the symlink.

## Writing and updating guides

- Follow nearby pages: YAML `title` front matter, one H1, descriptive section headings, and language-tagged code fences. `index.md` is a navigation list rather than a regular content page.
- Preserve website syntax such as `[TOC]` and `{{relay}}` version placeholders. Internal guide links use `/docs/1.x/<page>` without `.md`; API links point to `https://docs.relay.so/api/...`.
- Keep existing URLs and heading anchors stable where possible. Check incoming links when renaming a page or heading.
- Follow `.editorconfig`: UTF-8, LF, final newline, four-space indentation generally and two spaces for YAML. Markdown allows intentional trailing whitespace; avoid unrelated reformatting.
- Verify new methods, constants, defaults, units, return values, and version availability against the relevant Relay stubs, implementation, tests, or release information. Distinguish development features from released behavior; do not infer availability from the `1.x` guide directory name.
- For new features, update the relevant topic plus shared reference pages as needed: INI directives in `configuration.md`, runtime options in `options.md`, connection behavior in `connections.md`, and compatibility implications in `compatibility.md`. Keep duplicated defaults and examples consistent.
- Include a minimal usage example and relevant prerequisites or limitations. Check namespaces and named arguments against the target API. State whether an option must be set before connecting when applicable.
- API signatures and PHPDoc come from upstream `relay.stub.php` files. Correct those at their source when needed; editing generated HTML or downloaded stubs is not a durable documentation fix.

## API build and preview

Run commands from the repository root. The build uses PHP, Composer, Bash, and `wget`, with network access for dependencies and stubs. `composer.json` declares `code-lts/doctum` at `^5.5`; there is no pinned PHP runtime in the workflow. Generating API pages does not require loading the Relay extension or running Redis.

```sh
composer install --no-interaction
composer run doctum:stubs
composer run doctum
```

`doctum:stubs` deletes the contents of `doctum/.stubs/` before downloading the latest release metadata, development stub, and latest stable stub from `builds.r2.relay.so`. Preserve any deliberate local stub changes before running it.

The configuration copies each version's stub into `doctum/.source/`, caches parsing in `doctum/.cache/<version>/`, and writes HTML to `dist/api/<version>/`. `vendor/`, `composer.lock`, `doctum/.*`, and generated API directories are ignored; do not add them to commits.

**Version alignment:** `doctum/config.php` currently lists `0.x` and `develop` explicitly, while the download script derives the stable directory from the latest release tag. If a build cannot find the stable stub, compare these names. Coordinate changes to the downloader, version collection, and redirects when changing API versions; do not automatically rename them to match `docs/1.x`.

After building, preview the API site locally:

```sh
php -S 127.0.0.1:8000 -t dist
```

Open `http://127.0.0.1:8000/` and inspect affected pages, navigation, and links. This serves the API output only; it does not render the Markdown guides.

## Validation

- For prose changes, run `codespell <changed-markdown-files>` and check front matter, code fences, navigation entries, and link targets manually.
- The existing CI check is `codespell` from the repository root, using `.codespellrc` and `codespell>=2.2`. Run it before submitting a PR; distinguish existing spelling failures from new ones.
- For build changes, run the relevant syntax checks (`php -l doctum/config.php`, `bash -n bin/stubs-doctum.sh`) and the API build above. For theme changes, build and inspect the affected HTML.
- Run `git diff --check` and review the final diff. For an untracked new file, also check its contents directly because it is absent from the default diff.
- No automated example tests, Markdown renderer, or link checker are configured here. A successful API build does not validate guide examples. Report checks performed and any unavailable validation without claiming a full site build.

## Deployment

The API workflow runs daily at **11:00 UTC** and via `workflow_dispatch`; it is not triggered by pushes or pull requests. It installs dependencies, downloads stubs, builds API pages with Doctum, and uploads all of `dist/` to GitHub Pages. A local build only generates files. Consult `.github/workflows/docs.yml` for the exact CI command and deployment behavior.

Keep this file concise and update commands or repository-specific guidance when the corresponding workflow changes.
