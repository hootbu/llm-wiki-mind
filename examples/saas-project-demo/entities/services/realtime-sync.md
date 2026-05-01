---
type: entity
subtype: service
status: active
created: 2026-02-15
updated: 2026-02-15
sources:
  - sources/2026-02-15-offline-sync-spec.md
tags: [service, realtime, crdt, yjs]
---

# realtime-sync

FlowNote'un collaborative note edit servisi. Y.js CRDT + WebSocket. Offline mode reconciliation'ı da bu servis üzerinden geçer.

## Niye var

Aynı note'ta birden fazla kullanıcı eş zamanlı yazabilsin; kullanıcı offline'a düşse bile geri dönünce merge olabilsin. Manuel conflict resolution UI'ı istemiyoruz ([[sources/2026-02-15-offline-sync-spec]]).

## Ana parçalar

- **Y.Doc** — note'un CRDT temsili. Client'larda runtime'da, server'da snapshot.
- **WebSocket gateway** — update vector exchange.
- **Awareness channel** — cursor / selection / presence (offline mode'dan önce de vardı).
- **Persistence layer** — Postgres'te Y.js update log + son snapshot.

## Token refresh ile ilişki

Servis WebSocket bağlantısı başında auth token doğruluyor. Token expire olursa client refresh akışına gidiyor — bu akış 2026-03-12 incident'inde rate limit'e takıldı ([[sources/2026-03-12-rate-limit-incident]]). Sonrasında [[decisions/0002-rate-limit-backoff]] uygulandı.

## İlgili
- [[entities/features/offline-mode]]
- [[entities/services/auth-service]]
- [[concepts/eventual-consistency]]

## Açık sorular
- Y.Doc 100MB'a yaklaşınca server-side GC stratejisi?

## Kaynaklar
- [[sources/2026-02-15-offline-sync-spec]]
