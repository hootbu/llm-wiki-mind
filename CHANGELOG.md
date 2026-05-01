# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] — 2026-05-01

### Added
- Starter template: `raw/`, `sources/`, `entities/`, `concepts/`, `decisions/`, `syntheses/`, `archive/` yapısı + `CLAUDE.md` şema iskeleti.
- Claude Code skill'leri: `vault-init`, `vault-sync`, `vault-lint` — kurulum, ingest, sağlık kontrolü.
- `scripts/init-vault.sh` — bash kurucu (PROJECT_PATH ↔ VAULT_PATH bağlama, dual-mode CLAUDE.md işaretçisi).
- `scripts/install-skills.sh` — tek komutla 3 skill'i `~/.claude/skills/` altına kuran installer; mevcut skill varsa yedekler.
- Domain preset'leri: `software`, `research`, `book-reading`, `journal` — `init-vault.sh --preset <name>` flag'iyle CLAUDE.md §0/§1 + index.md kategorileri + raw/ alt klasörleri otomatik dolduruluyor.
- `examples/saas-project-demo/` — hayali FlowNote SaaS için 17 dosyalık doldurulmuş örnek vault (auth migration → rate limit incident → postmortem synthesis hikayesi).
- README badges: License (MIT), Built for Claude Code, Obsidian compatible.
- README'de FAQ ve "Tipik bir gün" bölümleri, Obsidian screenshot'ları.
- `.github/workflows/lint.yml` — shellcheck CI.
- `CONTRIBUTING.md`, `CHANGELOG.md`.

### Changed
- `init-vault.sh` REPO_URL artık `LLM_WIKI_REPO` env override ile değiştirilebilir (fork-friendly).

[Unreleased]: https://github.com/Hootbu/llm-wiki-mind/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Hootbu/llm-wiki-mind/releases/tag/v0.1.0
