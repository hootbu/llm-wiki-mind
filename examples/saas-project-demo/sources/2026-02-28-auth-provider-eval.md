---
type: source
subtype: meeting
status: active
created: 2026-02-28
updated: 2026-02-28
tags: [auth, decision, vendor]
---

# Auth provider tech review özeti

Auth0 sözleşmesi yenilenmesi yaklaşırken yapılan değerlendirme toplantısı; sonuç Clerk'e geçiş.

## Anahtar noktalar

- **Adaylar**: Auth0 (status quo, $740/ay +%18 yenileme), Clerk, Supabase Auth, self-host ([raw](../raw/decisions/auth-provider-eval.md)).
- **Karar**: Clerk seçildi.
- **Maliyet projeksiyonu**: 12k DAU → ~25k MAU → ~$425/ay (Clerk) vs ~$873/ay (Auth0 yenilemesi).
- **Migration plan**: 2 hafta dual-mode (Auth0 token + Clerk fallback), sonra Auth0 kapatma. Hedef deploy 2026-03-04.
- **Endişe — parking lot**: Clerk rate limit'i pricing page'de "fair use"; support 100 req/s soft limit dedi → "yeterli görüldü" notuyla kapatıldı, derinleştirilmedi ([raw](../raw/decisions/auth-provider-eval.md)).
- **Mobile refresh varsayımı**: Auth0'da sorunsuz çalışan client refresh akışının Clerk'te de tolere edileceği varsayıldı; ölçüm yapılmadı.
- **Erteleme**: Self-host post-mortem'e, Supabase Auth bir sonraki major'a.

## İlgili
- [[entities/services/auth-service]]
- [[entities/external-apis/clerk]]
- [[decisions/0001-clerk-over-auth0]]

## Açık sorular
- Clerk gerçek rate limit davranışı eval sonunda doğrulanmadı (parking lot'ta kaldı).
- Mobile client refresh davranışı migration sonrası ölçülmedi.

## Kaynaklar
- [raw/decisions/auth-provider-eval.md](../raw/decisions/auth-provider-eval.md)
