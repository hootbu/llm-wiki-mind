# CLAUDE.md — Wiki Anayasası

Bu dosya vault'un **şemasıdır**. Claude her oturumda önce bu dosyayı okur, kurallara uyar. Vault sahibi bu dosyayı zamanla evriltir.

---

## 0. Hızlı kimlik

- **Vault yolu**: `examples/saas-project-demo` *(demo amaçlı; gerçek vault'unuzda absolute path olur)*
- **Referans proje / kaynak**: *(yok — bu demo bir kod tabanına bağlı değil; gerçek vault'unuzda burası `~/Projects/FlowNote` gibi olurdu)*
- **Alan**: Yazılım projesi (SaaS — collaborative note-taking)
- **Kimlik özeti**: FlowNote'un mimari kararları, prod incident'leri, harici servis seçimleri ve cross-cutting teknik kavramları için kurumsal hafıza.

---

## 1. Amaç

Bu wiki **FlowNote** SaaS'ı için kurumsal hafızayı tutar. Kod GitHub'da; wiki kaynakların **dışında kalan bilgiyi** biriktirir: neden bir karar verildi, hangi tradeoff'lar tartışıldı, bir incident'in kök nedeni neydi, harici servisin gerçek davranışı dökümantasyondan nasıl ayrılıyor.

Yanıt aradığımız örnek sorular:

- "Auth provider'ı niye Clerk seçtik, Auth0'da hangi sorunlar vardı?"
- "Offline sync için niye Y.js, niye OT değil?"
- "Mart 2026 rate limit incident'inin kök nedeni neydi?"
- "Realtime-sync servisinin token refresh stratejisi nasıl evrildi?"

---

## 2. Klasör yapısı

```
vault/
├── CLAUDE.md              # bu dosya — anayasa
├── index.md               # içerik kataloğu (kategoriye göre)
├── log.md                 # zamansal append-only kayıt
├── raw/                   # ham kaynaklar — DOKUNULMAZ, sadece kullanıcı ekler
│   ├── specs/             # PRD, technical specs
│   ├── decisions/         # meeting notes, RFC tartışmaları
│   └── incidents/         # incident report'ları, post-mortem ham notları
├── sources/               # her raw dosya için bir özet sayfası (1:1)
├── entities/              # somut şeyler
│   ├── services/          # backend servisleri
│   ├── features/          # ürün feature'ları
│   └── external-apis/     # harici vendor / servis entegrasyonları
├── concepts/              # cross-cutting teknik kavramlar
├── decisions/             # numaralı kararlar (ADR tarzı)
├── syntheses/             # üst düzey sentez sayfaları (query filed-back'leri)
└── archive/               # stale/hatalı sayfalar — silmek yerine buraya taşınır
```

---

## 3. Dosya adlandırma

- **Sayfa isimleri**: `kebab-case.md`. Yerel karakter kullanma (ş, ğ, ü ...).
- **Tarih**: `YYYY-MM-DD` (ISO 8601).
- **Source sayfaları**: `sources/YYYY-MM-DD-kisa-slug.md`.
- **Decision sayfaları**: `decisions/NNNN-slug.md` (0001'den başlar, silinmez).

---

## 4. Sayfa formatı

Her wiki sayfası (raw/ HARİÇ) şu frontmatter'ı taşır:

```yaml
---
type: source | entity | concept | decision | synthesis
subtype: <opsiyonel, alt kategori — service, feature, external-api, prd, incident, ...>
status: active | draft | stale | archived
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - sources/<ilgili-source>.md
tags: [tag1, tag2]
aliases: [Alternatif Ad]   # opsiyonel
---
```

**Gövde yapısı** (öneri):

1. Bir cümle özet.
2. Niye önemli (bu vault'a özel bağlam).
3. Detay bölümleri.
4. `## İlgili` — `[[wiki-link]]`lerle çapraz referans.
5. `## Açık sorular` (varsa).
6. `## Kaynaklar` — her iddianın bağlandığı raw / source dosyalar.

---

## 5. Linkleme

- **Wiki içi**: `[[concepts/eventual-consistency]]` veya kısa form `[[eventual-consistency]]`.
- **Raw'a**: göreli markdown link — `[başlık](raw/specs/offline-sync-spec.md)` — `[[]]` değil.
- **Harici**: normal markdown link.
- Sayfa güncellerken **ona link veren diğer sayfaları** mutlaka kontrol et (çift-yönlü tutarlılık).

---

## 6. INGEST workflow

Kullanıcı `raw/` altına yeni dosya ekleyip "ingest et" dediğinde:

1. **Oku** — ham dosyayı tam oku.
2. **Konuş** — anahtar çıkarımları bullet listesi olarak sun, kullanıcıya onay/düzeltme sor.
3. **Source sayfası yaz** — `sources/YYYY-MM-DD-slug.md`.
4. **Entity/concept sayfalarını güncelle** — yoksa oluştur, varsa ilgili bölüme ekle.
5. **Decision çıkarımı** — kaynak bir karar içeriyorsa `decisions/NNNN-slug.md` yaz.
6. **Çelişki kontrolü** — mevcut sayfayla çeliştiğinde **silme**: `> ⚠ Çelişki: [[a]] X derken [[b]] Y diyor.` notu bırak.
7. **index.md güncelle**.
8. **log.md'ye append** — `## [YYYY-MM-DD] ingest | <raw> → <özet>`.
9. **Özet dön** — kullanıcıya: ne değişti, ne açık kaldı.

---

## 7. QUERY workflow

Kullanıcı wiki'ye soru sorduğunda:

1. `index.md`'yi tara, ilgili kategorileri aç.
2. İlgili sayfaları oku.
3. Sentez üret. Her iddianın yanına `([[source]])` referansı koy.
4. **Filed-back değerlendirmesi** — cevap yeni karşılaştırma içeriyorsa, mevcut sayfalarda olmayan yeni sentez ürettiyse, tekrar sorulma ihtimali varsa → `syntheses/` altına atomic sayfa.
5. `index.md` + `log.md` güncelle (yeni sayfa varsa).

---

## 8. LINT workflow

Kullanıcı "wiki lint" / "sağlık kontrolü" dediğinde §10'daki kurallara göre 7 kontrol çalıştır (çelişki, stale, orphan, broken link, tek-yönlü ref, veri boşluğu, yeni soru önerileri). Rapor + otomatik düzeltilebilir listesi.

---

## 9. Referans kaynak (varsa)

Bu demo vault'un referans projesi yok. Gerçek bir FlowNote vault'u olsa kod tabanı `~/Projects/FlowNote`'ta olurdu ve şu kurallar geçerli olurdu:

- Referans proje **immutable**.
- Dosya yolu + sembol ile refere et: `src/services/auth/refresh.ts:scheduleRefresh`.
- Wiki kodu ayna tutmaz; sadece **kod dışı** bilgiyi (neden/kim/ne zaman) tutar.

---

## 10. Yasaklar (hard rules)

1. **`raw/` immutable.** Sadece kullanıcı ekler.
2. **Referans proje dizini immutable** (varsa).
3. **Kaynaksız iddia yok.** Her önemli cümlede `([[source]])`.
4. **Çelişki silinmez, işaretlenir.**
5. **Sayfa silinmez, archive'a taşınır.**
6. **Frontmatter zorunlu** (raw/ hariç).
7. **Yerel karakter yok** dosya adında.
8. **Placeholder bırakma.** Bilgi eksikse "Açık sorular"a yaz.
9. **Gizli veri wiki'ye kopyalanmaz.** API anahtarları, kişisel veriler maskeli.
10. **Operasyonel işaret dışında emoji yok** — `⚠` (çelişki), `📎` (filed-back) sadece.

---

## 11. Şema evrimi

Bu dosya statik değil. Kural çalışmıyorsa öneri sun, onay alırsan güncelle. `log.md`'ye `## [YYYY-MM-DD] schema | <ne değişti>` ekle.
