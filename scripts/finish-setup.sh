#!/usr/bin/env bash
# Finishes KiwiHacks status page setup once GH_PAT is in place.
# Run from anywhere:  bash scripts/finish-setup.sh
set -euo pipefail

REPO="KiwiHacksNZ/status"
PROJECT_ID="prj_3pFmfEaEIXyMOuVDBvuvY0WaTY0H"
AUTH="$HOME/Library/Application Support/com.vercel.cli/auth.json"

unset GITHUB_TOKEN || true

echo "==> Checking GH_PAT secret exists"
gh secret list -R "$REPO" | grep -q '^GH_PAT' || {
  echo "GH_PAT secret not set. Add it first:"
  echo "  gh secret set GH_PAT -R $REPO"
  exit 1
}

echo "==> Triggering Upptime workflows"
gh workflow run uptime.yml -R "$REPO"
gh workflow run setup.yml -R "$REPO"

echo "==> Waiting for gh-pages branch (up to 10 min)"
for i in $(seq 1 60); do
  if gh api "repos/$REPO/branches/gh-pages" >/dev/null 2>&1; then
    echo "gh-pages exists"
    break
  fi
  sleep 10
done
gh api "repos/$REPO/branches/gh-pages" >/dev/null 2>&1 || {
  echo "gh-pages never appeared. Check: gh run list -R $REPO"
  exit 1
}

echo "==> Pointing Vercel production branch at gh-pages"
TOK=$(python3 -c "import json;print(json.load(open(r'''$AUTH'''))['token'])")
curl -s -X PATCH "https://api.vercel.com/v9/projects/$PROJECT_ID/branch" \
  -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
  -d '{"branch":"gh-pages"}' -w '\nHTTP %{http_code}\n'

echo
echo "Done. Remaining manual step: add the DNS record for status.kiwihacks.com"
echo "  CNAME  status  ->  cname.vercel-dns.com   (DNS only, do NOT proxy through Cloudflare)"
