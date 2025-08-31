# Usage:
# just run
# just build
# just deploy

set shell := ["/opt/homebrew/bin/fish", "-c"]

run:
	flutter run

build:
	flutter build web --release

serve:
	python3 -m http.server -d build/web 8080

# Requires `wrangler` CLI configured (`wrangler login`) and account_id in wrangler.toml
deploy: build
	wrangler pages deploy build/web
