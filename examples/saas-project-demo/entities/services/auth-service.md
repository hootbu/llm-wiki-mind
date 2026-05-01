---
type: entity
subtype: service
status: active
created: 2026-02-28
updated: 2026-03-15
sources:
  - sources/2026-02-28-auth-provider-eval.md
  - sources/2026-03-12-rate-limit-incident.md
tags: [service, auth, clerk]
---

# auth-service

FlowNote'un kimlik doğrulama servisi. 2026-03-04'te Auth0'dan Clerk'e migrate edildi ([[decisions/0001-clerk-over-auth0]]).

## Mevcut durum

- **Provider**: [[entities/external-apis/clerk]].
- **Token modeli**: JWT, 1 saatlik access + 30 günlük refresh.
- **Multi-org**: Clerk Organizations API üzerinden, kendi RLS politikalarımızla bütünlük.
- **Migration sonrası**: dual-mode 2 hafta açıktı (2026-03-04 → 2026-03-18), sonra Auth0 kapatıldı.

## Token refresh stratejisi

2026-03-12 incident'inden sonra ([[sources/2026-03-12-rate-limit-incident]]) revize edildi:

- **Client-side**: jittered exponential backoff (initial 1s, factor 2, jitter ±25%, cap 30s, max 6 attempts) ([[decisions/0002-rate-limit-backoff]]).
- **Server-side**: envoy IP-aware throttle (30 req/min/IP) — defense-in-depth.

Migration öncesi Auth0'da bu kadar agresif limit yoktu, mobile client'ta backoff'suz refresh tolere ediliyordu. Clerk geçişi gizli bir varsayımı kırdı — bu varsayım eval'de fark edilmemişti ([[syntheses/auth-migration-postmortem]]).

## İlgili
- [[entities/external-apis/clerk]]
- [[decisions/0001-clerk-over-auth0]]
- [[decisions/0002-rate-limit-backoff]]
- [[entities/services/realtime-sync]]
- [[syntheses/auth-migration-postmortem]]

## Açık sorular
- Self-host opsiyonu (Lucia, NextAuth) bir sonraki major'da yeniden değerlendirilecek mi?
- Auth-level uptime SLA Clerk sözleşmesinde yok — eklenmeli mi?

## Kaynaklar
- [[sources/2026-02-28-auth-provider-eval]]
- [[sources/2026-03-12-rate-limit-incident]]
