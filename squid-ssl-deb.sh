#!/bin/bash
set -eu -o pipefail

if [[ $# -ne 1 ]]; then
  echo 1>&2 -e "Single argument expected\nUsage: $0 release\n   or: $0 --all\nE.g. $0 focal"
  exit 2
fi

if [[ "$1" == "--all" ]]; then
  for f in patches/* ; do
      f=${f#"patches/squid-"}
      "$0" "${f%.patch}"
  done
  exit
fi

error() {
  echo 2>&1 "$1"
  exit 1
}

release="$1"
dir="__build/squid-$release"

[[ -d "$dir" ]] && rm -r "$dir"
mkdir -p "$dir"
pushd "$dir"

pull-lp-source squid "$release" 2>&1
pushd "$(find squid* -maxdepth 0 -type d)"

version="$(head -1 debian/changelog | sed -E "s/^.*\(([[:alnum:]:.~-]+)\).*$/\1+ssl/; t; q1")"
version_file="../../squid-$release.versions/$version" || error "Malformed header"
if [[ -f "$version_file" ]]; then
  echo "Already uploaded $release $version"
  exit
fi

patch -p0 < "../../../patches/squid-$release.patch"

header="$(head -1 debian/changelog | sed -E "s/\(([[:alnum:]:.~-]+)\) [[:alnum:]:.~-]+\;/(\1+ssl) $release\;/; t; q1")" || error "Malformed header"
cat > debian/changelog~ << END
$header

  * Build with SSL support (--enable-ssl --with-openssl)

 -- Georgiy Korneev <kgeorgiy@kgeorgiy.info>  $(date -R)

$(cat debian/changelog)
END
mv debian/changelog~ debian/changelog
head debian/changelog

debuild -S -d --lintian-opts --no-lintian

dput ppa:kgeorgiy/squid-ssl ../squid*+ssl_source.changes 2>&1

mkdir -p "$(dirname "$version_file")"
touch "$version_file"

popd
popd

