#!/usr/bin/env bash
# Installs (or updates) the JustScoo demo at http://<server>/justscoo on Ubuntu + nginx.
# The server's own root page is left untouched.
# Usage:  curl -fsSL https://raw.githubusercontent.com/humoramin/Scoo/main/install.sh | bash
set -euo pipefail
ARCHIVE="https://github.com/humoramin/Scoo/archive/refs/heads/main.tar.gz"
SITE_CONF=/etc/nginx/sites-available/default
command -v nginx >/dev/null || { apt-get update -y && apt-get install -y nginx; }
tmp=$(mktemp -d)
echo "Downloading site..."
curl -fsSL "$ARCHIVE" -o "$tmp/src.tar.gz"
tar -xzf "$tmp/src.tar.gz" -C "$tmp"
src=$(find "$tmp" -maxdepth 1 -type d -name 'Scoo-*' | head -1)
mkdir -p /var/www/sites
rm -rf /var/www/sites/justscoo.new && cp -r "$src/site" /var/www/sites/justscoo.new
rm -rf /var/www/sites/justscoo && mv /var/www/sites/justscoo.new /var/www/sites/justscoo
mkdir -p /etc/nginx/snippets
cp "$src/nginx-justscoo.conf" /etc/nginx/snippets/justscoo.conf
# hook the snippet into the default server block (once)
if ! grep -q "snippets/justscoo.conf" "$SITE_CONF"; then
  cp "$SITE_CONF" "$SITE_CONF.bak-justscoo"
  sed -i '0,/server_name _;/s//server_name _;\n\tinclude snippets\/justscoo.conf;/' "$SITE_CONF"
fi
grep -q "snippets/justscoo.conf" "$SITE_CONF" || { echo "Could not add the include to $SITE_CONF — add 'include snippets/justscoo.conf;' inside its server { } block"; exit 1; }
ln -sf "$SITE_CONF" /etc/nginx/sites-enabled/default
if ! nginx -t; then
  [ -f "$SITE_CONF.bak-justscoo" ] && cp "$SITE_CONF.bak-justscoo" "$SITE_CONF"
  echo "nginx config test failed — restored the previous config"; exit 1
fi
systemctl reload nginx || systemctl restart nginx
rm -rf "$tmp"
echo "Done: open http://$(hostname -I | awk '{print $1}')/justscoo"
