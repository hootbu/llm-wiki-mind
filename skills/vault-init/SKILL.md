---
name: vault-init
description: Mevcut bir projeye llm-wiki-mind pattern'ına göre yeni bir Obsidian bilgi arşivi (vault) kur ve projeye bağla. Kullanıcıdan proje yolu ve vault yolunu alır, GitHub'daki Hootbu/llm-wiki-mind template'ini kullanarak kurar, projenin CLAUDE.md'sine vault işaretçisi ekler. Proje yolu olmadan (salt-vault) da kurulabilir. Yazılım, araştırma, kitap okuma, kişisel günlük gibi her alan için kullanılır.
---

# vault-init — llm-wiki-mind vault kurucu

Tetiklendiğinde yapılacaklar:

## 1. Parametreleri al

Kullanıcıdan iki yol iste (varsa AskUserQuestion ile):

1. **PROJECT_PATH** — referans proje/kod dizini (opsiyonel; kullanıcı "yok" derse `-` geç).
2. **VAULT_PATH** — kurulacak vault'un hedef yolu. Varsayılan öneri: `~/Desktop/<ProjeAdı>-Mind/<ProjeAdı>` ama kullanıcı kendisi söyler.

Her iki yolu da **mutlak** yapıp onaylat. Vault yolunun üst dizini mevcut olmasa bile script oluşturur.

## 2. Script'i çalıştır

llm-wiki-mind repo'su daha önce indirildiyse `--local` ile, indirilmediyse default GitHub clone ile:

```bash
# Eğer ~/Desktop/llm-wiki-mind varsa local mod:
bash ~/Desktop/llm-wiki-mind/scripts/init-vault.sh "$PROJECT_PATH" "$VAULT_PATH" --local ~/Desktop/llm-wiki-mind

# Yoksa GitHub'dan çekerek:
bash <(curl -fsSL https://raw.githubusercontent.com/Hootbu/llm-wiki-mind/main/scripts/init-vault.sh) "$PROJECT_PATH" "$VAULT_PATH"
```

Script etkileşimli — proje CLAUDE.md'si için git davranışını (commit / gitignore / atla) sorar. Kullanıcının terminal'de soruyu görmesi için script'i **foreground'da** çalıştır, `--yes` geçme.

## 3. Kurulum sonrası

Script biter bitmez:

1. Vault'un `CLAUDE.md` dosyasını aç; **§0 Hızlı kimlik** ve **§1 Amaç** bölümlerini kullanıcıyla birlikte doldur (alan, örnek sorular). Claude bunu kendi başına yapmaz — kullanıcıya 2-3 soru sor (alan türü, amaç cümlesi, ilk örnek sorular).
2. `index.md`'nin ilk kategorilerini alana göre özelleştir (örn. yazılım projesi için: Services / Features / Models başlıkları).
3. Kullanıcıya sonraki adımları özetle:
   - Obsidian'da vault'u aç.
   - İlk kaynağı `raw/` altına koy.
   - "ingest et" komutunu dene.

## 4. Hatırlatıcılar

- Kullanıcı PROJECT_PATH'i olmayan saf araştırma/kitap vault'u istiyorsa `-` kabul et.
- Vault zaten varsa script fail eder — kullanıcıya manuel silme ya da farklı yol önerisi sun.
- Script çalıştırma başarısız olursa (`gh`, `git` eksikliği vb.) kullanıcıya somut hatayı ve çözümü söyle.

## Kullanım örnekleri

- "PortfoyGPT Flutter projem var, vault'u `~/Desktop/PortfoyGPT-Mind/PortfoyGPT/` altına kur."
- "Araştırma tezim için vault aç, proje yolu yok, vault'u `~/Thesis-Mind/` altına."
- "Yeni başladığım kitap kulübü için vault kur."
