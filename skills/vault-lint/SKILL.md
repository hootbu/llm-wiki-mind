---
name: vault-lint
description: llm-wiki-mind vault'unun sağlık kontrolü. Sayfalar arası çelişkileri, stale claim'leri, orphan sayfaları, broken link'leri, tek-yönlü referansları ve veri boşluklarını tespit eder; rapor üretir; otomatik düzeltilebilenleri kullanıcı onayıyla uygular; araştırmaya değer yeni sorular önerir. Vault büyürken sağlıklı kalması için periyodik çalıştırılır.
---

# vault-lint — vault sağlık kontrolü

Tetiklendiğinde yapılacaklar — vault'un `CLAUDE.md` §8'deki LINT workflow'unu uygular.

## 1. Vault'u bul

- `pwd` veya yakın bir `CLAUDE.md` işaretçisinden VAULT_PATH'i çıkar.
- Vault geçerli mi kontrol et: `CLAUDE.md`, `index.md`, `log.md` mevcut olmalı.

## 2. Yedi kontrol

### (1) Çelişki taraması
Tüm sayfalarda `⚠ Çelişki` notlarını ara. Her biri için:
- İki kaynağı listele.
- Mümkünse yeni bir raw ingest ile çözüm önerisi sun.
- Çözülmüşse `⚠` satırını kaldırıp normal bölüm olarak yaz (kullanıcı onayıyla).

### (2) Stale claim
`updated:` alanı 90 günden eski + `status: active` sayfaları listele. İlgili raw kaynaklar değişti mi kontrol et (örn. kod tabanı dosyaları). Öneri: re-ingest veya `status: stale` işaretle.

### (3) Orphan sayfalar
Hiçbir sayfadan link almayan sayfaları bul:
```bash
# pseudo: her sayfa için, başka sayfalarda [[slug]] geçiyor mu?
```
Öneri: link ekle (uygun yerde) veya `archive/` altına taşı.

### (4) Broken link
`[[linklenmiş]]` ama dosyası olmayan sayfaları bul. Her biri için:
- Stub oluştur (frontmatter + bir cümle "henüz ingest edilmedi" notu), veya
- Link'i kaldır (kullanıcı onayıyla).

### (5) Tek-yönlü referans
A sayfası B'ye link verirken B'de A geçmiyorsa, B'nin `## İlgili` bölümüne `[[A]]` ekle.

### (6) Veri boşlukları
"henüz ingest edilmedi", "burada açıklanacak", "*(doldurulacak)*" gibi placeholder'lar. Web araması veya raw ekleme önerisi.

### (7) Yeni soru önerileri
Wiki'deki kalıplara bakarak araştırmaya değer 3-5 yeni soru çıkar. Örn:
- "Aggregated Price Architecture'ın pratik etkisi nasıl ölçüldü?"
- "Adapty'den RevenueCat'a geçişin maliyet sonuçları ne oldu?"

## 3. Rapor

Tek bir markdown rapor olarak döndür:

```markdown
# Wiki Lint Raporu — YYYY-MM-DD

## Özet
- N çelişki
- M stale sayfa
- K orphan sayfa
- J broken link
- X tek-yönlü referans
- Y veri boşluğu

## Detay
<her kategori için liste + öneri>

## Otomatik düzeltilebilir
- [ ] <kullanıcı onayıyla uygulanacak değişiklik>
- [ ] ...

## Araştırmaya değer yeni sorular
1. ...
2. ...
```

## 4. Uygulama

Kullanıcı otomatik düzeltmeleri onaylarsa **tek tek** uygula (her dosya için diff göster, yazmadan önce).

## 5. Log

```markdown
## [YYYY-MM-DD] lint | N çelişki, M stale, K orphan, J broken → X düzeltildi
```

## Hatırlatıcılar

- **Sayfa silme yasak** — archive'a taşı.
- **Çelişki çözülmeden silinmez** — kaynak belirsizse `status: draft` yap, `⚠` notunu tut.
- Büyük vault'larda (>500 sayfa) kategori kategori ilerle; kullanıcıyı bunaltma.

## Kullanım örnekleri

- "Wiki sağlık kontrolü yap."
- "Son bir ayda yazdığım sayfalar arasında çelişki var mı?"
- "Orphan sayfaları listele ve ne yapacağımızı öner."
