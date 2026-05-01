# FlowNote — Offline Mode PRD

**Yazar:** Jane Doe (PM)
**Tarih:** 2026-02-15
**Durum:** Onaylandı (eng review beklemede)

## Bağlam

Kullanıcılar (özellikle metro/uçak) offline'a düşünce note'larında yazamıyor. Top 3 churn nedeni arasında "internet kesilince app çalışmıyor" var — son 90 günün NPS yorum analizi.

## Hedef

Tam offline yazma + reconciliation. Kullanıcı offline'da yazabilmeli, online'a dönünce diğer kullanıcılarla collaborative note'taki değişikliklerle merge olabilmeli. Manuel "conflict resolve" UI'ı istemiyoruz — kullanıcı sadece yazsın.

## Önerilen yaklaşım

**CRDT (Y.js).** OT (operational transformation) yerine CRDT seçildi çünkü:

- Conflict resolution deterministik, server-authoritative değil.
- Mevcut realtime backend'imiz zaten Y.js Awareness kullanıyor (cursor/selection sync için). Stack'in iki yarısını farklı modellerde tutmak istemiyoruz.
- OT için merkezi bir transform server gerekiyor; CRDT peer-to-peer benzeri çalışıyor — offline akışına uyuyor.

## Akış

1. Kullanıcı offline → Y.Doc IndexedDB'ye serialize.
2. Online → server'a Y.js update vector gönder.
3. Server merge edip diğer client'lara fan-out yapar.
4. Mobile (iOS/Android) için ayrı epic.

## Açık sorular

- Şifrelenmiş notlarda offline iken key rotation nasıl handle edilecek?
- Y.Doc 100MB'a yaklaşırsa GC stratejisi?
- IndexedDB limit'i tarayıcı bazlı; Safari'de pratikte ~50MB. Strategy?

## Tahmini iş

- Backend: 2 hafta (John)
- Frontend: 3 hafta (Emir + 1 jr)
- Mobile: ayrı epic (sonra planlanacak)

## Bağlı kararlar

- Eski offline-cache PoC'si (2025-Q4) iptal edildi — IndexedDB serialization sorunları, JSON-bazlı state ile başarısızdı.
- Bu PRD onun yerini alıyor; CRDT ile aynı sorun çözülüyor.
