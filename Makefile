.PHONY: all build test cli-build cli-test cli-run app-run app-test app-analyze

all: build

cli-build:
	cd cli && bun run build

cli-test:
	cd cli && bun run test

cli-run:
	cd cli && bun run src/index.ts

app-run:
	cd app && flutter run

app-test:
	cd app && flutter test

app-analyze:
	cd app && flutter analyze

build: cli-build
	cd app && flutter build linux --release

test: cli-test app-test
