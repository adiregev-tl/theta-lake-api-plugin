# Theta Lake API — Legal Hold (renamed)

`/legal_hold` no longer exists. The resource is now `/legal_matters`, and its
`rules` sub-resource is now `custodians`. Verified on dev1 2026-10-22:
`GET /api/v1/legal_hold` returns 404, `GET /api/v1/legal_matters` returns 200.

See **[legal-matters-api.md](legal-matters-api.md)**.

The previous version of this file is kept as `legal-hold-api.md.bak-20261022`.
