# 📈 KiwiHacks Status

Uptime monitor and status page for KiwiHacks services, powered by [Upptime](https://github.com/upptime/upptime).

Checks run every 5 minutes on GitHub Actions, independent of KiwiHacks infrastructure, so the monitor stays up even when a service does not.

- Status page: https://status.kiwihacks.com
- Incidents are filed automatically as GitHub Issues in this repo and close themselves on recovery.
- To add or remove a monitored service, edit `.upptimerc.yml`. The workflows regenerate from it on push.
