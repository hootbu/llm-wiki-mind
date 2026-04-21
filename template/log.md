# Log

Append-only olay kaydı. Her ingest, filed-back query, lint pass ve şema değişikliği buraya.

**Format:**
- `## [YYYY-MM-DD] ingest | <konu> → <etki>`
- `## [YYYY-MM-DD] query | "<soru>" → filed: [[sayfa]]`
- `## [YYYY-MM-DD] lint | <sayılar>`
- `## [YYYY-MM-DD] schema | <ne değişti>`

En yeni olay en altta.

---

<!-- vault-init ilk girişi otomatik ekler -->
