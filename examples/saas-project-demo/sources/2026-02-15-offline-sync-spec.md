---
type: source
subtype: prd
status: active
created: 2026-02-15
updated: 2026-02-15
tags: [offline, sync, prd, crdt]
---

# Offline Mode PRD özeti

PM Jane Doe tarafından yazılan PRD; FlowNote'a tam offline yazma + reconciliation getiriyor.

## Anahtar noktalar

- **Niyet**: offline metroda/uçakta yazabilme; top 3 churn nedeninden biri ([raw](../raw/specs/offline-sync-spec.md)).
- **Yaklaşım**: CRDT (Y.js), OT değil. Mevcut realtime stack zaten Y.js Awareness kullanıyor.
- **Persistence**: IndexedDB Y.Doc serialize.
- **Sync**: online'a dönünce update vector server'a, server merge + diğer client'lara fan-out.
- **Sınırlar**: Safari IndexedDB pratikte ~50MB; Y.Doc GC stratejisi 100MB'a yaklaşınca açık ([raw](../raw/specs/offline-sync-spec.md)).
- **Tahmini effort**: backend 2 hafta, frontend 3 hafta, mobile ayrı epic.
- **Eski PoC**: 2025-Q4 JSON-bazlı offline-cache iptal edildi; bu PRD onun yerini alıyor.

## İlgili
- [[entities/features/offline-mode]]
- [[entities/services/realtime-sync]]
- [[concepts/eventual-consistency]]

## Açık sorular
- Y.Doc GC stratejisi 100MB'a yaklaşınca ne olacak?
- Safari 50MB limit'i için strategy?
- Şifrelenmiş notlarda offline key rotation?

## Kaynaklar
- [raw/specs/offline-sync-spec.md](../raw/specs/offline-sync-spec.md)
