---
name: vault-sync
description: Projede yapılan değişikliği llm-wiki-mind vault'una sindir. Git log, commit mesajları ve diff'leri okur; etkilenen wiki sayfalarını (entities, concepts, decisions) günceller; raw/pr-discussions/ altına commit özet dosyası düşer. Proje-vault bağlantısı projenin CLAUDE.md'sinden okunur. Her commit, PR veya haftalık toplu senkron için kullanılır.
---

# vault-sync — kod değişikliklerini vault'a sindir

Tetiklendiğinde yapılacaklar:

## 1. Proje ve vault yolunu belirle

1. Çalışma dizininin (`pwd`) köküne bak — `CLAUDE.md` var mı?
2. Varsa `Vault (llm-wiki-mind)` bölümündeki vault yolunu oku.
3. Yoksa kullanıcıdan iki yolu sor (PROJECT_PATH, VAULT_PATH).
4. Vault yolunu doğrula: `<vault>/CLAUDE.md` ve `<vault>/index.md` mevcut olmalı.

## 2. Değişiklik aralığını belirle

**Varsayılan: otomatik tespit. Soru sorma.** Vault'un `log.md` dosyasından en son ingest edilen commit'i bul ve oradan `HEAD`'e kadar atılmamış olan tüm commit'leri sync'le.

```bash
LAST_HASH=$(grep -oE 'commit `[a-f0-9]+\.\.[a-f0-9]+`' "$VAULT_PATH/log.md" \
  | tail -1 \
  | sed -E 's/commit `[a-f0-9]+\.\.([a-f0-9]+)`/\1/')

cd "$PROJECT_PATH"
NEW_COUNT=$(git rev-list --count "$LAST_HASH..HEAD" 2>/dev/null || echo "?")
```

Sonra duruma göre:

- **Yeni commit var (`NEW_COUNT > 0`)** — Aralık otomatik olarak `$LAST_HASH..HEAD` belirlendi. Kullanıcıya kısa bir teyit yaz (örn. "Vault `<hash>`'e kadar güncel, oradan HEAD'e kadar N commit ingest edeceğim.") ve **direkt §3'e geç**. Soru sorma.
- **Yeni commit yok (`NEW_COUNT == 0`)** — "Vault zaten en son commit'e kadar güncel (`<hash>`). Sync'lenecek bir şey yok." mesajıyla durdur.
- **`log.md` parse edilemezse** (ilk ingest, format değişikliği vb.) — geri çekil ve AskUserQuestion ile sor:
  - **Son commit** (HEAD~1..HEAD): tek değişiklik.
  - **Belirli commit / aralık** (kullanıcı hash verir).
  - **Aktif branch'in divergence'ı** (main..HEAD): PR bütünü.
  - **Belirli tarih aralığı** (örn. "son 7 gün").

**Override:** Kullanıcı komutu çağırırken explicit bir aralık (örn. `/vault-sync HEAD~3..HEAD`) veya doğal dilde belirtirse ("son commit", "PR bütünü"), otomatik tespit yerine kullanıcının seçimi kullanılır.

## 3. Değişikliği topla

```bash
cd "$PROJECT_PATH"
git log --format="commit %H%n%an <%ae>%n%ad%n%n%B%n---" "$RANGE" > /tmp/vault-sync-log.txt
git diff --stat "$RANGE"
# Kritik dosyalar için tam diff:
git diff "$RANGE" -- <önemli-dosyalar>
```

Kısa özet dosyası hazırla: etkilenen klasörler, dokunulan dosya sayıları, commit mesajları, **ne değişti** kısa özet.

## 4. Raw'a düşür

`<vault>/raw/pr-discussions/YYYY-MM-DD-<short-hash>.md` oluştur. İçerikte:

```markdown
# <commit mesajının ilk satırı>

**Commit**: <full hash>
**Yazar**: <author>
**Tarih**: <date>
**Aralık**: <range>

## Özet
<commit body + kullanıcıyla konuşarak çıkarılan "neden" özeti>

## Etkilenen dosyalar
<git diff --stat çıktısı, markdown tablo>

## Önemli diff'ler
<seçilmiş hunks, code block içinde>
```

## 5. Ingest et

Vault'un `CLAUDE.md` §6 (INGEST workflow) adımlarını uygula:

1. Yeni raw dosyasını oku.
2. Anahtar çıkarımları kullanıcıyla konuş.
3. `sources/YYYY-MM-DD-<slug>.md` yaz.
4. Etkilenen entity/concept/decision sayfalarını güncelle. Dokunulan dosya yolu bir mevcut sayfayla eşleşiyorsa (örn. `lib/features/paywall/` → `entities/features/paywall.md`) o sayfaya yeni bilgi ekle, `updated:` tarihini güncelle, `sources:` listesine yeni source'u ekle.
5. Yeni feature / service eklendiyse yeni entity sayfası oluştur.
6. Önemli karar içeriyorsa `decisions/NNNN-<slug>.md` yaz.
7. Çelişki varsa `⚠ Çelişki` notu bırak — silme.
8. `index.md` güncelle.
9. `log.md`'ye append:
   ```
   ## [YYYY-MM-DD] ingest | commit <short-hash> → <N source + M entity/concept>
   ```

## 6. Özet dön

Kullanıcıya kısaca:
- Hangi sayfalar oluştu/güncellendi?
- Hangi açık sorular çıktı?
- Herhangi bir çelişki var mı?

## Hatırlatıcılar

- **Proje dizini ve `raw/` immutable** — sadece oku, yazma (raw'a script-üretimi dosya dışında).
- Vault şemasını izle — projenin kendi `CLAUDE.md`'si yerine **vault'un** `CLAUDE.md`'si authoritative.
- Commit büyük ve dağınıksa ingest'i parçala: önemli feature'ları ayrı source sayfalarına böl.

## Kullanım örnekleri

- "Az önce portföy split feature'ını ekledim, vault'u sync'le."
- "Bu hafta yaptığım 12 commit'i topluca ingest et."
- "PR #342'de ne değişti özet çıkar, ilgili entity'leri güncelle."
