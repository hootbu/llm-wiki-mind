# Index

FlowNote vault — sayfaların kategorik kataloğu.

## Services

- [[entities/services/auth-service]] — kimlik doğrulama servisi (Auth0 → Clerk migration sonrası).
- [[entities/services/realtime-sync]] — Y.js + WebSocket tabanlı CRDT sync servisi.

## Features

- [[entities/features/offline-mode]] — IndexedDB cache + offline edit + reconciliation.

## External APIs

- [[entities/external-apis/clerk]] — auth provider; rate limit ve token refresh davranışı.

## Concepts

- [[concepts/eventual-consistency]] — offline sync ve realtime collaboration için temel garanti modeli.

## Decisions

- [[decisions/0001-clerk-over-auth0]] — auth provider seçimi (2026-02-28).
- [[decisions/0002-rate-limit-backoff]] — client-side jittered backoff stratejisi (2026-03-15).

## Syntheses

- [[syntheses/auth-migration-postmortem]] — Clerk migration kararı + Mart 2026 rate limit incident'inin birleşik analizi.

## Sources

- [[sources/2026-02-15-offline-sync-spec]]
- [[sources/2026-02-28-auth-provider-eval]]
- [[sources/2026-03-12-rate-limit-incident]]
