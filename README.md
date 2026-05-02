# llm-wiki-mind

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Built for Claude Code](https://img.shields.io/badge/Built%20for-Claude%20Code-D97757)](https://claude.com/claude-code)
[![Obsidian compatible](https://img.shields.io/badge/Obsidian-compatible-7c3aed)](https://obsidian.md)

**English** · [Türkçe](#türkçe)

> A **starter template + init script + Claude Code skills** for a persistent, cumulative Obsidian knowledge vault that an LLM agent continuously builds.

You find the sources; Claude does the bookkeeping: summaries, cross-references, contradiction flagging, synthesis. The wiki grows over time, and every new question is met with a richer layer of knowledge.

**Role split**

| You | Claude |
|---|---|
| Find sources (drop in `raw/`) | Reads, summarizes, files |
| Decide what to ask | Maintains cross-references |
| Drive the analysis | Flags contradictions |
| Read results, think critically | Does the bookkeeping |
| Evolve the schema | Follows the schema |

**Obsidian = IDE, LLM = programmer, wiki = codebase.**

---

![Demo vault overview](docs/screenshots/obsidian-graph-and-overview.png)
*FlowNote demo vault — Graph view and overview README, in Obsidian.*

![Demo vault — meeting raw + graph](docs/screenshots/obsidian-graph-and-meeting.png)
*Same vault — auth provider eval meeting (raw) and graph view side by side.*

---

## Quick start

### Option A — via Claude Code skill (recommended)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Hootbu/llm-wiki-mind/main/scripts/install-skills.sh)
```

Installs the skills under `~/.claude/skills/` in one shot; backs up any existing skill with the same name.

Then in any Claude Code session:

```
/vault-init
```

Claude will ask for the project path and vault path, then handle the rest.

### Option B — script directly

```bash
curl -fsSL https://raw.githubusercontent.com/Hootbu/llm-wiki-mind/main/scripts/init-vault.sh \
  -o /tmp/init-vault.sh && chmod +x /tmp/init-vault.sh
/tmp/init-vault.sh ~/Projects/MyApp ~/Desktop/MyApp-Mind/MyApp
```

Two arguments:
1. **PROJECT_PATH** — reference project directory (use `-` if none)
2. **VAULT_PATH** — where the vault will live

The script asks questions as it goes: should the project root `CLAUDE.md` pointer be committed, gitignored, or skipped?

Offline / local template:
```bash
./init-vault.sh <proj> <vault> --local ~/Desktop/llm-wiki-mind
```

**Pick the domain up front with a preset** — CLAUDE.md §0/§1, `index.md` categories, and `raw/` subfolders are auto-populated:
```bash
./init-vault.sh <proj> <vault> --preset software
```
Available presets: `software`, `research`, `book-reading`, `journal`. To add new ones, see the `presets/` folder.

---

## What do the skills do?

### `/vault-init` — set up a new vault

Creates a vault for a new project (or a pure knowledge area — book reading, research, journal). Asks for the project path and vault path, pulls the template from GitHub, places it, updates paths in `CLAUDE.md`, and adds a **vault pointer** to the project's root `CLAUDE.md` (so Claude recognizes the vault in every session for that project).

### `/vault-sync` — digest changes into the vault

Made some commits? This skill reads `git log` + `git diff`, drops a commit summary under `raw/pr-discussions/`, and runs the vault's ingest workflow:

- Updates affected entity/feature/service pages.
- Creates a new entity page if a new feature was added.
- Important decisions get filed as `decisions/NNNN-*.md`.
- If a contradiction surfaces it isn't deleted — a `⚠ Contradiction` note is left.
- `index.md` and `log.md` stay synchronized.

Range is flexible: last commit, a specific hash, a date range, or an entire PR (`main..HEAD`).

### `/vault-lint` — health check

Wikis decay as they grow. This skill scans for:

- **Contradictions** — `⚠ Contradiction` notes, with resolution suggestions.
- **Stale claims** — `active` pages not updated in 90+ days; re-ingest suggestion.
- **Orphan pages** — pages with no incoming links; add a link or move to archive.
- **Broken links** — `[[linked]]` targets without files; create a stub or remove.
- **One-way references** — A→B exists but B→A doesn't; add a `## Related` section.
- **Data gaps** — placeholders; suggest a web search / raw addition.
- **New question suggestions** — 3–5 research-worthy questions inferred from patterns in the wiki.

Output: a single markdown report + auto-fixable changes applied with user approval.

---

## How does the vault work? (short pattern summary)

### Three layers

1. **`raw/`** — raw sources. **Immutable** (only you add; the agent never writes here).
2. **Wiki** (vault root) — `sources/`, `entities/`, `concepts/`, `decisions/`, `syntheses/`. Fully managed by the LLM.
3. **`CLAUDE.md`** — schema / constitution. First file read every session; defines folder structure, naming, workflows, prohibitions. You and the agent evolve it over time.

### Three operations

- **INGEST** — drop a new source under `raw/`, say "ingest it." The agent: reads → writes a source summary → updates entity/concept pages → flags contradictions if any → updates `index.md` + `log.md`.
- **QUERY** — ask a question. The agent: scans `index.md` → opens relevant pages → produces a synthesis → **files back** valuable answers under `syntheses/` as atomic pages.
- **LINT** — periodic health check (above).

### Why does it work?

The hard part of wiki maintenance isn't thinking — it's **bookkeeping**. Cross-references, stale summaries, contradiction-catching, consistency across dozens of pages. The LLM doesn't get bored, doesn't forget, can touch 15 files in one pass. **The wiki stays maintained because maintenance cost is nearly zero.**

---

## Examples

To see what the pattern looks like in a concrete vault:

- [`examples/saas-project-demo/`](examples/saas-project-demo/) — a fictional SaaS project (FlowNote). Three raw inputs (PRD, auth provider eval meeting, prod incident report) and the full wiki that emerges from them: 4 entities, 1 concept, 2 decisions, 1 synthesis. Story: an auth migration decision + a rate limit incident one week later → a filed-back postmortem connecting the two. The most concrete view of the pattern for software engineers.

Try reading `examples/saas-project-demo/raw/decisions/auth-provider-eval.md` first → then `raw/incidents/2026-03-rate-limit.md` → finally `syntheses/auth-migration-postmortem.md`; you'll see the pattern's ability to **connect a decision to an event a week later.**

---

## A typical day

Working with a vault settles into a daily rhythm. Example week:

- **Monday** — You drop a new meeting transcript under `raw/meetings/`. You say `/vault-sync`. Claude reads the transcript, writes a summary under `sources/`, updates the relevant entity/concept pages, flags any contradictions.
- **Wednesday** — You made a few commits in the project. You say `/vault-sync`. The skill auto-detects the last ingested commit from `log.md` and ingests new commits between; affected entity pages are updated, a new decision file is opened under `decisions/` if needed.
- **Friday** — You ask a question ("what did the rate limit incident teach us after the auth migration?"). Claude scans `index.md`, reads the relevant decision + incident pages, returns a synthesis; valuable ones get filed back under `syntheses/`.
- **End of month** — You run a health check with `/vault-lint`: contradictions, stale claims, orphan pages, broken links. Report + auto-fixes with your approval.

You produce sources and questions; the bookkeeping takes care of itself in the background.

---

## Use cases

- **Software projects**: architectural decisions, sprint plans, meetings, PR discussions, incidents, external service behavior, cost/performance analyses.
- **Research**: papers, theories, methodology notes, experiment logs, an evolving thesis.
- **Book reading**: file chapter by chapter — characters, themes, connections. A personal Gateway.
- **Personal development / journal**: goals, health, reading notes, a structured picture of yourself.
- **Team knowledge**: Slack threads, meeting transcripts, customer interviews. The bookkeeping no one wants to do.
- **Competitive analysis, due diligence, course notes, hobby research** — anything you want to accumulate knowledge about over time.

---

## Repo structure

```
llm-wiki-mind/
├── README.md                    # this file
├── LICENSE                      # MIT
├── template/                    # /vault-init copies this
│   ├── CLAUDE.md                # schema (constitution) — <VAULT_PATH>/<PROJECT_PATH> placeholders
│   ├── README.md                # vault's own README
│   ├── index.md                 # category skeleton
│   ├── log.md                   # temporal-log skeleton
│   ├── raw/                     # (empty, .gitkeep)
│   ├── sources/
│   ├── entities/
│   ├── concepts/
│   ├── decisions/
│   ├── syntheses/
│   └── archive/
├── examples/                    # concrete, populated example vaults
│   └── saas-project-demo/       # fictional SaaS project — 17 files, full story
├── scripts/
│   └── init-vault.sh            # bash installer
└── skills/
    ├── vault-init/SKILL.md
    ├── vault-sync/SKILL.md
    └── vault-lint/SKILL.md
```

---

## Acknowledgments

This project draws inspiration from the `llm-wiki` SKILL.md pattern by **Selma Akçebay** in [selmakcby/knowledge-pipeline](https://github.com/selmakcby/knowledge-pipeline). The pattern itself is originally hers; this repo packages it as a Turkish-language, Obsidian-focused "starter + skill" bundle.

In spirit, the pattern is close to Vannevar Bush's 1945 **Memex** vision — a personal, actively curated knowledge store with associative trails between documents. The one thing Bush couldn't solve was who would do the maintenance. The LLM handles that part.

Setup and documentation help: Claude (Anthropic).

---

## FAQ

**Why this instead of Notion / Logseq / Tana?**
Those are editors — you write the page, you make the link. This pattern centers LLM-bookkeeping: markdown stays raw and portable while Claude handles cross-referencing/summarizing/contradiction maintenance. It's a flow, not a tool.

**Is Claude Code required? Will GPT / Cursor / another model work?**
The skills (`/vault-init`, `/vault-sync`, `/vault-lint`) are Claude Code-specific — they use mechanisms like slash commands and AskUserQuestion. But the pattern itself (CLAUDE.md schema, raw/sources/entities structure, three operations) is model-agnostic; you can set up the same flow manually with another assistant.

**How much does it cost?**
For small vaults, a few ingests per day = low token spend. For large vaults, Claude's prompt caching kicks in and reduces per-ingest cost. With direct Anthropic API usage, typical personal use sits in the $5–20/month range; via a Claude Code subscription, it's covered by the subscription.

**Where is the data kept? Privacy?**
The vault is fully local — markdown files on your disk, nothing else. Only the relevant pages you give to / let Claude read during a conversation go to Anthropic. The full vault isn't continuously uploaded.

**Can I push my vault to git?**
Yes. `init-vault.sh` already runs `git init` on the vault, and you can push it to GitHub if you want. Before pushing to a public repo, watch out for sensitive content under `raw/` (API keys, personal info, customer interviews) — you'd need to add those to `.gitignore` manually.

---

## License

MIT — see [LICENSE](LICENSE) for details.

---
---
---

# Türkçe

[English](#llm-wiki-mind) · **Türkçe**

> LLM ajanının sürekli inşa ettiği kalıcı, birikimli bir Obsidian bilgi arşivi (persistent wiki) için **starter template + init script + Claude Code skill'leri**.

Sen kaynak bulursun, Claude bookkeeping'i yapar: özetler, çapraz-referansları kurar, çelişkileri işaretler, sentez yazar. Wiki zamanla büyür ve her yeni soru daha zenginleşmiş bir bilgi katmanıyla karşılanır.

**Rol dağılımı**

| Sen | Claude |
|---|---|
| Kaynak bulur (`raw/` altına kor) | Okur, özetler, dosyalar |
| Hangi soruları soracağını belirler | Çapraz-referansları korur |
| Analizi yönlendirir | Çelişkileri işaretler |
| Sonuçları okur, eleştirel düşünür | Bookkeeping'i yapar |
| Şemayı evriltir | Şemaya uyar |

**Obsidian = IDE, LLM = programmer, wiki = kod tabanı.**

---

![Demo vault overview](docs/screenshots/obsidian-graph-and-overview.png)
*FlowNote demo vault — Graph view ve overview README, Obsidian'da.*

![Demo vault — meeting raw + graph](docs/screenshots/obsidian-graph-and-meeting.png)
*Aynı vault — auth provider eval meeting (raw) ve graph view yan yana.*

---

## Hızlı başlangıç

### Seçenek A — Claude Code skill ile (önerilen)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Hootbu/llm-wiki-mind/main/scripts/install-skills.sh)
```

Skill'leri `~/.claude/skills/` altına bir kerede kurar; mevcut skill varsa yedekler.

Sonra herhangi bir Claude Code oturumunda:

```
/vault-init
```

Claude proje yolu ve vault yolunu soracak, gerisini halledecek.

### Seçenek B — Script doğrudan

```bash
curl -fsSL https://raw.githubusercontent.com/Hootbu/llm-wiki-mind/main/scripts/init-vault.sh \
  -o /tmp/init-vault.sh && chmod +x /tmp/init-vault.sh
/tmp/init-vault.sh ~/Projects/MyApp ~/Desktop/MyApp-Mind/MyApp
```

İki argüman:
1. **PROJECT_PATH** — referans proje dizini (yoksa `-`)
2. **VAULT_PATH** — kurulacak vault'un yeri

Script sorular sorarak ilerler: proje kök `CLAUDE.md` işaretçisi git'e dahil mi, `.gitignore` mı, yoksa atla mı?

Offline / yerel template için:
```bash
./init-vault.sh <proj> <vault> --local ~/Desktop/llm-wiki-mind
```

**Preset ile alanı baştan belirle** — CLAUDE.md §0/§1, `index.md` kategorileri ve `raw/` alt klasörleri otomatik dolar:
```bash
./init-vault.sh <proj> <vault> --preset software
```
Mevcut preset'ler: `software`, `research`, `book-reading`, `journal`. Yeni eklemek için `presets/` klasörüne bak.

---

## Skill'ler ne işe yarar?

### `/vault-init` — yeni vault kur

Yeni bir projeye (veya salt bilgi alanına — kitap okuma, araştırma, günlük) vault kurar. Sorular: proje yolu, vault yolu. Template'i GitHub'dan çeker, yerine yerleştirir, `CLAUDE.md`'deki yolları günceller, projenin kök `CLAUDE.md`'sine **vault işaretçisi** ekler (böylece Claude o projede her oturumda vault'u otomatik tanır).

### `/vault-sync` — değişiklikleri vault'a sindir

Projede commit yaptın mı? Bu skill `git log` + `git diff` okur, commit özetini `raw/pr-discussions/` altına düşer ve vault'un ingest workflow'unu çalıştırır:

- Etkilenen entity/feature/service sayfalarını günceller.
- Yeni feature eklendiyse yeni entity sayfası yaratır.
- Önemli kararlar `decisions/NNNN-*.md` olarak dosyalanır.
- Çelişki çıkarsa silmez — `⚠ Çelişki` notu bırakır.
- `index.md` ve `log.md` senkronize.

Aralık esnek: son commit, belirli hash, tarih aralığı, ya da tüm bir PR (`main..HEAD`).

### `/vault-lint` — sağlık kontrolü

Wiki büyüdükçe bozulur. Bu skill şunları tarar:

- **Çelişkiler** — `⚠ Çelişki` notları, çözüm önerileri.
- **Stale claim'ler** — 90+ gün güncellenmemiş `active` sayfalar; re-ingest önerisi.
- **Orphan sayfalar** — hiç link almayanlar; link ekle veya archive'a taşı.
- **Broken link'ler** — `[[linklenmiş]]` ama dosyası olmayanlar; stub oluştur veya kaldır.
- **Tek-yönlü referanslar** — A→B var ama B→A yok; `## İlgili` ekle.
- **Veri boşlukları** — placeholder'lar; web araması / raw ekleme önerisi.
- **Yeni soru önerileri** — wiki'deki kalıplara bakarak araştırmaya değer 3-5 soru.

Çıktı: tek markdown rapor + otomatik düzeltilebilir değişiklikler kullanıcı onayıyla uygulanır.

---

## Vault nasıl çalışır? (kısa pattern özeti)

### Üç katman

1. **`raw/`** — ham kaynaklar. **Immutable** (sadece sen eklersin, ajan yazmaz).
2. **Wiki** (vault root) — `sources/`, `entities/`, `concepts/`, `decisions/`, `syntheses/`. LLM burayı tamamen yönetir.
3. **`CLAUDE.md`** — şema / anayasa. Her oturumda ilk okunan dosya; klasör yapısını, isimlendirmeyi, workflow'ları, yasakları tanımlar. Sen ve ajan zamanla evriltirsiniz.

### Üç operasyon

- **INGEST** — yeni kaynağı `raw/` altına koy, "ingest et" de. Ajan: okur → source özeti yazar → entity/concept sayfalarını günceller → çelişki varsa işaretler → `index.md` + `log.md` günceller.
- **QUERY** — soru sor. Ajan: `index.md`'yi tarar → ilgili sayfaları açar → sentez üretir → değerli cevapları `syntheses/` altına **filed-back** eder (atomic sayfa olarak).
- **LINT** — periyodik sağlık kontrolü (yukarıda).

### Neden çalışır?

Wiki bakımının zor kısmı düşünmek değil — **bookkeeping**'tir. Çapraz-referanslar, stale özetler, çelişki yakalama, onlarca sayfa arasında tutarlılık. LLM sıkılmaz, unutmaz, tek pass'te 15 dosyaya dokunur. **Wiki bakımlı kalır çünkü bakımın maliyeti neredeyse sıfırdır.**

---

## Örnekler

Pattern'in somut bir vault'ta nasıl göründüğünü görmek için:

- [`examples/saas-project-demo/`](examples/saas-project-demo/) — hayali bir SaaS projesi (FlowNote). Üç raw input (PRD, auth provider eval meeting, prod incident report) ve bunlardan üreyen tam wiki: 4 entity, 1 concept, 2 decision, 1 synthesis. Hikaye: bir auth migration kararı + 1 hafta sonra rate limit incident → kararla incident'i birleştiren filed-back postmortem. Yazılımcılar için pattern'in en somut görünümü.

Önce `examples/saas-project-demo/raw/decisions/auth-provider-eval.md` → sonra `raw/incidents/2026-03-rate-limit.md` → en sonunda `syntheses/auth-migration-postmortem.md` okumayı dene; pattern'in **kararla bir hafta sonraki olayı bağlama** yeteneğini görürsün.

---

## Tipik bir gün

Vault'la çalışmak günlük bir akışa oturur. Örnek bir hafta:

- **Pazartesi** — Yeni bir toplantı transkriptini `raw/meetings/` altına atarsın. `/vault-sync` dersin. Claude transcript'i okur, `sources/` altına özet yazar, geçen entity/concept sayfalarını günceller, çelişki varsa işaretler.
- **Çarşamba** — Projede birkaç commit attın. `/vault-sync` dersin. Skill `log.md`'den son ingest commit'ini otomatik tespit eder, aradaki yeni commit'leri ingest eder; etkilenen entity sayfaları güncellenir, gerekirse `decisions/` altına yeni karar dosyası açılır.
- **Cuma** — Bir soru sorarsın ("auth migration'dan sonra rate limit incident'i ne öğretti?"). Claude `index.md`'yi tarar, ilgili decision + incident sayfalarını okur, sentez verir; değerli olanı `syntheses/` altına filed-back eder.
- **Ay sonu** — `/vault-lint` ile sağlık kontrolü çalıştırırsın: çelişkiler, stale claim'ler, orphan sayfalar, broken link'ler. Rapor + onayınla otomatik düzeltmeler.

Sen kaynak ve soru üretirsin; bookkeeping arka planda kendini toplar.

---

## Kullanım alanları

- **Yazılım projesi**: mimari kararlar, sprint planları, toplantılar, PR tartışmaları, incident'ler, harici servis davranışları, maliyet/performans analizleri.
- **Araştırma**: makaleler, teoriler, metodoloji notları, deney kayıtları, evrilen tez.
- **Kitap okuma**: bölüm bölüm dosyala — karakterler, temalar, bağlantılar. Kişisel bir Gateway.
- **Kişisel gelişim / günlük**: hedefler, sağlık, okuma notları, kendi hakkında yapılandırılmış resim.
- **Takım bilgisi**: Slack thread'leri, toplantı transkriptleri, müşteri görüşmeleri. Kimsenin yapmak istemediği bookkeeping.
- **Rakip analizi, due diligence, ders notları, hobi araştırması** — zamanla bilgi biriktirmek istediğin her şey.

---

## Repo yapısı

```
llm-wiki-mind/
├── README.md                    # bu dosya
├── LICENSE                      # MIT
├── template/                    # /vault-init bunu kopyalar
│   ├── CLAUDE.md                # şema (anayasa) — <VAULT_PATH>/<PROJECT_PATH> placeholder
│   ├── README.md                # vault'un kendi README'i
│   ├── index.md                 # kategori iskelet
│   ├── log.md                   # zamansal kayıt iskelet
│   ├── raw/                     # (boş, .gitkeep)
│   ├── sources/
│   ├── entities/
│   ├── concepts/
│   ├── decisions/
│   ├── syntheses/
│   └── archive/
├── examples/                    # somut, doldurulmuş örnek vault'lar
│   └── saas-project-demo/       # hayali SaaS projesi — 17 dosya, tam hikaye
├── scripts/
│   └── init-vault.sh            # bash kurucu
└── skills/
    ├── vault-init/SKILL.md
    ├── vault-sync/SKILL.md
    └── vault-lint/SKILL.md
```

---

## Teşekkürler

Bu proje [selmakcby/knowledge-pipeline](https://github.com/selmakcby/knowledge-pipeline) reposundaki **Selma Akçebay**'ın yazdığı `llm-wiki` SKILL.md pattern'ından ilham alıyor. Desen özgün olarak ona aittir; bu repo o deseni Türkçe, Obsidian odaklı, "starter + skill" paketlemesi olarak sunar.

Pattern ruhen Vannevar Bush'un 1945'teki **Memex** vizyonuna yakındır — kişisel, aktif olarak küratörlenmiş bilgi deposu, belgeler arasında çağrışımsal izler. Bush'un çözemediği tek şey kimin bakımı yapacağıydı. LLM o kısmı halleder.

Kurulum ve dokümantasyon yardımı: Claude (Anthropic).

---

## SSS

**Notion / Logseq / Tana yerine niye bu?**
Onlar editör — sayfayı sen yazarsın, bağlantıyı sen kurarsın. Bu pattern LLM-bookkeeping'i merkeze koyuyor: markdown'lar ham ve taşınabilir, çapraz-referans/özet/çelişki bakımını Claude yapıyor. Tool değil, bir akış.

**Claude Code şart mı? GPT / Cursor / başka model çalışır mı?**
Skill'ler (`/vault-init`, `/vault-sync`, `/vault-lint`) Claude Code'a özel — slash command, AskUserQuestion gibi mekanizmaları kullanıyor. Ama pattern'in kendisi (CLAUDE.md şeması, raw/sources/entities yapısı, üç operasyon) model-agnostik; başka asistanla manuel olarak aynı akışı kurabilirsin.

**Maliyet ne kadar?**
Küçük vault'larda günde birkaç ingest = düşük token harcaması. Büyük vault'larda Claude'un prompt caching'i devreye giriyor, ingest başına maliyet düşüyor. Anthropic API doğrudan kullanımıyla tipik kişisel kullanım $5-20/ay aralığında; Claude Code aboneliği üzerinden kullanılırsa abonelik kapsamında.

**Veri nerede tutulur, privacy?**
Vault tamamen yerel — markdown dosyaları diskinde, başka yere gitmiyor. Sadece konuşma sırasında Claude'a verdiğin / okuttuğun ilgili sayfalar Anthropic'e gidiyor. Vault'un tamamı sürekli upload edilmiyor.

**Vault'umu git'e push edebilir miyim?**
Evet. `init-vault.sh` vault'u zaten `git init`'liyor, istersen GitHub'a push edebilirsin. Public bir repo'ya push'tan önce `raw/` altına koyduğun gizli içeriklere (API key, kişisel bilgi, müşteri görüşmesi) dikkat et — bunları `.gitignore`'a manuel eklemen gerekir.

---

## Lisans

MIT — detay için [LICENSE](LICENSE).
