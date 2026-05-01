---
type: synthesis
status: active
created: 2026-03-20
updated: 2026-03-20
sources:
  - sources/2026-02-28-auth-provider-eval.md
  - sources/2026-03-12-rate-limit-incident.md
tags: [synthesis, auth, postmortem, lessons]
---

# auth-migration-postmortem

**Soru (filed-back kaynağı):** "Clerk migration kararıyla Mart 2026 rate limit incident'i arasında nedensel bağ var mı, yoksa iki bağımsız olay mı?"

## Cevap (kısa)

**Nedensel bağ var.** Migration kararı incident'i kaçınılmaz yapmadı; ama eval sürecinde rate limit risk'i "parking lot"a alınıp derinleştirilmediği için, **client-side backoff varsayımının kırıldığı** bir vendor switch'e körlemesine girildi. İki gizli varsayım çakıştı: (1) Clerk dokümantasyonu = gerçek davranış, (2) mobile client'taki backoff'suz refresh = vendor-agnostik olarak tolere edilir.

## Ayrıntı

### 1. Eval'de neyin atlandığı

[[decisions/0001-clerk-over-auth0]] kararında "Clerk rate limit görünürlüğü zayıf" risk'i listelendi. Ama:

- Concrete sayı support'tan alındı (100 req/sec soft) ve dokümantasyon olarak kabul edildi.
- Mevcut mobile client'ta backoff'un Auth0'a göre kalibre edildiği — yani gizli bir varsayım — fark edilmedi ([[sources/2026-02-28-auth-provider-eval]]).
- "Migration sonrası mobile client retry davranışını ölç" diye action item açılmadı.
- "Parking lot" → "yeterli görüldü" geçişi sessizce oldu.

### 2. Niye sorun gerçekleşti

[[sources/2026-03-12-rate-limit-incident]] iki gerçeği aynı anda ortaya çıkardı:

- **Vendor varsayım kayması**: Auth0'da app-level rate limit "var-ama-pratikte-vurulmaz"dı; Clerk'te öyle değil.
- **Dokümantasyon ≠ gerçek**: Clerk pricing "100 req/sec" dedi; gerçek ~60 req/sec. Bu çelişki [[entities/external-apis/clerk]] sayfasında işaretli, support ticket açık.

Mobile client'ın backoff'suz tasarımı Auth0 dünyasında hayatta kalan bir "shortcut"tu. Clerk'e geçiş bunu enforce eden ortamı kaldırdı; shortcut bedeli ödedi.

### 3. Düzeltici aksiyonlar

- **Client-side**: jittered exponential backoff ([[decisions/0002-rate-limit-backoff]]).
- **Server-side**: envoy IP-aware throttle (30 req/min/IP), kalıcı.
- **Vendor**: Clerk support ticket'ı açık ([[entities/external-apis/clerk]] sayfasındaki çelişki notu).
- **Sözleşme review**: auth-level uptime SLA Clerk sözleşmesinde yok — yenileme döneminde gündeme gelecek.

### 4. Çıkarımlar (transferable lesson)

Bu vault için kalıcı kayıt:

- **Vendor switch'lerinde gizli varsayım taraması yap**: "Eski vendor'un sınır çıkmadığı için fark edilmeyen client davranışları" ayrı bir risk kategorisi. Eval matrix'e şu soruyu ekle: *"Hangi mevcut shortcut'lar (backoff yok, retry agressif, timeout uzun, vb.) yeni vendor'da kırılır?"*
- **"Parking lot" ≠ "kabul edildi"**: Risk listelendi diye derinleşmiş sayılmaz; explicit follow-up action ya da explicit "kabul ediyoruz, bu maliyetle yaşarız" notu gerekli.
- **Pricing page sayıları SLA değil**: Production-critical limit'ler test edilmeden vendor seçimi onaylanmasın. "Support'a sorduk" yeterli değil — paralel-prod load test minimum.

## İlgili
- [[decisions/0001-clerk-over-auth0]]
- [[decisions/0002-rate-limit-backoff]]
- [[entities/services/auth-service]]
- [[entities/external-apis/clerk]]
- [[sources/2026-02-28-auth-provider-eval]]
- [[sources/2026-03-12-rate-limit-incident]]

## Kaynaklar
- [[sources/2026-02-28-auth-provider-eval]]
- [[sources/2026-03-12-rate-limit-incident]]
