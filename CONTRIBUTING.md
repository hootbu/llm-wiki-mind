# Katkı Rehberi

Bu repo bir pattern arşivi: starter template + Claude Code skill'leri + örnek vault'lar. Amaç, `llm-wiki-mind` yaklaşımını farklı alanlara (yazılım, araştırma, kitap, günlük) taşımayı kolaylaştırmak. Yeni preset, skill iyileştirmesi, dokümantasyon — her tür katkı çok aranıyor. Aşağıdaki bölümler nasıl başlayacağını özetler.

## 1. Bug ya da öneri

GitHub Issues üzerinden aç.
- **Bug:** reproduction adımı, beklenen davranış, gerçekleşen davranış, ortam bilgisi (macOS/Linux, bash sürümü).
- **Öneri:** somut bir use case örneği ekle — "şu durumda şunu yapmak istiyorum, şu an mümkün değil/zor".

## 2. Yeni skill önerme

- Konum: `skills/<name>/SKILL.md`.
- Frontmatter zorunlu: `name`, `description`.
- `description` tetikleme cümleleri içermeli (Claude Code skill'i çağırırken bu cümleleri match'liyor) — kullanıcı ne derse skill devreye girsin, onu yaz.
- Sonda kısa kullanım örnekleri (1–3 satır).

## 3. Yeni preset ekleme

- Konum: `presets/<name>.md` (repo root, `template/` dışında — vault'a kopyalanmaz, sadece kurulum sırasında okunur).
- Format: mevcut preset'lere bak — `CLAUDE_SECTION_0`, `CLAUDE_SECTION_1`, `INDEX_CATEGORIES`, `RAW_SUBDIRS` bölümleri olmalı.
- Test:
  ```bash
  bash scripts/init-vault.sh - /tmp/test-vault --local . --preset <name> --yes
  ```
  Hatasız çalışmalı, üretilen `CLAUDE.md` ve `index.md` doğru kategorilerle gelmeli.
- README'nin "Kullanım alanları" bölümüne tek satırlık özet ekle.

## 4. Bash kod stili

- `set -euo pipefail` zorunlu.
- shellcheck temiz olmalı (CI'da `severity: warning` ile kontrol ediliyor).
- macOS + Linux uyumlu yaz: `sed -i` farkı (BSD vs GNU), `mktemp -d` portatif kullanımı.
- Mevcut helper fonksiyonlarla tutarlı kal: `info`, `die`, `ask`. Yeni helper eklemeden önce mevcut script'e bak.

## 5. Commit mesajları

[Conventional Commits](https://www.conventionalcommits.org/) kullan:

- `feat(skill): yeni preset desteği`
- `fix(init): macOS sed uyumluluğu`
- `docs(readme): FAQ bölümü`
- `chore(ci): shellcheck workflow`

## 6. Pull Request

- **Açıklama:** kısa — ne değişti, niye.
- **Test plan:** nasıl test ettin (örnek script çağrısı, manuel adım, smoke test).
- README ya da CHANGELOG güncellemesi gerekiyorsa aynı PR içine al.
