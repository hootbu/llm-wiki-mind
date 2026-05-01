# llm-wiki-mind

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Built for Claude Code](https://img.shields.io/badge/Built%20for-Claude%20Code-D97757)](https://claude.com/claude-code)
[![Obsidian compatible](https://img.shields.io/badge/Obsidian-compatible-7c3aed)](https://obsidian.md)

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

## Hızlı başlangıç

### Seçenek A — Claude Code skill ile (önerilen)

Skill'leri `~/.claude/skills/` altına bir kereliğine kur:

```bash
git clone https://github.com/Hootbu/llm-wiki-mind.git ~/Desktop/llm-wiki-mind
mkdir -p ~/.claude/skills
cp -R ~/Desktop/llm-wiki-mind/skills/vault-init ~/.claude/skills/
cp -R ~/Desktop/llm-wiki-mind/skills/vault-sync ~/.claude/skills/
cp -R ~/Desktop/llm-wiki-mind/skills/vault-lint ~/.claude/skills/
```

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

## Lisans

MIT — detay için [LICENSE](LICENSE).
