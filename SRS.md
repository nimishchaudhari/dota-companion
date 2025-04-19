# Dota Companion – Complete Software Requirements & Functional Specification
*Revision **1.1 – Final Draft** – April 18 2025*

> **Purpose of this document** – Hand it to any autonomous engineering agent (or human team) and they will have every contract, interface, and constraint they need to produce a first working release of Dota Companion without further clarification.

---

## 0  Executive Overview
Dota Companion is a **browser‑based, VAC‑safe companion web application** for Dota 2 that:
1. Streams *only* Valve‑approved Game State Integration (GSI) telemetry.
2. Combines it with public match data from **OpenDota** & **STRATZ**.
3. Feeds compact event frames to a **user‑supplied Large‑Language‑Model (LLM)** for personalised coaching.
4. Presents the results as overlays, dashboards, and push notifications on any device.

Key differentiators:
* Zero installs on mobiles – delivered as a Progressive Web App (PWA).
* Users keep control of their AI provider choice & API key (OpenAI, Mistral, Anthropic, etc.).
* 100 % VAC‑safe (no memory reads, no DLL injections).

Target launch date: **November 21 2025**.

---

## 1  Business Context
| Item | Value |
|------|-------|
| Stakeholders | Product Lead, Esports Coach Council, Streaming Partners |
| Revenue Model | Freemium (€4.99 Plus tier), Affiliate cosmetics, B2B team dashboards |
| Success KPIs | DAU ≥ 120 k, Plus conversion ≥ 4 %, Churn ≤ 5 %/month |

---

## 2  System Scope & Architecture

### 2.1 High‑Level Context Diagram
```
+-----------+           HTTPS          +--------------------+
|  Browser  |<------------------------>|  GraphQL Gateway   |
| (PWA/WS)  |------------------------->|  (Mesh + Hive)     |
+-----------+  SSE/WS   |             +----------+---------+
                        |                        |
+-------------+   WS    |                        |  REST/GraphQL
| Electron    |<--------+              +---------v---------+
| Overlay     |                       |   LLM Proxy       |
+-------------+  UDP                   |  (Stateless)      |
        ^      (GSI)                  +---------+---------+
        |                                         |
        |                                         v
+-------+-------+                          +------+------+  Redis, PG, TSDB
|  Dota 2 Game  |                          |  Data API   |-----> Databases
+---------------+                          +-------------+
```

### 2.2 Deployment Environments
| Env | Cluster | DB | TLS Termination |
|-----|---------|----|-----------------|
| Dev | Kind | SQLite | Self‑signed |
| Staging | GKE europe‑west1 | PG 16  | Cloudflare CERT |
| Prod | GKE europe‑west1 | PG 16 + Timescale 2.15 | Cloudflare CERT |

---

## 3  Detailed Functional Requirements (Complete)

### 3.1 Authentication & Authorisation
* **FR‑AUTH‑1** – Steam OpenID 2.0 login via `openid/login` endpoint.
* **FR‑AUTH‑2** – JWT issued (HS512), 4‑hour expiry, refresh token rotated.
* **FR‑AUTH‑3** – Roles: `FREE`, `PLUS`, `ADMIN`.

### 3.2 AI Coach (LLM Integration)
* **FR‑LLM‑1** – Settings screen stores provider config `{ provider, baseUrl, model, apiKey }` encrypted in IndexedDB using WebCrypto AES‑GCM 256.
* **FR‑LLM‑2** – LLM Proxy accepts requests in the following schema:
```json
{
  "model": "gpt-4o-mini",
  "provider": "openai",
  "apiKeyCiphertext": "…",
  "nonce": "…",
  "messages": [
    {"role": "system", "content": "You are a Dota 2 coach …"},
    {"role": "user", "content": "GAME_STATE: …"}
  ]
}
```
* **FR‑LLM‑3** – First token must be streamed back to client ≤ 150 ms p95.
* **FR‑LLM‑4** – Provider HTTP errors → graceful degradation chart:
| HTTP | Action |
|------|--------|
| 401/403 | Prompt re‑enter key |
| 429 | Backoff (exponential starting 30 s) |
| 5xx | Fallback to text disabled |

### 3.3 Draft Assistant
* **FR‑DRAFT‑1** – For each pick/ban, gateway resolves top 5 counters (min sample 500 games) and top 3 synergies.
* **FR‑DRAFT‑2** – UI update ≤ 500 ms of GSI event.

### 3.4 Match History & Analytics
* **FR‑HIST‑1** – Last 100 matches paginated (20/page).
* **FR‑HIST‑2** – Timeline charts 10 s granularity using `/match/<id>/timeline` REST.
* **FR‑HIST‑3** – Percentile benchmarks computed nightly by cron job in Data API.

### 3.5 Replay Clip & Share
* **FR‑CLIP‑1** – Generate 720p MP4 (< 10 MB) in < 60 s via ffmpeg in serverless job.

### 3.6 Pro‑Match Alerts
* **FR‑PRO‑1** – Subscribe up to 10 teams; push via FCM/Web Push.
* **FR‑PRO‑2** – Delay ≤ 15 s from match start.

