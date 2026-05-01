# Incident — Auth Rate Limit Cascade (2026-03-12)

**Severity:** SEV-2
**Süre:** 7 dakika (09:03–09:10 TRT)
**Etkilenen:** ~4200 kullanıcı (Pazartesi peak)
**On-call:** Emir Yorgun
**Yazar:** Emir Yorgun

## Özet

Pazartesi sabah 09:00 peak'inde, Clerk auth provider'ından 429 (rate limit) hatası kaskadı geldi. Mobile client'lar token refresh için exponential backoff'sız saldırgan retry yapıyordu — limit'i delemediği gibi geri besleme döngüsüne soktu. 7 dakikada ~4200 kullanıcı login fail. Server-side throttle ve client-side patch ile düzeldi.

## Timeline

- **09:00** — TRT Pazartesi peak. Concurrent ~800 kullanıcı.
- **09:03** — Datadog alarmı: `auth_4xx_rate > 5%`. PagerDuty Emir'e.
- **09:04** — İlk teşhis: Clerk dashboard "rate limited" requests göstermiyor (delayed metric, ~3 dk gecikme).
- **09:05** — Emir client log'larına bakıyor: token refresh 429 dönüyor, client hemen retry, tekrar 429.
- **09:06** — Kararlaştırıldı: server-side IP-aware throttle + client'lar yavaşlasın.
- **09:08** — IP throttle deploy edildi (envoy filter, 30 req/min/IP).
- **09:10** — 4xx oranı normalize. Login flow tekrar çalışıyor.

## Root cause

İki sorun çakıştı:

1. **Mobile client'ta backoff yok.** Token expire → 401 → refresh çağrısı → 429 → hemen retry. 30 saniye içinde tek client ~12 retry yaptı. Bu pattern Auth0 dünyasında hayatta kalıyordu çünkü Auth0'da app-level rate limit pratikte vurulmuyordu.

2. **Clerk gerçek limit dokümantasyonun altında.** Pricing page "100 req/sec soft limit" diyor; support de aynı şeyi konfirme etmişti. Prod'da ~60 req/sec'te kuyruk reddetmeye başladı (peak burst handling Clerk'te aşırı conservative). Bu ölçümü bizim metric'imiz değil Clerk'in 429 dönüşleri gösteriyor.

## Action items

- **A1** [Emir] Mobile client'ta jittered exponential backoff (max 30s). Hot-fix bu hafta.
- **A2** [John] Server-side throttle kalıcı olsun (envoy filter). Done.
- **A3** [Emir] Clerk support'a aç: gerçek limit nedir? Postmortem'e ekle.
- **A4** [Jane] Status page güncelleme — gelecek incident için template.

## Maliyet

- 4200 user, ortalama session değer ~$0.18 → ~$760 revenue impact (kabul: %10 churn-as-leave).
- SLA breach yok (uptime SLA app-level uptime, auth değil — bu bir kontrat eksikliği gibi görünüyor, ayrı tartışma).

## Notlar

- Ironik olarak Clerk migration'ı Auth0'a göre daha temiz/dev-friendly diye seçilmişti. Rate limit konusu eval'de "endişe" olarak parking lot'taydı; support cevabı "yeterli görüldü" diye yazıldı, derinleştirilmedi.
- Mobile client'taki backoff'suz refresh "Auth0'da sorun olmamıştı" varsayımıyla migrate edildi. Bu varsayım şimdi kırıldı.
