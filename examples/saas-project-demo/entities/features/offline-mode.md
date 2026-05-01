---
type: entity
subtype: feature
status: active
created: 2026-02-15
updated: 2026-02-15
sources:
  - sources/2026-02-15-offline-sync-spec.md
tags: [feature, offline, sync]
---

# offline-mode

Kullanıcının internet olmadığında bile FlowNote'ta yazıp, online'a dönünce diğer collaborator'larla merge olabilmesi.

## Niye

Top 3 churn nedeni arasında "internet kesilince app çalışmıyor" var; NPS yorum analizi (son 90 gün) bunu somutlaştırdı ([[sources/2026-02-15-offline-sync-spec]]).

## Yaklaşım

- **Persistence**: IndexedDB'ye Y.Doc serialize.
- **Sync**: online'a dönünce server'a update vector, server merge + diğer client'lara fan-out.
- **Conflict**: CRDT deterministik merge, manuel resolution yok.

## Bağımlılıklar

- [[entities/services/realtime-sync]] servisinin Y.js stack'i.
- [[concepts/eventual-consistency]] modeli.

## Sınırlar

- Safari IndexedDB pratikte ~50MB → büyük note'larda strategy gerek.
- Y.Doc GC stratejisi 100MB+ için açık.
- Şifrelenmiş notlarda offline key rotation çözülmemiş.

## İlgili
- [[entities/services/realtime-sync]]
- [[concepts/eventual-consistency]]

## Açık sorular
- Mobile epic ne zaman? (PRD'de "ayrı epic, sonra")
- Safari 50MB strategy?
- Şifrelenmiş not + offline iken key rotation?

## Kaynaklar
- [[sources/2026-02-15-offline-sync-spec]]
