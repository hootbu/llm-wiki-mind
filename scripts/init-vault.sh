#!/usr/bin/env bash
# init-vault.sh — llm-wiki-mind vault kurucu
# Kullanım:
#   ./init-vault.sh <PROJECT_PATH> <VAULT_PATH> [--local /path/to/llm-wiki-mind] [--preset NAME] [--yes]
#
# <PROJECT_PATH>  — referans alınacak kod/proje dizini (opsiyonel: "-" geçilirse yok sayılır)
# <VAULT_PATH>    — kurulacak vault'un hedef dizini (yoksa oluşur, varsa reddedilir)
# --local PATH    — template'i GitHub yerine yerel llm-wiki-mind kopyasından kullan
# --preset NAME   — alan tipine göre §0/§1/index/raw'i otomatik doldur (software, research, book-reading, journal)
# --yes           — etkileşimli soruları atla (default: soru sor)
#
# Fork ediyorsan: LLM_WIKI_REPO env değişkeni ile kendi forkunu varsayılan yapabilirsin.

set -euo pipefail

REPO_URL="${LLM_WIKI_REPO:-https://github.com/Hootbu/llm-wiki-mind.git}"
LOCAL_TEMPLATE=""
ASSUME_YES=0
PROJECT_PATH=""
VAULT_PATH=""
PRESET=""

die() { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }
ask() {
  # $1 prompt, $2 default (y/n)
  local prompt="$1" default="$2" ans
  if [ "$ASSUME_YES" = "1" ]; then echo "$default"; return; fi
  read -r -p "$prompt " ans
  echo "${ans:-$default}"
}

# Marker'lar arası bloğu çıkar (başlık satırları hariç).
# $1: dosya, $2: başlangıç marker, $3: bitiş marker
extract_block() {
  awk -v b="$2" -v e="$3" '
    $0==b {flag=1; next}
    $0==e {flag=0; next}
    flag==1 {print}
  ' "$1"
}

# Marker'dan sonraki tüm satırları al (marker hariç).
extract_after() {
  awk -v m="$2" '
    $0==m {flag=1; next}
    flag==1 {print}
  ' "$1"
}

# CLAUDE.md'de "## N. Başlık" ile başlayan bölümün gövdesini (sonraki "## " başlığına kadar) yeni içerikle değiştirir.
# $1: dosya, $2: bölüm başlığı (örn "## 0. Hızlı kimlik"), $3: yeni içerik dosyası
replace_section() {
  local file="$1" header="$2" content_file="$3" tmp
  tmp="$(mktemp)"
  awk -v h="$header" -v cf="$content_file" '
    BEGIN { state=0 }
    state==0 && $0==h {
      print
      while ((getline line < cf) > 0) print line
      close(cf)
      state=1
      next
    }
    state==1 {
      if (/^## /) { state=2; print; next }
      next
    }
    { print }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}

apply_preset() {
  local preset_file="$1"
  local sec0 sec1 idx raw_subdirs
  sec0="$(mktemp)"
  sec1="$(mktemp)"
  idx="$(mktemp)"
  raw_subdirs="$(mktemp)"

  # Marker'lar arası içerikleri çıkar (etrafına boş satır ekleyerek estetik düzgün dursun).
  {
    echo ""
    extract_block "$preset_file" "## CLAUDE_SECTION_0" "## CLAUDE_SECTION_1"
  } > "$sec0"
  {
    echo ""
    extract_block "$preset_file" "## CLAUDE_SECTION_1" "## INDEX_CATEGORIES"
  } > "$sec1"
  extract_block "$preset_file" "## INDEX_CATEGORIES" "## RAW_SUBDIRS" > "$idx"
  extract_after "$preset_file" "## RAW_SUBDIRS" > "$raw_subdirs"

  # Preset §0 içeriğindeki <VAULT_PATH> / <PROJECT_PATH> placeholder'larını da değiştir.
  sed "${SED_INPLACE[@]}" \
    -e "s|<VAULT_PATH>|$VAULT_ABS|g" \
    -e "s|<PROJECT_PATH>|$PROJECT_DISPLAY|g" \
    "$sec0"

  # §0 ve §1'i CLAUDE.md'de değiştir.
  replace_section "$CLAUDE_FILE" "## 0. Hızlı kimlik" "$sec0"
  replace_section "$CLAUDE_FILE" "## 1. Amaç" "$sec1"

  # index.md sonuna preset kategorilerini ekle.
  {
    echo ""
    echo "---"
    echo ""
    cat "$idx"
  } >> "$VAULT_PATH/index.md"

  # raw/ alt klasörlerini oluştur.
  while IFS= read -r sub; do
    [ -z "$sub" ] && continue
    sub="${sub%/}"
    mkdir -p "$VAULT_PATH/raw/$sub"
    : > "$VAULT_PATH/raw/$sub/.gitkeep"
  done < "$raw_subdirs"

  rm -f "$sec0" "$sec1" "$idx" "$raw_subdirs"
  info "Preset uygulandı: $(basename "$preset_file" .md)"
}

# --- argüman ayrıştır ---
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --local) LOCAL_TEMPLATE="$2"; shift 2 ;;
    --preset) PRESET="$2"; shift 2 ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    -h|--help)
      sed -n '2,12p' "$0"; exit 0 ;;
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

# --- preset uygula (varsa) ---
if [ -n "$PRESET" ]; then
  PRESET_FILE="$SRC/../presets/$PRESET.md"
  [ -f "$PRESET_FILE" ] || die "Preset bulunamadı: $PRESET (mevcut: software, research, book-reading, journal)"
  apply_preset "$PRESET_FILE"
fi

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

  POINTER_TMP="$(mktemp)"
  cat > "$POINTER_TMP" <<'EOF'
__MB__
## Vault (llm-wiki-mind)

Bu projenin bilgi arşivi: `__VAULT__`

Claude'a talimat: bu projede bir oturum başladığında veya `/clear` / compact sonrası yukarıdaki vault'un `CLAUDE.md` dosyasını oku ve `index.md` + `log.md` dosyalarını tara. Kullanıcı "ingest", "vault'a sor", "lint" gibi ifadeler kullanırsa vault şemasını izle. Vault'un `raw/` dizini immutable — asla yazma.
__ME__
EOF
  POINTER_BLOCK="$(cat "$POINTER_TMP")"
  rm -f "$POINTER_TMP"
  POINTER_BLOCK="${POINTER_BLOCK//__MB__/$MARKER_BEGIN}"
  POINTER_BLOCK="${POINTER_BLOCK//__VAULT__/$VAULT_ABS}"
  POINTER_BLOCK="${POINTER_BLOCK//__ME__/$MARKER_END}"

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
    echo "Secenekler:"
    echo "  1) Proje kok CLAUDE.md icine vault isaretcisi ekle (commitlenebilir, takim gorur)"
    echo "  2) Ekle ama .gitignore icine de koy (sadece senin makinende kalir)"
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
