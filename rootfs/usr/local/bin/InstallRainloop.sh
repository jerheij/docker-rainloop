#!/bin/bash
# shellcheck disable=2086

ZipURL=$(curl -s -H "Accept: application/vnd.github+json"   -H "X-GitHub-Api-Version: 2022-11-28"   https://api.github.com/repos/RainLoop/rainloop-webmail/releases/latest | grep browser_download_url | grep zip | grep -v -e owncloud -e asc  | cut -d ':' -f2- | cut -d '"' -f2)
KeyURL=$(curl -s -H "Accept: application/vnd.github+json"   -H "X-GitHub-Api-Version: 2022-11-28"   https://api.github.com/repos/RainLoop/rainloop-webmail/releases/latest | grep browser_download_url | grep asc | grep -v -e owncloud | cut -d ':' -f2- | cut -d '"' -f2)
ZipFileName=$(echo $ZipURL | rev | cut -d '/' -f1 | rev)
KeyFileName=$(echo $KeyURL | rev | cut -d '/' -f1 | rev)

mkdir /tmp/rainloop 
cd /tmp/rainloop || exit 1

wget -q https://www.rainloop.net/repository/RainLoop.asc
wget -q $ZipURL
wget -q $KeyURL

gpg --import RainLoop.asc
FINGERPRINT="$(LANG=C gpg --verify $KeyFileName $ZipFileName 2>&1 | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")"

if [ -z "${FINGERPRINT}" ] 
then 
  echo "ERROR: Invalid GPG signature!" && exit 1; 
fi

if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]
then 
  echo "ERROR: Wrong GPG fingerprint!" && exit 1
else 
  echo "SUCCESS: GPG fingerprint correct!"
fi

mkdir /rainloop && unzip -q /tmp/rainloop/${ZipFileName} -d /rainloop
find /rainloop -type d -exec chmod 755 {} \;
find /rainloop -type f -exec chmod 644 {} \;
rm -vrf /tmp/rainloop /root/.gnupg