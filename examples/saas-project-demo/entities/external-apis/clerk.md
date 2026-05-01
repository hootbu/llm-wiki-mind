---
type: entity
subtype: external-api
status: active
created: 2026-02-28
updated: 2026-03-15
sources:
  - sources/2026-02-28-auth-provider-eval.md
  - sources/2026-03-12-rate-limit-incident.md
tags: [external-api, auth, clerk, vendor]
---

# clerk

FlowNote'un auth provider'ı. 2026-03-04'te Auth0'dan migrate edildik ([[decisions/0001-clerk-over-auth0]]).

## Sözleşme

- **Plan**: Pro.
- **Pricing**: $25/ay + $0.02/MAU after 5k. ~25k MAU'da ~$425/ay.
- **Eval karşılaştırması**: [[decisions/0001-clerk-over-auth0]].
- **SLA**: app-level uptime; auth-spesifik latency / availability SLA yok (gözden kaçtı, post-incident not).

## Gerçek davranış (dokümantasyondan ayrılan kısım)

> ⚠ Çelişki: Clerk pricing/docs sayfası "100 req/sec soft limit" diyor; support de aynı şeyi konfirme etti (2026-03-01). Ama 2026-03-12 incident'inde gerçek kuyruk yaklaşık **60 req/sec**'te reddetmeye başladı ([[sources/2026-03-12-rate-limit-incident]]). Çözüm: support ticket açık (Emir), gerçek peak burst kapasitesi henüz teyit edilmedi.

Bu fark 2026-03-12 cascade'inin doğrudan tetikleyicilerinden biri. Migration eval'inde rate limit "parking lot"taydı, derinleştirilmedi ([[syntheses/auth-migration-postmortem]]).

## Entegrasyon noktaları

- **JWT** issuance + refresh.
- **Webhook** → kendi `users` tablomuzda mirror tutuyoruz (Clerk-only state'i avoid etmek için).
- **Multi-org** → Clerk Organizations API.

## İlgili
- [[entities/services/auth-service]]
- [[decisions/0001-clerk-over-auth0]]
- [[decisions/0002-rate-limit-backoff]]
- [[syntheses/auth-migration-postmortem]]

## Açık sorular
- Gerçek peak burst kapasitesi (support ticket açık).
- 1000+ req/s tier pricing var mı? Şu an "kontak edin" diyorlar.
- Auth-level SLA sözleşmeye eklenebilir mi?

## Kaynaklar
- [[sources/2026-02-28-auth-provider-eval]]
- [[sources/2026-03-12-rate-limit-incident]]
