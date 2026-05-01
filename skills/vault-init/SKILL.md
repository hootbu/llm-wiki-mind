---
name: vault-init
description: Mevcut bir projeye llm-wiki-mind pattern'ına göre yeni bir Obsidian bilgi arşivi (vault) kur ve projeye bağla. Kullanıcıdan proje yolu ve vault yolunu alır, GitHub'daki Hootbu/llm-wiki-mind template'ini kullanarak kurar, projenin CLAUDE.md'sine vault işaretçisi ekler. Proje yolu olmadan (salt-vault) da kurulabilir. Yazılım, araştırma, kitap okuma, kişisel günlük gibi her alan için kullanılır.
---

# vault-init — llm-wiki-mind vault kurucu

Tetiklendiğinde yapılacaklar:

## 1. Parametreleri al

Kullanıcıdan üç parametre iste (varsa AskUserQuestion ile):

1. **PROJECT_PATH** — referans proje/kod dizini (opsiyonel; kullanıcı "yok" derse `-` geç).
2. **VAULT_PATH** — kurulacak vault'un hedef yolu. Varsayılan öneri: `~/Desktop/<ProjeAdı>-Mind/<ProjeAdı>` ama kullanıcı kendisi söyler.
3. **PRESET** — alan tipi: `software`, `research`, `book-reading`, `journal`, ya da boş (manuel doldurma). Kullanıcının amacından (yazılım projesi mi, tez mi, kitap mı, günlük mü) çıkarsa öner ve onaylat. Net değilse boş geç — §0/§1 sonradan elle doldurulur.

İki yolu da **mutlak** yapıp onaylat. Vault yolunun üst dizini mevcut olmasa bile script oluşturur.

## 2. Script'i çalıştır

llm-wiki-mind repo'su daha önce indirildiyse `--local` ile, indirilmediyse default GitHub clone ile. Preset varsa `--preset` flag'ini ekle:

```bash
# Local + preset:
bash ~/Desktop/llm-wiki-mind/scripts/init-vault.sh "$PROJECT_PATH" "$VAULT_PATH" --local ~/Desktop/llm-wiki-mind --preset software

# Local, preset yok (manuel doldurulacak):
bash ~/Desktop/llm-wiki-mind/scripts/init-vault.sh "$PROJECT_PATH" "$VAULT_PATH" --local ~/Desktop/llm-wiki-mind

# GitHub'dan çekerek + preset:
bash <(curl -fsSL https://raw.githubusercontent.com/Hootbu/llm-wiki-mind/main/scripts/init-vault.sh) "$PROJECT_PATH" "$VAULT_PATH" --preset research
```

Script etkileşimli — proje CLAUDE.md'si için git davranışını (commit / gitignore / atla) sorar. Kullanıcının terminal'de soruyu görmesi için script'i **foreground'da** çalıştır, `--yes` geçme.

## 3. Kurulum sonrası

Script biter bitmez:

1. **Preset uygulandıysa**: §0 Hızlı kimlik ve §1 Amaç bölümleri ile `index.md` kategorileri ve `raw/` alt klasörleri otomatik dolmuştur. Kullanıcıya doldurulmuş §0/§1'i göster, gerekirse alana özel inceltmeleri (kimlik özeti cümlesini projeye özelleştirme, örnek soruları somutlaştırma) birlikte yap.
2. **Preset uygulanmadıysa**: `CLAUDE.md` §0 ve §1'i kullanıcıyla birlikte doldur — 2-3 soru sor (alan türü, amaç cümlesi, ilk örnek sorular). `index.md`'nin ilk kategorilerini alana göre özelleştir.
3. Kullanıcıya sonraki adımları özetle:
   - Obsidian'da vault'u aç.
   - İlk kaynağı `raw/<alt-klasör>/` altına koy.
   - "ingest et" komutunu dene.

## 4. Hatırlatıcılar

- Kullanıcı PROJECT_PATH'i olmayan saf araştırma/kitap vault'u istiyorsa `-` kabul et.
- Vault zaten varsa script fail eder — kullanıcıya manuel silme ya da farklı yol önerisi sun.
- Script çalıştırma başarısız olursa (`gh`, `git` eksikliği vb.) kullanıcıya somut hatayı ve çözümü söyle.

## Kullanım örnekleri

- "PortfoyGPT Flutter projem var, vault'u `~/Desktop/PortfoyGPT-Mind/PortfoyGPT/` altına kur." → `--preset software`
- "Araştırma tezim için vault aç, proje yolu yok, vault'u `~/Thesis-Mind/` altına." → `--preset research`
- "Yeni başladığım kitap kulübü için vault kur." → `--preset book-reading`
- "Kişisel günlük tutmak istiyorum, vault'u `~/Journal-Mind/` altına." → `--preset journal`
- "Vault kur ama §0/§1'i kendim dolduracağım." → preset yok, eski davranış
