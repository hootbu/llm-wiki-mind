# CLAUDE.md — Wiki Anayasası

Bu dosya vault'un **şemasıdır**. Claude her oturumda önce bu dosyayı okur, kurallara uyar. Vault sahibi bu dosyayı zamanla evriltir.

---

## 0. Hızlı kimlik

<!-- vault-init bu alanı doldurur. Manuel düzenleyeceksen örnek: -->
- **Vault yolu**: `<VAULT_PATH>`
- **Referans proje / kaynak** *(varsa)*: `<PROJECT_PATH>` — sadece okuma.
- **Alan**: *(yazılım projesi / araştırma / kitap okuma / kişisel günlük / takım bilgisi / rakip analizi / ...)* — ilk oturumda doldur.
- **Kimlik özeti**: *(bir cümle ile: bu wiki neyi biriktiriyor?)*

---

## 1. Amaç

*(İlk oturumda doldur.)*

Bu wiki **\<alan\>** konusunda kurumsal/kişisel hafızayı tutar. Kaynak ne ise orada kalır — wiki kaynakların **dışında kalan bilgiyi** biriktirir: sentez, karşılaştırma, karar, çelişki, açık soru, zaman içi değişim.

Yanıt aradığımız örnek sorular:

- *(örnek 1 — alanına özgü)*
- *(örnek 2)*
- *(örnek 3)*

---

## 2. Klasör yapısı

```
vault/
├── CLAUDE.md              # bu dosya — anayasa
├── index.md               # içerik kataloğu (kategoriye göre)
├── log.md                 # zamansal append-only kayıt
├── raw/                   # ham kaynaklar — DOKUNULMAZ, sadece kullanıcı ekler
├── sources/               # her raw dosya için bir özet sayfası (1:1)
├── entities/              # somut şeyler (kişi, organizasyon, araç, ürün, bölüm, karakter, ...)
├── concepts/              # soyut kavramlar ve terimler
├── decisions/             # numaralı kararlar (ADR tarzı)
├── syntheses/             # üst düzey sentez sayfaları (query filed-back'leri)
└── archive/               # stale/hatalı sayfalar — silmek yerine buraya taşınır
```

### Alt klasörler alanına göre oluşur

Template boş başlar. İlk ingest sırasında uygun alt klasörleri **kendin** açarsın:

- **Yazılım projesi**: `entities/services/`, `entities/features/`, `entities/models/`, `entities/external-apis/`
- **Araştırma**: `entities/people/`, `entities/papers/`, `entities/methods/`, `entities/experiments/`
- **Kitap okuma**: `entities/characters/`, `entities/places/`, `entities/themes/`, `entities/quotes/`
- **Kişisel günlük**: `entities/people/`, `entities/themes/`, `entities/routines/`, `entities/goals/`
- **Takım bilgisi**: `entities/people/`, `entities/teams/`, `entities/rituals/`, `entities/tools/`

Raw alt klasörleri de aynı mantıkla: `raw/specs/`, `raw/meetings/`, `raw/chapters/`, `raw/interviews/`, `raw/papers/`, vb.

---

## 3. Dosya adlandırma

