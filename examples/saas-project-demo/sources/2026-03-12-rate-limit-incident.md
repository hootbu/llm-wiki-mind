---
type: source
subtype: incident
status: active
created: 2026-03-12
updated: 2026-03-12
tags: [incident, auth, rate-limit, sev2]
---

# Rate limit cascade incident özeti

Clerk migration'dan 1 hafta sonra Pazartesi peak'inde 7 dakikalık SEV-2 incident.

## Anahtar noktalar

- **Süre / etki**: 7 dk, ~4200 kullanıcı login fail, ~$760 revenue impact ([raw](../raw/incidents/2026-03-rate-limit.md)).
- **Tetikleyici**: Pazartesi 09:00 TRT peak; concurrent ~800 user.
- **Root cause #1**: Mobile client'ta backoff yok; 401 → refresh → 429 → hemen retry. 30 saniyede tek client ~12 retry.
- **Root cause #2**: Clerk gerçek limit ~60 req/sec; dokümantasyon "100 req/sec" diyor → çelişki.
- **Düzeltme**: Server-side IP-aware throttle (envoy filter, 30 req/min/IP) + client-side jittered exponential backoff hot-fix.
- **Önemli not**: Clerk eval'de rate limit "parking lot"taydı; "support cevabı yeterli görüldü" diye kapatıldı, derinleştirilmemişti — eval kararının zayıf noktası.
- **Varsayım kayması**: Mobile backoff'suz refresh Auth0 dünyasında yaşıyordu; Clerk'e geçiş bunu enforce eden ortamı kaldırdı.

## İlgili
- [[entities/services/auth-service]]
- [[entities/external-apis/clerk]]
- [[decisions/0002-rate-limit-backoff]]
- [[decisions/0001-clerk-over-auth0]]

## Açık sorular
- Clerk gerçek peak burst kapasitesi nedir? (Support ticket açık.)
- 1000+ req/s tier için pricing var mı?
- Auth-level uptime SLA eksikliği — sözleşmeye eklenmeli mi?

## Kaynaklar
- [raw/incidents/2026-03-rate-limit.md](../raw/incidents/2026-03-rate-limit.md)
