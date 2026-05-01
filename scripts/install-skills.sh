#!/usr/bin/env bash
# install-skills.sh — llm-wiki-mind skill kurucu (vault-init, vault-sync, vault-lint)
#
# Kullanım:
#   ./install-skills.sh
#
# ya da repo'yu klonlamadan tek satır:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Hootbu/llm-wiki-mind/main/scripts/install-skills.sh)
#
# Env override:
#   LLM_WIKI_REPO=https://github.com/<fork>/llm-wiki-mind.git ./install-skills.sh
#
# Davranış:
#   - Repo'yu geçici dizine shallow clone'lar.
#   - skills/{vault-init,vault-sync,vault-lint} dizinlerini ~/.claude/skills/ altına kopyalar.
#   - Mevcut skill varsa <skill>.bak.YYYYMMDDHHMMSS olarak yedekler, sonra üzerine yazar.
#   - Idempotent: her çalıştırmada temiz biter.

set -euo pipefail

REPO_URL="${LLM_WIKI_REPO:-https://github.com/Hootbu/llm-wiki-mind.git}"
SKILLS=(vault-init vault-sync vault-lint)
SKILLS_DIR="${HOME}/.claude/skills"

die()  { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

command -v git >/dev/null 2>&1 || die "git bulunamadı. Önce git kurun."

TMPDIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'llm-wiki-mind')"
trap 'rm -rf "$TMPDIR"' EXIT

info "Repo indiriliyor: $REPO_URL"
git clone --depth 1 "$REPO_URL" "$TMPDIR/llm-wiki-mind" >/dev/null 2>&1 \
  || die "git clone başarısız: $REPO_URL"

SRC_SKILLS="$TMPDIR/llm-wiki-mind/skills"
[ -d "$SRC_SKILLS" ] || die "Repo'da skills/ dizini yok: $SRC_SKILLS"

mkdir -p "$SKILLS_DIR"

TS="$(date +%Y%m%d%H%M%S)"

for skill in "${SKILLS[@]}"; do
  src="$SRC_SKILLS/$skill"
  dst="$SKILLS_DIR/$skill"

  [ -d "$src" ] || die "Repo'da skill bulunamadı: skills/$skill"

  if [ -e "$dst" ]; then
    backup="${dst}.bak.${TS}"
    mv "$dst" "$backup"
    info "yedeklendi: $skill → $(basename "$backup")"
  fi

  cp -R "$src" "$dst"
  info "kuruldu: $skill"
done

cat <<EOF

==============================
${#SKILLS[@]} skill kuruldu: ~/.claude/skills/{$(IFS=,; echo "${SKILLS[*]}")}

Şimdi Claude Code'da deneyebilirsin:
  /vault-init   — yeni vault kur
  /vault-sync   — projeyi vault'a sindir
  /vault-lint   — vault sağlık kontrolü
==============================
EOF
