#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl -p unzip

# Adapted from <nixpkgs>/pkgs/misc/documentation-highlighter/update.sh

set -eu
set -o pipefail

root=$(pwd)

if [ ! -f "./update.sh" ]; then
    echo "Please run this script from within pkgs/misc/documentation-highlighter/!"
    exit 1
fi

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
function finish {
  rm -rf "$scratch"
}
trap finish EXIT


mkdir $scratch/src
cd $scratch/src

token=$(curl https://highlightjs.org/download/ -c "$scratch/jar" \
    | grep csrf \
    | cut -d'"' -f6)

curl --header "Referer: https://highlightjs.org/download/"\
    -b "$scratch/jar" \
    --data "csrfmiddlewaretoken=$token&nix.js=on&bash.js=on&python.js=on&makefile.js=on&ini.js=on" \
    https://highlightjs.org/download/ > $scratch/out.zip

unzip "$scratch/out.zip"
out="$root/"
mkdir -p "$out"
cp ./{highlight.min.js,LICENSE,styles/mono-blue.min.css} "$out"

(
    echo "This file was generated with pkgs/misc/documentation-highlighter/update.sh"
    echo ""
    cat README.md
) > "$out/README.md"
