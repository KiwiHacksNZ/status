# 📈 KiwiHacks Status

Uptime monitor and status page for KiwiHacks services, powered by [Upptime](https://github.com/upptime/upptime).

Checks run every 5 minutes on GitHub Actions, independent of KiwiHacks infrastructure, so the monitor stays up even when a service does not.

- **Status page:** https://status.kiwihacks.com
- **Incidents** are filed automatically as GitHub Issues here and close themselves on recovery.
- **Alerts** go to Discord via the `NOTIFICATION_DISCORD_WEBHOOK_URL` repo secret.

## How it fits together

| Piece      | Where                                                           | Notes                                               |
| ---------- | --------------------------------------------------------------- | --------------------------------------------------- |
| Checks     | GitHub Actions, `uptime.yml`, every 5 min                       | Free, unlimited minutes because this repo is public |
| Data       | `history/`, `api/`, `graphs/` on `master`                       | Committed by the workflows                          |
| Site build | `site.yml` pushes static output to `gh-pages`                   |                                                     |
| Hosting    | Vercel project `kiwihacks-status`, production branch `gh-pages` | No build command, output dir `.`                    |

## Monitored services

Edit `.upptimerc.yml` to add or remove one. The workflows regenerate from it on push.

## Operational notes

**Actions needs `GH_PAT`.** The KiwiHacksNZ org disables write permissions for `GITHUB_TOKEN`
org-wide, so `github-actions[bot]` gets a 403 when Upptime commits results. The workflows fall
back to the `GH_PAT` repo secret, a fine-grained token scoped to this repo only
(Contents + Workflows, read and write). Rotate it before it expires or every workflow starts
failing silently.

**Two workflows are disabled on purpose.** `updates.yml` and `update-template.yml` both ran
`upptime/*@master`, an unpinned upstream branch, while holding `GH_PAT`. Disabling them removes
that supply-chain exposure. Cost: Upptime template updates are now manual. Re-enable only if you
pin those actions to commit SHAs first.

**DNS.** `status.kiwihacks.com` lives on Cloudflare. Both records must be DNS-only (grey cloud);
proxying breaks Vercel certificate issuance.
