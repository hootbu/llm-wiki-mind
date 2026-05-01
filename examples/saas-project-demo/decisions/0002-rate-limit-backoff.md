---
type: decision
status: active
created: 2026-03-15
updated: 2026-03-15
sources:
  - sources/2026-03-12-rate-limit-incident.md
tags: [decision, adr, rate-limit, client-resilience]
---

# 0002 — Client-side jittered exponential backoff for token refresh

**Karar:** Mobile + web client'larda token refresh akışı jittered exponential backoff kullanacak.
**Tarih:** 2026-03-15
**Karar verenler:** Emir Yorgun, John Doe.
**Status:** active.

## Bağlam

2026-03-12 rate limit incident'inde ([[sources/2026-03-12-rate-limit-incident]]) mobile client'ların backoff'suz refresh akışı 7 dakikada ~4200 user login fail'a yol açtı. Clerk'in gerçek limit'i (~60 req/sec) dokümante edilmiş "100 req/sec"in altında çıktı — ama incident'in tek nedeni bu değil; mobile client'taki backoff eksikliği amplifier'dı.

## Karar

Token refresh akışında:

- **Initial delay**: 1s.
- **Multiplier**: 2.
- **Jitter**: ±25% (peak'te uniform retry'ı kırmak için, thundering herd avoid).
- **Cap**: 30s.
- **Max attempts**: 6 (sonra hard logout, kullanıcı tekrar login'e yönlendirilir).

**Server-side ek savunma**: envoy IP-aware throttle, 30 req/min/IP (John deploy etti incident sırasında, kalıcı bırakıldı).

## Alternatif düşünülenler

- **Linear backoff**: rejected — peak burst'te yetersiz dağılım, yine cascade riski.
- **Token caching extension** (refresh'i nadirleştir): rejected — security tradeoff (uzun-yaşayan token), scope creep.
- **SDK-level handling Clerk'e bırak**: rejected — Clerk SDK'nın mobile client'ta yeterli backoff'u yok (test edildi 2026-03-13).

## Ölçüm

Hot-fix deploy'undan sonra ilk 7 gün:
- 429 response oranı %0.04 → %0.001'e düştü.
- Refresh latency p99 → 1.4s (jitter etkisi).
- Yeni cascade riski monitoring'de bekleniyor; on-call playbook'a eklendi.

## İlgili
- [[entities/services/auth-service]]
- [[entities/external-apis/clerk]]
- [[decisions/0001-clerk-over-auth0]]
- [[syntheses/auth-migration-postmortem]]

## Kaynaklar
- [[sources/2026-03-12-rate-limit-incident]]
