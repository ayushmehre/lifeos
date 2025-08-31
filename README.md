LifeOS — Flutter Web + Cloudflare Pages
======================================

This repository is now a pure Flutter app targeting the web. Deployments use Cloudflare Pages via Wrangler.

Prerequisites
- Flutter SDK installed and on PATH (`flutter --version`).
- Cloudflare Wrangler installed (`npm i -g wrangler`) and authenticated (`wrangler login`).

Local Build
```bash
flutter pub get
flutter build web --release
```
The static site is generated at `build/web`.

One-Command Deploy with just
```bash
# Default project name (from justfile): lifeos
just deploy

# Override project name
just deploy my-pages-project
# or
PAGES_PROJECT_NAME=my-pages-project just deploy
```
The recipe builds the Flutter web app and runs:
`wrangler pages deploy --project-name <project>`

Local Preview (Pages dev server)
```bash
just preview
```

Notes
- `wrangler.toml` sets `pages_build_output_dir = "build/web"` so the deploy command doesn’t need a directory argument.
- If you still have a local `.next/` folder from previous Next.js experiments, it is ignored by `.gitignore`. You can remove it with `rm -rf .next`.