### 3.7 PWA & Offline
* **FR‑PWA‑1** – Installable; icon set in manifest.
* **FR‑PWA‑2** – Offline caching via Workbox runtime rules for `/heroes`, `/matches/recent`.

---

## 4  Non‑Functional Requirements (Complete)
| ID | Category | Spec |
|----|----------|------|
| NFR‑PERF‑1 | Latency | Overlay → First coach word ≤ 200 ms p95 EU West |
| NFR‑SCALE‑1 | Scaling | 20 k concurrent overlays, 200 req/s GraphQL |
| NFR‑AVAIL‑1 | Uptime | 99.5 % Monthly |
| NFR‑SEC‑1 | Privacy | API keys client‑only, never logged |
| NFR‑SEC‑2 | GDPR | Right‑to‑delete ≤ 24 h |
| NFR‑A11Y‑1 | Accessibility | WCAG 2.2 AA |
| NFR‑TEST‑1 | Quality | Unit ≥ 80 %, e2e (Playwright) ≥ 20 critical flows |

---

## 5  API Inventory (Non‑Exhaustive)

### 5.1 GraphQL
* `draftSuggestions(state: DraftInput!): DraftAdvice!`
* `liveCoachPing(frame: FrameInput!): AIResponse!  # SSE subscription`

### 5.2 REST
| Method | Path | Purpose |
|--------|------|---------|
| GET | `/v1/users/{steamId}/matches?limit=100` | Match list |
| POST | `/v1/clip` | Start clip render |
| POST | `/v1/llm/chat` | Proxy to selected provider |

### 5.3 WebSocket Topics
* `/ws/frame` – Overlay → Gateway (1 msg/sec)
* `/ws/coach` – Gateway → Overlay (token stream)

---

## 6  Data Design (Excerpt)
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  steam_id BIGINT NOT NULL UNIQUE,
  role TEXT CHECK (role IN ('FREE','PLUS','ADMIN')),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE match_events (
  match_id BIGINT,
  ts   TIMESTAMPTZ,
  type TEXT,
  payload JSONB
) PARTITION BY RANGE (ts);
SELECT create_hypertable('match_events','ts');
```

---

## 7  Sequence Diagram – Live Coach (Token Streaming)
```
Participant Overlay
Participant Gateway
Participant LLMProxy
Participant Provider

Overlay->Gateway: GSI Frame (WS)
Gateway->LLMProxy: /llm/chat (JSON)
LLMProxy->Provider: POST /chat (stream)
Provider-->>LLMProxy: token 1..n (SSE)
LLMProxy-->>Gateway: token 1..n
Gateway-->>Overlay: token 1..n (WS)
Overlay->Overlay: Display / TTS
```

---

## 8  CI/CD & Infrastructure
* **GitHub Actions** – Lint, test, build containers.
* **Argo CD** – GitOps sync to clusters.
* **Helm charts** – parameterise `env`, HPA, secrets via SealedSecrets.
* **Terraform** – GKE, CloudSQL, Redis Memorystore, Cloudflare resources.
* **Observability** – Prometheus, Grafana, Loki, Alertmanager (PagerDuty route).

---

## 9  Test Plan Highlights
| Layer | Tool | Key Tests |
|-------|------|-----------|
| Unit | Jest | Utils, reducers, prompt builder |
| Integration | Supertest | Auth, LLM proxy, GSI ingest |
| e2e | Playwright | Draft flow, AI coach voice on/off |
| Load | k6 | 20 k WS clients, 200 req/s GraphQL |
| Security | ZAP | OWASP Top 10 scan |

---

## 10  Project Timeline (Updated)
| Date | Milestone |
|------|-----------|
| 2025‑05‑02 | Overlay frame emitter & PWA shell |
| 2025‑06‑06 | LLM proxy MVP (OpenAI only) |
| 2025‑07‑11 | Provider‑agnostic config, IndexedDB encryption |
| 2025‑08‑15 | Draft Assistant beta |
| 2025‑09‑19 | Pro‑Match alerts, push notifications |
| 2025‑10‑24 | Plus paywall & Stripe |
| 2025‑11‑21 | Public launch (v1.0) |

---

## 11  Glossary (Abbrev.)
| Term | Meaning |
|------|---------|
| **GSI** | Game State Integration |
| **LLM** | Large Language Model |
| **SSE** | Server‑Sent Events |
| **TSDB** | Time‑Series DB |

---

## 12  Acceptance Criteria for v1.0 (Must‑Have)
1. Player installs overlay and PWA; receives counter suggestions within 500 ms of a pick.
2. Voice coach speaks within 2 s of a kill event using personal OpenAI key.
3. Match history page shows 100 matches with timelines on mobile Safari.
4. GDPR delete request acknowledged and data wiped (< 24 h).
5. 99.5 % uptime over a continuous 30‑day staging soak.

---

## 13  Future Considerations (Non‑exhaustive)
* WebGPU on‑device LLM (2–3 B params) to remove server dependency.
* Shared team prompts & cohort analytics dashboard.
* Twitch extension embedding draft advice for spectators.

---

### End of Document – This version is **conclusive** for initial development.

