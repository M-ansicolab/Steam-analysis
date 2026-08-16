#!/usr/bin/env bash
# Downloads the real Steam catalog dataset used by this project.
# Source: win7guru/steam-dataset-2024 on GitHub (mirrors the Fronkon Games "Steam Games Dataset").
set -e
mkdir -p data && cd data

FILES="games genres tags reviews steamspy_insights categories"
BASE="https://raw.githubusercontent.com/win7guru/steam-dataset-2024/main"

for f in $FILES; do
    echo "Downloading ${f}.zip ..."
    curl -sL -o "${f}.zip" "${BASE}/${f}.zip"
    unzip -o -q "${f}.zip"
done

echo "Done. CSVs are in data/. Now run: python3 build_db.py"
