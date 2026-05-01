# saas-project-demo

llm-wiki-mind pattern'ının yazılım projesi senaryosunda nasıl göründüğünü gösteren örnek vault.

**Hayali proje:** FlowNote — collaborative real-time note-taking SaaS (Next.js + Postgres + Y.js). 12k DAU.

## Hikaye

Üç raw input, birbirine bağlı bir prod hikayesi:

1. **Şubat ortası:** Offline mode için PRD geldi. CRDT temelli Y.js senaryosu öneriliyor.
2. **Şubat sonu:** Auth provider değerlendirme toplantısı — Auth0'dan Clerk'e geçiş kararı.
3. **Mart ortası:** Migration'dan 1 hafta sonra peak saatte rate limit incident — Clerk'in app-level limit'i Auth0'dakinden katı çıkıyor, login fail cascade'i.

Wiki bunlardan üretildi:

- **3 source** — her raw için bir özet sayfası
- **4 entity** — `auth-service`, `realtime-sync`, `offline-mode`, `clerk`
- **1 concept** — `eventual-consistency`
- **2 decision** — Clerk seçimi, client-side backoff stratejisi
- **1 synthesis** — postmortem, kararla incident'i birleştiren filed-back

## Bunu nasıl okumalıyım?

- [`CLAUDE.md`](CLAUDE.md) — vault'un şeması (FlowNote için doldurulmuş §0/§1)
- [`index.md`](index.md) — sayfa kataloğu, kategoriye göre
- [`log.md`](log.md) — kronolojik kayıt (3 ingest + 1 schema notu + 1 synthesis filed-back)
- [`raw/`](raw/) — ham kaynaklar (PRD, meeting notes, incident report)
- `sources/`, `entities/`, `concepts/`, `decisions/`, `syntheses/` — ajan tarafından üretilmiş wiki

İlginç gezinti: önce `raw/decisions/auth-provider-eval.md`'yi oku, sonra `raw/incidents/2026-03-rate-limit.md`'yi, en sonunda `syntheses/auth-migration-postmortem.md`'yi — pattern'in **kararla bir hafta sonraki olayı bağlama** yeteneğini görürsün.

## Bu vault gerçek mi?

Hayır. Tamamen uydurulmuş. İsimler (FlowNote, Emir Yorgun, Jane Doe, John Doe), sayılar, tarihler kurgu. Pattern'i somut göstermek için tasarlandı. Gerçek vault'unu bu şablona benzer üretirsin.
