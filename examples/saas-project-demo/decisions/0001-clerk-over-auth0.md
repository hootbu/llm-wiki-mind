---
type: decision
status: active
created: 2026-02-28
updated: 2026-03-15
sources:
  - sources/2026-02-28-auth-provider-eval.md
  - sources/2026-03-12-rate-limit-incident.md
tags: [decision, adr, auth, vendor]
---

# 0001 — Clerk over Auth0

**Karar:** FlowNote'un auth provider'ı Auth0'dan Clerk'e geçirilecek.
**Tarih:** 2026-02-28
**Karar verenler:** Emir Yorgun, John Doe, Jane Doe.
**Status:** active (uygulandı 2026-03-04).

## Bağlam

Auth0 sözleşmesi Mayıs 2026'da yenileniyor; mevcut $740/ay + %18 yenileme zammı (~$873/ay). 12k DAU'ya ulaşınca alternatifleri tartışma fırsatı doğdu ([[sources/2026-02-28-auth-provider-eval]]).

## Adaylar

| Aday | Aylık tahmini | Pro | Con |
|---|---|---|---|
| Auth0 (status quo) | $873 (yenileme) | tanıdık, çalışıyor | maliyet, yeni feature pacing yavaş |
| **Clerk** | **~$425** | dev-friendly, JWT customization, webhook | yeni vendor, rate limit görünürlüğü zayıf |
| Supabase Auth | düşük (entegre) | Postgres'le aynı vendor | RLS migration ~3 hafta extra |
| Self-host | infra + bakım | tam kontrol | bakım yükü |

## Karar nedenleri

- Clerk maliyet projeksiyonu Auth0 yenilemesinden ucuz, scale (~100k MAU) sonrasına kadar avantajlı.
- Multi-org modeli FlowNote'un çoklu workspace yapısına uyuyor.
- Webhook-bazlı sync POC'si test edildi (John), Auth0 hooks'tan temiz çıktı.
- Self-host bakım yükünü almak istemiyoruz; Supabase Auth RLS migration'ı bir sonraki major'a kalacak.

## Bilinen riskler (eval'de işaretlenen)

- **Clerk rate limit dokümantasyonu** "fair use" / "100 req/sec soft" — somut değil. Support 100 req/s soft limit dedi (2026-03-01).
- Bu risk **parking lot'a** alındı. Support cevabı "yeterli görüldü" diye yazıldı, prod-paralel ölçüm yapılmadı.
- **Mobile client refresh akışı** Auth0'da sorunsuz çalışıyor; Clerk'te tolere edileceği varsayımıyla migrate edildi (ölçüm yok).

## Sonuç (post-fact)

Migration 2026-03-04'te tamamlandı. **2026-03-12'de rate limit cascade incident'i** oldu ([[sources/2026-03-12-rate-limit-incident]]). Eval'de "parking lot"taki risk somut sorun olarak gerçekleşti — Clerk'in gerçek limit'i ~60 req/sec çıktı, dokümante edilen 100'ün altında.

Karar yine de geri alınmıyor; çözüm client-side backoff ([[decisions/0002-rate-limit-backoff]]) ve server-side throttle. Vendor switch'in altında yatan cost-benefit analizi hâlâ Clerk lehine.

Detaylı analiz: [[syntheses/auth-migration-postmortem]].

## İlgili
- [[entities/services/auth-service]]
- [[entities/external-apis/clerk]]
- [[decisions/0002-rate-limit-backoff]]
- [[syntheses/auth-migration-postmortem]]

## Kaynaklar
- [[sources/2026-02-28-auth-provider-eval]]
- [[sources/2026-03-12-rate-limit-incident]]
