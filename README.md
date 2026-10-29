# JustScoo — demo of the redesigned website

Static build of the new JustScoo frontend (concept, not the official site; `noindex`).

Install / update on an Ubuntu server with nginx (served at `/justscoo`):

```bash
curl -fsSL https://raw.githubusercontent.com/humoramin/Scoo/main/install.sh | bash
```

Files go to `/var/www/sites/justscoo`; `/justscoo` redirects to `/justscoo/ru`. The server root is not changed.
