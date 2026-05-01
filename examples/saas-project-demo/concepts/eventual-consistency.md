---
type: concept
status: active
created: 2026-02-15
updated: 2026-02-15
sources:
  - sources/2026-02-15-offline-sync-spec.md
tags: [concept, distributed-systems, crdt]
aliases: [Eventual Consistency, Sonunda Tutarlılık]
---

# eventual-consistency

Distributed sistemlerde tutarlılığın "her replicada anında aynı state" değil, "yeterli zaman geçince hepsi aynı state'te buluşur" olarak garanti edilmesi.

## Niye FlowNote için önemli

[[entities/features/offline-mode]] ve [[entities/services/realtime-sync]] direkt eventual consistency üstüne kurulu:

- Offline kullanıcı yerel yazıyor → kendi replica'sı server'dan ayrışıyor.
- Online'a dönünce → CRDT merge → tüm replica'lar konverj ediyor.

Bu modeli kabul etmek manuel "conflict resolution" UI'ından kurtarıyor; ama "kullanıcı şu anda gördüğü state benim cihazımdaki güncel olmayabilir" varsayımını her UI/UX kararına geçiriyor (örn. "bu note 3 dk önce güncel" tipi metadata).

## CRDT vs OT

OT (operational transformation) merkezi bir "transform server" gerektirir; client → server → diğer client'lar. CRDT (Y.js gibi) decentralize merge edebilir; offline durumda peer-to-peer ya da gecikmeli sync mümkün.

FlowNote CRDT seçti çünkü:
- Offline-first hedefi ([[sources/2026-02-15-offline-sync-spec]]).
- Mevcut Y.js stack (Awareness için zaten kullanılıyordu).
- OT'nin server-authoritative modeli offline akışına uymuyor.

## İlgili
- [[entities/features/offline-mode]]
- [[entities/services/realtime-sync]]

## Kaynaklar
- [[sources/2026-02-15-offline-sync-spec]]
