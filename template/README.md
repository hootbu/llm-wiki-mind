# Vault

Bu vault llm-wiki-mind pattern'ına göre kurulmuştur. LLM ajanı (Claude) bakımını yapar, sen kaynak eklersin ve sorular sorarsın.

## Akış

1. **Kaynak ekle** — `raw/` altındaki uygun alt klasöre markdown/PDF/resim bırak.
2. **Ingest et** — Claude'a "şu dosyayı ingest et" de. `CLAUDE.md`'deki workflow'a göre `sources/`, `entities/`, `concepts/` güncellenir.
3. **Soru sor** — Claude `index.md`'yi tarar, ilgili sayfaları okur, sentez üretir. Değerli cevaplar `syntheses/` altına filed-back olur.
4. **Lint et** — Arada bir "wiki sağlık kontrolü yap" de. Çelişki, stale, orphan, broken link taraması.

## Giriş noktaları

- [[CLAUDE.md]] — şema, kurallar, workflow (her oturumda önce bu okunur)
- [[index.md]] — tüm sayfaların kataloğu
- [[log.md]] — zamansal kayıt

## Hatırlatıcılar (hard rules)

- `raw/` **immutable** — sadece sen eklersin, ajan yazmaz.
- Kaynaksız iddia yok. Çelişki silinmez, işaretlenir. Sayfa silinmez, archive'a taşınır.
- Detay: [[CLAUDE.md]] §10.