- **Sayfa isimleri**: `kebab-case.md`. Yerel karakter kullanma (ş, ğ, ü, é, ñ ...).
- **Tarih**: `YYYY-MM-DD` (ISO 8601). Asla `13/04/2026` yazma.
- **Source sayfaları**: `sources/YYYY-MM-DD-kisa-slug.md`.
- **Decision sayfaları**: `decisions/NNNN-slug.md` numaralı (0001'den başlar, artar, silinmez).

---

## 4. Sayfa formatı

Her wiki sayfası (raw/ HARİÇ) şu frontmatter'ı taşır:

```yaml
---
type: source | entity | concept | decision | synthesis
subtype: <opsiyonel, alt kategori>
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
2. Neden önemli (bu vault'a özel bağlam).
3. Detay bölümleri.
4. `## İlgili` — `[[wiki-link]]`lerle çapraz referans.
5. `## Açık sorular` (varsa).
6. `## Kaynaklar` — her iddianın bağlandığı raw dosyalar.

---

## 5. Linkleme

- **Wiki içi**: `[[concepts/aggregated-price]]` veya kısa form `[[aggregated-price]]`.
- **Raw'a**: göreli markdown link — `[başlık](raw/specs/master-plan.md)` — `[[]]` değil.
- **Harici**: normal markdown link.
- Sayfa güncellerken **ona link veren diğer sayfaları** mutlaka kontrol et (çift-yönlü tutarlılık).

---

## 6. INGEST workflow

Kullanıcı `raw/` altına yeni dosya ekleyip "ingest et" dediğinde:

1. **Oku** — ham dosyayı tam oku.
2. **Konuş** — anahtar çıkarımları bullet listesi olarak sun, kullanıcıya onay/düzeltme sor.
3. **Source sayfası yaz** — `sources/YYYY-MM-DD-slug.md`: tek cümle özet, 5-10 madde anahtar nokta, her maddeye raw referansı, "## İlgili" bölümü.
4. **Entity/concept sayfalarını güncelle** — yoksa oluştur, varsa ilgili bölüme ekle. `sources:` frontmatter listesine yeni source'u ekle. `updated:` tarihini güncelle.
5. **Decision çıkarımı** — kaynak bir karar içeriyorsa `decisions/NNNN-slug.md` yaz.
6. **Çelişki kontrolü** — mevcut sayfayla çeliştiğinde **silme**: `> ⚠ Çelişki: [[source-a]] X derken [[source-b]] Y diyor. Çözüm: [açık/kararsız]` notu bırak.
7. **index.md güncelle** — yeni sayfaları ekle, değişenlerin özetini güncelle.
8. **log.md'ye append** — `## [YYYY-MM-DD] ingest | <raw dosya> → <özet>`.
9. **Özet dön** — kullanıcıya: ne değişti, ne açık kaldı.

---

## 7. QUERY workflow

Kullanıcı wiki'ye soru sorduğunda:

1. `index.md`'yi oku, ilgili kategorileri tara.
2. İlgili sayfaları aç (frontmatter + gövde).
3. Sentez üret. Her iddianın yanına `([[source-page]])` referansı koy.
4. **Filed-back değerlendirmesi** — cevap:
   - Yeni karşılaştırma içeriyor,
   - Mevcut sayfalarda olmayan yeni sentez üretti,
   - Tekrar sorulma ihtimali var
   → `syntheses/` altına **atomic** bir sayfa yaz. Cevabın içine "📎 Wiki'ye eklendi: [[page]]" notu düş.
5. Büyük "session özeti" değil, **her ayrık fikir kendi sayfasına**.
6. `index.md` güncelle (yeni sayfa varsa).
7. `log.md` append — sadece filed-back olan query'ler: `## [YYYY-MM-DD] query | "<soru>" → filed: [[page]]`.

Sıradan soru-cevaplar (cevap zaten sayfada) log'lanmaz.

---

## 8. LINT workflow

Kullanıcı "wiki lint" / "sağlık kontrolü" dediğinde:

1. **Çelişki taraması** — sayfalardaki `⚠ Çelişki` notları → çözüm önerisi.
2. **Stale claim** — `updated:` > 90 gün olan `active` sayfalar.
3. **Orphan** — hiç link almayan sayfalar → link öner veya archive'a taşıma öner.
4. **Broken link** — `[[linklenmiş]]` ama dosyası olmayan sayfalar → stub oluştur veya kaldır.
5. **Tek-yönlü referans** — A → B link verirken B'de A yoksa, B'ye "## İlgili" ekle.
6. **Veri boşlukları** — "burada açıklanacak" placeholder'lar → web araması / raw ekleme öner.
7. **Yeni soru önerileri** — wiki'deki kalıplara bakarak araştırmaya değer 3-5 yeni soru.
8. **Rapor** + otomatik düzeltilebilir listesi (kullanıcı onayı sonrası uygula).
9. `log.md` append: `## [YYYY-MM-DD] lint | N stale, M orphan, K çelişki, J broken`.

---

## 9. Referans kaynak (varsa)

Vault bir koda/proje dizinine (`<PROJECT_PATH>`) bağlıysa:

- Referans proje **immutable** — oraya asla yazma.
- Dosya yolu + sembol ile refere et: `src/module/file.ext:symbol`.
- Kod sayfalarını wiki'de **ayna tutma** — authoritative olan kod. Wiki sadece **kod dışı** bilgiyi (neden/kim/ne zaman) tutar.
- Bir entity sayfası bir kod sembolünü açıklıyorsa, frontmatter'a `source_path: <PROJECT_PATH>/...` alanı ekle.

---

## 10. Yasaklar (hard rules)

1. **`raw/` immutable.** Oraya yazma, silme, taşıma. Sadece kullanıcı ekler.
2. **Referans proje dizini immutable** (varsa).
3. **Kaynaksız iddia yok.** Her önemli cümlede `([[source]])`.
4. **Çelişki silinmez, işaretlenir.** `⚠ Çelişki` notu.
5. **Sayfa silinmez, archive'a taşınır.** `archive/YYYY-MM-DD-eski-slug.md`. `index.md` güncellenir.
6. **Frontmatter zorunlu** (raw/ hariç).
7. **Yerel karakter yok** dosya adında. Gövdede serbest.
8. **Placeholder bırakma** (`TODO: doldur`). Bilgi eksikse "Açık sorular"a yaz.
9. **Gizli veri wiki'ye kopyalanmaz** — API anahtarları, kişisel veriler maskeli (`***masked***`) veya raw'a referansla.
10. **Operasyonel işaret dışında emoji yok** — `⚠` (çelişki), `📎` (filed-back) sadece.

---

## 11. Şema evrimi

Bu dosya statik değil:

1. Kural çalışmıyorsa öneri sun.
2. Onay alırsan bu dosyayı güncelle.
3. `log.md`'ye `## [YYYY-MM-DD] schema | <ne değişti>` ekle.
4. Yeni kural sonraki oturumdan itibaren geçerli — **geriye dönük uygulamazsın** (lint ile yavaş uyarlanır).

---

## 12. İlk oturum checklist

Bu template'ten yeni vault kurduğunda, ilk oturumda:

- [ ] §0'ı doldur (alan, kimlik).
- [ ] §1'i doldur (amaç, örnek sorular).
- [ ] `index.md`'ye wiki'nin ilk kategorilerini ekle.
- [ ] `log.md`'nin ilk girişini kontrol et.
- [ ] İlk kaynağı `raw/<uygun-alt-klasör>/` altına koy, "ingest et" de.
