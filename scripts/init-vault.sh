#!/usr/bin/env bash
# init-vault.sh — llm-wiki-mind vault kurucu
# Kullanım:
#   ./init-vault.sh <PROJECT_PATH> <VAULT_PATH> [--local /path/to/llm-wiki-mind] [--yes]
#
# <PROJECT_PATH>  — referans alınacak kod/proje dizini (opsiyonel: "-" geçilirse yok sayılır)
# <VAULT_PATH>    — kurulacak vault'un hedef dizini (yoksa oluşur, varsa reddedilir)
# --local PATH    — template'i GitHub yerine yerel llm-wiki-mind kopyasından kullan
# --yes           — etkileşimli soruları atla (default: soru sor)

set -euo pipefail

REPO_URL="https://github.com/Hootbu/llm-wiki-mind.git"
LOCAL_TEMPLATE=""
ASSUME_YES=0
PROJECT_PATH=""
VAULT_PATH=""

die() { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }
ask() {
  # $1 prompt, $2 default (y/n)
  local prompt="$1" default="$2" ans
  if [ "$ASSUME_YES" = "1" ]; then echo "$default"; return; fi
  read -r -p "$prompt " ans
  echo "${ans:-$default}"
}

# --- argüman ayrıştır ---
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --local) LOCAL_TEMPLATE="$2"; shift 2 ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    -h|--help)
      sed -n '2,10p' "$0"; exit 0 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

