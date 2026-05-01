# Auth Provider Değerlendirme — Tech Review

**Tarih:** 2026-02-28
**Katılımcılar:** Emir Yorgun (Sr. Eng), John Doe (Backend Lead), Jane Doe (PM)
**Süre:** 50 dk

## Bağlam

Auth0 sözleşmesi Mayıs 2026'da yenileniyor. Şu an aylık $740. Bir önceki sözleşme review'unda kararlaştırılan "büyürken yeniden bakarız" notu vardı. 12k DAU'ya ulaştık, alternatifleri tartışalım.

## Adaylar

1. **Auth0 (status quo)** — $740/ay, yenileme +%18 (~$873).
2. **Clerk** — yeni nesil, dev-friendly. $25/ay temel + $0.02/MAU after 5k.
3. **Supabase Auth** — Postgres'i zaten kullanıyoruz; entegre.
4. **Self-host (Lucia, NextAuth)** — kontrol max, bakım yükü +.

## Tartışma

**Emir:** Clerk'in JWT customization'ı bizim multi-org modelimize uyuyor mu?
**John:** Webhook bazlı approach çalışıyor — POC'sini geçen hafta yaptım, prod'da Auth0 hooks'tan daha temiz.

**Jane:** Migration sürecinde kullanıcı login state ne olur?
**Emir:** Stale Auth0 token'ları + Clerk fallback ile dual-mode 2 hafta. Sonra Auth0 kapatma. Kullanıcı re-login zorunluluğu yok.

**John:** Supabase Auth çekiyor ama RLS politikalarımızın migration maliyeti yüksek. ~3 hafta extra. Bir sonraki major'a koyalım.

**Emir:** Clerk pricing modeli scaling'de tehlikeli mi?
**John:** 12k DAU → ~25k MAU → ($25 + 20k * $0.02) = $425/ay. Auth0 yenilemesinden ucuz. 100k MAU'da bile (~$2k/ay) Auth0 enterprise'tan ucuz.

**Emir:** Self-host?
**John:** Bakım yükü almak istemiyorum. Pass.

## Kapanış / aksiyon

- Karar: **Clerk**.
- Emir migration plan'ı yazacak (2 hafta).
- Deploy hedefi: 2026-03-04.
- Self-host opsiyonu post-mortem'e kaldırıldı.
- Supabase Auth bir sonraki majora.

## Endişeler (parking lot)

- Clerk rate limit'leri görünür değil — pricing page'de "fair use" yazıyor. Emir support'a soracak.
- (Cevap geldi 2026-03-01: 100 req/sec soft limit, "kontak edin" diyorlar 1000+ için. Yeterli görüldü.)
- Mobile token refresh akışını migration sonrası ölçmedik — Auth0'da hiç sorun olmamıştı, varsayım olarak Clerk'te de tolere edileceği düşünüldü.
