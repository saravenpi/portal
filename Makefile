OUTPUT_DIR=./
OUTPUT_FILE=portal
SRC_FILE=src/index.ts

all:
	bun build --compile $(SRC_FILE) --outfile $(OUTPUT_DIR)$(OUTPUT_FILE)