[ ${#POSITIONAL[@]} -ge 2 ] || die "usage: $0 <PROJECT_PATH> <VAULT_PATH> [--local DIR] [--yes]"
PROJECT_PATH="${POSITIONAL[0]}"
VAULT_PATH="${POSITIONAL[1]}"

# --- yolları normalize et ---
if [ "$PROJECT_PATH" != "-" ]; then
  [ -d "$PROJECT_PATH" ] || die "PROJECT_PATH dizini yok: $PROJECT_PATH"
  PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
fi

if [ -e "$VAULT_PATH" ]; then
  die "VAULT_PATH zaten var: $VAULT_PATH (manuel silin ya da farklı yol verin)"
fi
VAULT_PARENT="$(dirname "$VAULT_PATH")"
mkdir -p "$VAULT_PARENT"

# --- template kaynağı ---
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

if [ -n "$LOCAL_TEMPLATE" ]; then
  [ -d "$LOCAL_TEMPLATE/template" ] || die "--local dizininde template/ alt klasörü yok"
  SRC="$LOCAL_TEMPLATE/template"
  info "Local template kullanılıyor: $SRC"
else
  info "Template indiriliyor: $REPO_URL"
  git clone --depth 1 "$REPO_URL" "$TMPDIR/llm-wiki-mind" >/dev/null 2>&1 \
    || die "git clone başarısız. --local <path> ile yerel kopya verebilirsiniz."
  SRC="$TMPDIR/llm-wiki-mind/template"
fi

# --- kopyala ---
info "Vault oluşturuluyor: $VAULT_PATH"
cp -R "$SRC" "$VAULT_PATH"
# .gitkeep dosyalarını korumak için temizlik yok; Obsidian görmezden gelir.

# --- CLAUDE.md placeholder'ları değiştir ---
CLAUDE_FILE="$VAULT_PATH/CLAUDE.md"
TODAY="$(date +%Y-%m-%d)"
VAULT_ABS="$(cd "$VAULT_PATH" && pwd)"

# macOS sed -i '' / GNU sed -i ayrımı
if sed --version >/dev/null 2>&1; then
  SED_INPLACE=(-i)
else
  SED_INPLACE=(-i '')
fi

PROJECT_DISPLAY="$PROJECT_PATH"
[ "$PROJECT_PATH" = "-" ] && PROJECT_DISPLAY="(yok)"

sed "${SED_INPLACE[@]}" \
  -e "s|<VAULT_PATH>|$VAULT_ABS|g" \
  -e "s|<PROJECT_PATH>|$PROJECT_DISPLAY|g" \
  "$CLAUDE_FILE"

# --- ilk log girişi ---
{
  echo ""
  echo "## [$TODAY] schema | vault kuruldu"
  echo ""
  echo "- \`init-vault.sh\` ile template indirildi, \`$VAULT_ABS\` altına kopyalandı."
  echo "- Referans proje: \`$PROJECT_DISPLAY\`."
  echo "- CLAUDE.md §0 ve §1 alanlarını ilk oturumda doldurmayı unutma."
} >> "$VAULT_PATH/log.md"

# --- vault git init ---
( cd "$VAULT_PATH" && git init -q && git add . && git -c user.email="vault@local" -c user.name="vault-init" commit -q -m "init vault from llm-wiki-mind template" ) || true
info "Vault git repo başlatıldı (opsiyonel)."

# --- proje bağlantısı (opsiyonel) ---
if [ "$PROJECT_PATH" != "-" ]; then
  PROJECT_CLAUDE="$PROJECT_PATH/CLAUDE.md"
  MARKER_BEGIN="<!-- llm-wiki-mind:begin -->"
  MARKER_END="<!-- llm-wiki-mind:end -->"

  POINTER_BLOCK=$(cat <<EOF
$MARKER_BEGIN
## Vault (llm-wiki-mind)

Bu projenin bilgi arşivi: \`$VAULT_ABS\`

Claude'a talimat: bu projede bir oturum başladığında veya \`/clear\` / compact sonrası yukarıdaki vault'un \`CLAUDE.md\` dosyasını oku ve \`index.md\` + \`log.md\` dosyalarını tara. Kullanıcı "ingest", "vault'a sor", "lint" gibi ifadeler kullanırsa vault şemasını izle. Vault'un \`raw/\` dizini immutable — asla yazma.
$MARKER_END
EOF
)

  WRITE_POINTER=0
  IGNORE_POINTER=0

  if [ -f "$PROJECT_CLAUDE" ] && grep -q "$MARKER_BEGIN" "$PROJECT_CLAUDE" 2>/dev/null; then
    info "Projenin CLAUDE.md'sinde zaten vault işaretçisi var — güncelleniyor."
    # MARKER_BEGIN ... MARKER_END arası bloğu sil, yeniden ekle.
    awk -v b="$MARKER_BEGIN" -v e="$MARKER_END" '
      $0==b {skip=1; next}
      skip==1 && $0==e {skip=0; next}
      skip!=1 {print}
    ' "$PROJECT_CLAUDE" > "$PROJECT_CLAUDE.tmp" && mv "$PROJECT_CLAUDE.tmp" "$PROJECT_CLAUDE"
    WRITE_POINTER=1
  else
    echo ""
    echo "Proje yolu: $PROJECT_PATH"
    echo "Seçenekler:"
    echo "  1) Proje kök CLAUDE.md'ye vault işaretçisi ekle (commit'lenebilir, takım görür)"
    echo "  2) Ekle ama .gitignore'a da koy (sadece senin makinende kalır)"
    echo "  3) Ekleme (atla, sadece vault kuruldu)"
    case "$(ask 'Tercih [1/2/3]:' '1')" in
      1) WRITE_POINTER=1 ;;
      2) WRITE_POINTER=1; IGNORE_POINTER=1 ;;
      3) ;;
      *) ;;
    esac
  fi

  if [ "$WRITE_POINTER" = "1" ]; then
    if [ -f "$PROJECT_CLAUDE" ]; then
      printf "\n%s\n" "$POINTER_BLOCK" >> "$PROJECT_CLAUDE"
    else
      printf "# %s\n\n%s\n" "$(basename "$PROJECT_PATH")" "$POINTER_BLOCK" > "$PROJECT_CLAUDE"
    fi
    info "İşaretçi eklendi: $PROJECT_CLAUDE"

    if [ "$IGNORE_POINTER" = "1" ]; then
      PROJECT_GITIGNORE="$PROJECT_PATH/.gitignore"
      if [ ! -f "$PROJECT_GITIGNORE" ] || ! grep -qxF "CLAUDE.md" "$PROJECT_GITIGNORE"; then
        echo "CLAUDE.md" >> "$PROJECT_GITIGNORE"
        info ".gitignore güncellendi: CLAUDE.md eklendi."
      fi
    fi
  else
    info "Proje CLAUDE.md'sine işaretçi eklenmedi."
  fi
fi

# --- özet ---
cat <<EOF

==============================
Vault kuruldu.
==============================
Vault yolu   : $VAULT_ABS
Referans     : $PROJECT_DISPLAY
Sonraki adım :
  1) Obsidian'da vault'u aç: "Open folder as vault" → $VAULT_ABS
  2) CLAUDE.md §0 ve §1'i doldur (alan, amaç, örnek sorular).
  3) İlk kaynağı raw/<alt-klasör>/ altına koy, Claude'a "ingest et" de.

Daha fazla: https://github.com/Hootbu/llm-wiki-mind
EOF
