# Log

## [2026-02-15] ingest | offline-sync-spec.md → 1 source + 1 feature + 1 service + 1 concept

PRD ingest edildi. [[entities/features/offline-mode]] feature sayfası yaratıldı. CRDT/Y.js bağlantısıyla [[concepts/eventual-consistency]] concept sayfası yaratıldı. [[entities/services/realtime-sync]] servisi PRD'den çıkarımla oluşturuldu (zaten Y.js Awareness için kullanılıyormuş).

## [2026-02-28] ingest | auth-provider-eval.md → 1 source + 2 entity + 1 decision

Auth provider tech review meeting ingest edildi. [[entities/services/auth-service]] ve [[entities/external-apis/clerk]] entity'leri yaratıldı. [[decisions/0001-clerk-over-auth0]] kararı dosyalandı. Endişe: Clerk rate limit görünürlüğü zayıf, parking lot'a alındı (sonraki ingest'te bunun ödenmemiş bedeli ortaya çıkacak).

## [2026-03-12] ingest | 2026-03-rate-limit.md → 1 source + 2 entity güncelleme + 1 decision

Mart 12 rate limit incident'i ingest edildi. [[entities/external-apis/clerk]] entity'sine "gerçek davranış" bölümü eklendi (dokümantasyondan ayrılan rate limit). [[entities/services/auth-service]] token refresh stratejisi güncellendi. [[decisions/0002-rate-limit-backoff]] kararı dosyalandı.

> ⚠ Çelişki: Clerk dokümantasyonu "soft 100 req/s" diyor ama incident sırasında kuyruk ~60 req/s civarında reddedilmeye başlamış. [[entities/external-apis/clerk]] sayfasına işaretlendi, support ticket açık.

## [2026-03-20] query | "auth migration ile incident bağı" → filed: [[syntheses/auth-migration-postmortem]]

Soru: "Clerk'e geçişle Mart incident'i arasında nedensel bağ var mı?" Cevap iki kararı + bir entity'i + iki source'u birleştiren bir sentez oluşturdu. [[syntheses/auth-migration-postmortem]] olarak filed-back. Transferable lesson çıkardı: vendor switch'lerinde "eski vendor'un sınır çıkmadığı için fark edilmeyen client davranışları" ayrı bir risk kategorisi.

## [2026-03-25] schema | demo notu

Bu vault llm-wiki-mind örneği — gerçek değil. İsimler, sayılar, tarihler kurgu.
