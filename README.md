# Squid with SSL build scripts

Build scripts for https://launchpad.net/~kgeorgiy/+archive/ubuntu/squid-ssl

Usage: `squid-ssl-deb.sh [release]` or `squid-ssl-deb.sh --all`

Per-release patches are in [patches](patches) directory. Add `squid-[release].patch` for new release support.

# Preparation

Install required packages: `apt-get install -y gnupg pbuilder ubuntu-dev-tools devscripts build-essential fakeroot debhelper dh-autoreconf dh-apparmor cdbs`
