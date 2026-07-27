# frozen_string_literal: true

module Content
  class MockGenerator
    def self.blueprints
      interviews.each_with_index.map { |m, i| m.merge(position: i + 1) }
    end

    def self.interviews
      [
        faang_backend,
        startup_full_stack,
        stripe_payments,
        datadog_observability,
        uber_realtime,
        amazon_leadership,
        netflix_scale,
        shopify_commerce,
        cloudflare_edge,
        wizdaa_nestjs
      ]
    end

    def self.faang_backend
      {
        title: "FAANG Backend Loop (NestJS Focus)",
        slug: "faang-backend-loop-nestjs",
        introduction: "75-minute senior backend loop covering theory, live coding, architecture, and behavioral. Assume NestJS + PostgreSQL + Redis.",
        duration_minutes: 75,
        difficulty: "hard",
        company_focus: "FAANG",
        scoring_rubric: "Theory clarity 20%, coding correctness/edge cases 30%, architecture tradeoffs 25%, communication 15%, behavioral ownership 10%.",
        interviewer_notes: "Push on failure modes, idempotency, and how they would roll out safely. Interrupt if candidate jumps to microservices without justification.",
        items: [
          { section: "introduction", prompt: "Walk me through a production NestJS service you owned end-to-end.", expected_answer: "Clear ownership: domain, SLIs, on-call, key incidents, tech choices (Nest modules, Postgres, queues), and measurable impact.", follow_ups: "What would you rewrite? What was the biggest outage?", duration_minutes: 5, position: 1 },
          { section: "theory", prompt: "Explain the Node.js event loop and when CPU-bound work breaks Nest latency SLOs.", expected_answer: "Phases (timers, poll, check); single-threaded JS; offload CPU via worker threads/separate services; never block event loop with sync crypto/fs on hot paths.", follow_ups: "How do you detect event-loop lag in production?", duration_minutes: 8, position: 2 },
          { section: "practical", prompt: "Design JWT access + refresh token rotation for a Nest API.", expected_answer: "Short-lived access JWT; refresh in httpOnly cookie or rotating store; reuse detection; revoke lists; CSRF if cookies.", follow_ups: "How do you force logout everywhere?", duration_minutes: 8, position: 3 },
          { section: "coding", prompt: "Implement idempotent POST /transfers with row locks and an idempotency key.", expected_answer: "Transaction + pessimistic locks in sorted account id order; unique idempotency key; ledger entries; insufficient funds error.", follow_ups: "Optimistic locking variant? Outbox for notifications?", duration_minutes: 20, position: 4 },
          { section: "architecture", prompt: "Sketch module boundaries for Orders, Inventory, Payments in a modular Nest monolith.", expected_answer: "Clear module APIs, no cross-DB joins across domains, async events for side effects, shared kernel minimal.", follow_ups: "When would you split into services?", duration_minutes: 12, position: 5 },
          { section: "system_design", prompt: "Design a rate limiter for 100k RPS API gateway.", expected_answer: "Token bucket/sliding window in Redis; local + global limits; fail-open vs fail-closed; fairness; observability.", follow_ups: "How do you handle multi-region?", duration_minutes: 12, position: 6 },
          { section: "behavioral", prompt: "Tell me about a time you disagreed with a tech lead on an API design.", expected_answer: "STAR: data-driven disagreement, listened, proposed tradeoffs, committed to decision, followed up with metrics.", follow_ups: "What did you learn about influence without authority?", duration_minutes: 10, position: 7 }
        ]
      }
    end

    def self.startup_full_stack
      {
        title: "Startup Senior Node Interview",
        slug: "startup-senior-node",
        introduction: "60-minute practical interview for a high-ownership Nest/Node role at a Series B startup.",
        duration_minutes: 60,
        difficulty: "medium",
        company_focus: "Startup",
        scoring_rubric: "Shipping judgment 30%, coding 30%, pragmatism 20%, communication 20%.",
        interviewer_notes: "Reward bias to action and MVP scoping. Penalize over-engineering.",
        items: [
          { section: "introduction", prompt: "What did you ship in the last quarter that moved a metric?", expected_answer: "Specific metric, role, tradeoffs under time pressure.", follow_ups: "What did you cut?", duration_minutes: 5, position: 1 },
          { section: "theory", prompt: "REST vs RPC for internal services — when each?", expected_answer: "REST for public/resource APIs; RPC/gRPC for low-latency internal; contracts and versioning matter more than fashion.", follow_ups: "Idempotency keys on which verbs?", duration_minutes: 6, position: 2 },
          { section: "practical", prompt: "How do you structure Nest modules for a small team of 4?", expected_answer: "Feature modules, shared infra module, avoid premature microservices, strong lint/test CI.", follow_ups: "Monorepo or polyrepo?", duration_minutes: 6, position: 3 },
          { section: "coding", prompt: "Build cursor pagination for GET /items with stable ordering.", expected_answer: "Keyset on (createdAt,id); opaque cursor; clamp limit; nextCursor.", follow_ups: "Filter + cursor together?", duration_minutes: 18, position: 4 },
          { section: "architecture", prompt: "Background job strategy for email + webhooks with retries.", expected_answer: "BullMQ, exponential backoff, DLQ, idempotent consumers, after-commit enqueue.", follow_ups: "Poison messages?", duration_minutes: 10, position: 5 },
          { section: "system_design", prompt: "MVP URL shortener for launch week.", expected_answer: "Hash/base62 ids, Postgres, redirect cache, analytics async, custom domains later.", follow_ups: "Abuse prevention?", duration_minutes: 8, position: 6 },
          { section: "behavioral", prompt: "Describe wearing multiple hats during an incident.", expected_answer: "Triage, communicate, fix, postmortem without blame.", follow_ups: "What process changed after?", duration_minutes: 7, position: 7 }
        ]
      }
    end

    def self.stripe_payments
      {
        title: "Stripe-like Payments Backend",
        slug: "stripe-like-payments-backend",
        introduction: "90-minute deep dive on payment correctness, idempotency, and ledger design.",
        duration_minutes: 90,
        difficulty: "hard",
        company_focus: "Stripe",
        scoring_rubric: "Correctness 40%, systems thinking 25%, coding 20%, communication 15%.",
        interviewer_notes: "Probe money as integers, exactly-once effects, and reconciliation.",
        items: [
          { section: "introduction", prompt: "Experience with money movement or financial ledgers?", expected_answer: "Concrete systems, auditability, double-entry if any.", follow_ups: "Biggest money bug you prevented?", duration_minutes: 5, position: 1 },
          { section: "theory", prompt: "Why store currency as integer cents? Floating point pitfalls?", expected_answer: "Binary floats not decimal-safe; use integers or decimal types; define rounding rules.", follow_ups: "FX conversion timing?", duration_minutes: 8, position: 2 },
          { section: "practical", prompt: "Webhook signature verification and replay protection.", expected_answer: "HMAC verify, timestamp tolerance, idempotent event ids, raw body.", follow_ups: "Out-of-order events?", duration_minutes: 10, position: 3 },
          { section: "coding", prompt: "Implement PaymentIntent confirm that is safe under double-submit.", expected_answer: "Idempotency key unique; state machine; transaction; no double capture.", follow_ups: "Partial capture?", duration_minutes: 25, position: 4 },
          { section: "architecture", prompt: "Double-entry ledger vs balance column — tradeoffs.", expected_answer: "Ledger append-only audit; balance as projection; reconciliation jobs.", follow_ups: "When is balance column enough?", duration_minutes: 12, position: 5 },
          { section: "system_design", prompt: "Design payouts to 1M sellers weekly.", expected_answer: "Batching, bank windows, retries, compliance holds, observability, fan-out workers.", follow_ups: "Failed bank files?", duration_minutes: 15, position: 6 },
          { section: "behavioral", prompt: "Time you slowed a launch for risk reasons.", expected_answer: "Risk articulation, alternatives, stakeholder management.", follow_ups: "How did you measure residual risk?", duration_minutes: 15, position: 7 }
        ]
      }
    end

    def self.datadog_observability
      {
        title: "Observability & Production Debugging",
        slug: "observability-production-debugging",
        introduction: "75-minute interview focused on metrics, tracing, logging, and incident response for Nest services.",
        duration_minutes: 75,
        difficulty: "hard",
        company_focus: "Datadog",
        scoring_rubric: "Debugging method 35%, observability design 30%, coding 15%, communication 20%.",
        interviewer_notes: "Give a mystery latency graph; expect hypothesis-driven debugging.",
        items: [
          { section: "introduction", prompt: "How do you instrument a new Nest service on day one?", expected_answer: "RED metrics, structured logs, traces, health/readiness, error tracking.", follow_ups: "Cardinality hazards?", duration_minutes: 5, position: 1 },
          { section: "theory", prompt: "Traces vs metrics vs logs — when each?", expected_answer: "Metrics for SLOs/alerts; traces for request path; logs for context; correlate via trace id.", follow_ups: "Sampling strategies?", duration_minutes: 8, position: 2 },
          { section: "practical", prompt: "p99 latency doubled after deploy — triage steps.", expected_answer: "Confirm deploy, compare versions, check DB/redis/deps, profiles, rollback criteria.", follow_ups: "How to prove DB regression?", duration_minutes: 10, position: 3 },
          { section: "coding", prompt: "Add a Nest interceptor that logs duration + status + route template.", expected_answer: "Interceptor timing, avoid high-cardinality paths, include request id.", follow_ups: "How to export OpenTelemetry spans?", duration_minutes: 15, position: 4 },
          { section: "architecture", prompt: "Design SLOs for a checkout API.", expected_answer: "Availability + latency SLOs, error budget, burn alerts, dependency SLIs.", follow_ups: "Multi-endpoint SLO weighting?", duration_minutes: 12, position: 5 },
          { section: "system_design", prompt: "High-cardinality metrics pipeline sketch.", expected_answer: "Aggregation, exemplars, limit labels, remote write, downsampling.", follow_ups: "Cost controls?", duration_minutes: 15, position: 6 },
          { section: "behavioral", prompt: "Hardest production incident you led.", expected_answer: "STAR with clear roles, communication cadence, blameless postmortem.", follow_ups: "What alert would have fired earlier?", duration_minutes: 10, position: 7 }
        ]
      }
    end

    def self.uber_realtime
      {
        title: "Realtime Systems (Uber-style)",
        slug: "realtime-systems-uber-style",
        introduction: "80-minute loop on WebSockets, presence, and location-ish fan-out patterns.",
        duration_minutes: 80,
        difficulty: "hard",
        company_focus: "Uber",
        scoring_rubric: "Realtime design 35%, coding 25%, scale tradeoffs 25%, behavioral 15%.",
        interviewer_notes: "Watch for sticky sessions assumptions and Redis pub/sub scale limits.",
        items: [
          { section: "introduction", prompt: "Realtime systems you've built (chat, presence, live updates)?", expected_answer: "Concrete fan-out approach and failure handling.", follow_ups: "Mobile flaky networks?", duration_minutes: 5, position: 1 },
          { section: "theory", prompt: "WebSocket vs SSE vs long polling.", expected_answer: "WS bidirectional; SSE server-push simple; polling fallback; proxies/load balancers.", follow_ups: "Auth for WS?", duration_minutes: 8, position: 2 },
          { section: "practical", prompt: "Presence heartbeats and false offline.", expected_answer: "TTL keys, grace period, last-seen, multi-device merge.", follow_ups: "Clock skew?", duration_minutes: 8, position: 3 },
          { section: "coding", prompt: "Nest gateway: join room, broadcast message, leave cleanup.", expected_answer: "Gateway handlers, rooms, disconnect hooks, auth guard on connect.", follow_ups: "Horizontal scale with Redis adapter?", duration_minutes: 20, position: 4 },
          { section: "architecture", prompt: "Where does business logic live — gateway or services?", expected_answer: "Thin gateway; domain in services; persist then fan-out.", follow_ups: "Ordering guarantees?", duration_minutes: 10, position: 5 },
          { section: "system_design", prompt: "Design city-scale driver location fan-out.", expected_answer: "Partition by geo, sampling, Kafka, WS gateways, backpressure.", follow_ups: "Hot downtown cell?", duration_minutes: 18, position: 6 },
          { section: "behavioral", prompt: "Conflict under on-call pressure.", expected_answer: "Calm triage, clear owner, escalate early.", follow_ups: "How do you coach juniors on-call?", duration_minutes: 11, position: 7 }
        ]
      }
    end

    def self.amazon_leadership
      {
        title: "Amazon L6 Backend + Leadership",
        slug: "amazon-l6-backend-leadership",
        introduction: "75-minute mix of LP behavioral and Nest/system design.",
        duration_minutes: 75,
        difficulty: "hard",
        company_focus: "Amazon",
        scoring_rubric: "Leadership Principles stories 40%, technical depth 40%, structure 20%.",
        interviewer_notes: "Dive deep on metrics and Dive Deep / Ownership / Bias for Action.",
        items: [
          { section: "introduction", prompt: "Scope of your current role and team size?", expected_answer: "Clear ownership boundary and influence.", follow_ups: "How do you prioritize?", duration_minutes: 5, position: 1 },
          { section: "behavioral", prompt: "Tell me about a time you delivered with incomplete requirements (Bias for Action).", expected_answer: "STAR with customer impact and calculated risk.", follow_ups: "What did you validate later?", duration_minutes: 10, position: 2 },
          { section: "behavioral", prompt: "Customer Obsession example with a hard tradeoff.", expected_answer: "Customer metric vs eng cost; how decided.", follow_ups: "Disagree and commit?", duration_minutes: 10, position: 3 },
          { section: "theory", prompt: "Exactly-once vs at-least-once processing.", expected_answer: "At-least-once + idempotency common; exactly-once costly/limited.", follow_ups: "Outbox pattern?", duration_minutes: 8, position: 4 },
          { section: "coding", prompt: "Implement a dedupe store for webhook event ids with TTL.", expected_answer: "Redis SET NX EX; fallback DB unique; handle races.", follow_ups: "Replay after TTL?", duration_minutes: 15, position: 5 },
          { section: "architecture", prompt: "API versioning strategy for public partners.", expected_answer: "URI or header versioning, deprecation policy, contract tests.", follow_ups: "Breaking change process?", duration_minutes: 10, position: 6 },
          { section: "system_design", prompt: "Order tracking timeline service.", expected_answer: "Event-sourced timeline, read models, privacy, scale reads.", follow_ups: "GDPR deletion?", duration_minutes: 12, position: 7 },
          { section: "practical", prompt: "How do you write an operational readiness review?", expected_answer: "Dependencies, alarms, runbooks, load test, rollback.", follow_ups: "Load test gaps?", duration_minutes: 5, position: 8 }
        ]
      }
    end

    def self.netflix_scale
      {
        title: "Netflix Scale API Design",
        slug: "netflix-scale-api-design",
        introduction: "85-minute session on resilience, caching, and high-read APIs.",
        duration_minutes: 85,
        difficulty: "hard",
        company_focus: "Netflix",
        scoring_rubric: "Resilience 30%, caching 25%, coding 20%, design 25%.",
        interviewer_notes: "Listen for chaos thinking and graceful degradation.",
        items: [
          { section: "introduction", prompt: "Highest QPS system you've worked on?", expected_answer: "Numbers + bottlenecks + mitigations.", follow_ups: "Cache hit ratio?", duration_minutes: 5, position: 1 },
          { section: "theory", prompt: "Circuit breaker vs bulkhead vs retry jitter.", expected_answer: "Isolate failures, avoid retry storms, fail fast, deadlines.", follow_ups: "Hedged requests?", duration_minutes: 8, position: 2 },
          { section: "practical", prompt: "Cache stampede prevention techniques.", expected_answer: "Locking, probabilistic early expire, singleflight, stale-while-revalidate.", follow_ups: "Negative caching?", duration_minutes: 8, position: 3 },
          { section: "coding", prompt: "Cache-aside getOrSet with singleflight in Nest service.", expected_answer: "In-process map of promises + Redis; TTL; error handling.", follow_ups: "Multi-instance stampede?", duration_minutes: 20, position: 4 },
          { section: "architecture", prompt: "Read path for personalized homepage fragments.", expected_answer: "BFF, partial failure, timeouts, fallbacks, prefetch.", follow_ups: "A/B config delivery?", duration_minutes: 14, position: 5 },
          { section: "system_design", prompt: "Design a global title metadata cache.", expected_answer: "Regional caches, invalidation pubsub, consistency model, CDN.", follow_ups: "Stale reads OK?", duration_minutes: 18, position: 6 },
          { section: "behavioral", prompt: "Time you chose availability over consistency.", expected_answer: "Clear product rationale and user messaging.", follow_ups: "How did you heal?", duration_minutes: 12, position: 7 }
        ]
      }
    end

    def self.shopify_commerce
      {
        title: "Shopify Commerce Backend",
        slug: "shopify-commerce-backend",
        introduction: "70-minute commerce domain: inventory, carts, checkout race conditions.",
        duration_minutes: 70,
        difficulty: "medium",
        company_focus: "Shopify",
        scoring_rubric: "Domain modeling 30%, concurrency 30%, coding 25%, communication 15%.",
        interviewer_notes: "Push on overselling and multi-warehouse inventory.",
        items: [
          { section: "introduction", prompt: "E-commerce systems experience?", expected_answer: "Cart/checkout/inventory specifics.", follow_ups: "Peak traffic event?", duration_minutes: 5, position: 1 },
          { section: "theory", prompt: "Soft reserve vs hard decrement inventory.", expected_answer: "TTL holds, payment auth window, release jobs, oversell risk.", follow_ups: "Multi-warehouse allocation?", duration_minutes: 8, position: 2 },
          { section: "practical", prompt: "Idempotent checkout endpoint design.", expected_answer: "Idempotency key, cart snapshot, payment intent link.", follow_ups: "Client retries mid-pay?", duration_minutes: 8, position: 3 },
          { section: "coding", prompt: "Reserve inventory with CHECK constraint / conditional UPDATE.", expected_answer: "UPDATE ... WHERE qty >= :n RETURNING; transaction with order row.", follow_ups: "Deadlocks?", duration_minutes: 18, position: 4 },
          { section: "architecture", prompt: "Modular monolith for Shop, Catalog, Checkout.", expected_answer: "Boundaries, events, shared IDs, avoid distributed monolith.", follow_ups: "App store plugins impact?", duration_minutes: 12, position: 5 },
          { section: "system_design", prompt: "Flash sale for 50k concurrent buyers one SKU.", expected_answer: "Queue, rate limit, precompute, inventory shard, UX waiting room.", follow_ups: "Fairness?", duration_minutes: 12, position: 6 },
          { section: "behavioral", prompt: "Mentoring a junior through a production bug.", expected_answer: "Teach debugging method, not just fix.", follow_ups: "How measure growth?", duration_minutes: 7, position: 7 }
        ]
      }
    end

    def self.cloudflare_edge
      {
        title: "Edge & Platform API Interview",
        slug: "edge-platform-api-interview",
        introduction: "60-minute focus on edge caching, API gateways, and multi-tenant platforms.",
        duration_minutes: 60,
        difficulty: "hard",
        company_focus: "Cloudflare",
        scoring_rubric: "Platform thinking 35%, security 25%, coding 20%, design 20%.",
        interviewer_notes: "Emphasize tenant isolation and abuse.",
        items: [
          { section: "introduction", prompt: "Multi-tenant systems you've built?", expected_answer: "Isolation model: schema/db/row + noisy neighbor.", follow_ups: "Worst tenant incident?", duration_minutes: 5, position: 1 },
          { section: "theory", prompt: "CDN cache keys and Vary headers pitfalls.", expected_answer: "Cookie/auth variance, cache poisoning, purge APIs.", follow_ups: "Stale-if-error?", duration_minutes: 6, position: 2 },
          { section: "practical", prompt: "API key auth + scoped permissions.", expected_answer: "Hashed keys at rest, prefix lookup, scopes, rotation.", follow_ups: "Leak response?", duration_minutes: 6, position: 3 },
          { section: "coding", prompt: "Implement sliding-window rate limit in Redis.", expected_answer: "ZSET timestamps or token bucket LUA; return remaining.", follow_ups: "Clock issues?", duration_minutes: 15, position: 4 },
          { section: "architecture", prompt: "Control plane vs data plane split.", expected_answer: "Config propagation, eventual consistency, blast radius.", follow_ups: "Schema evolution?", duration_minutes: 10, position: 5 },
          { section: "system_design", prompt: "Global purge API with seconds latency.", expected_answer: "Fan-out to PoPs, idempotent purge ids, verification.", follow_ups: "Partial purge failure?", duration_minutes: 10, position: 6 },
          { section: "behavioral", prompt: "Security concern you raised that delayed shipping.", expected_answer: "Risk communication and mitigation path.", follow_ups: "Would you do it again?", duration_minutes: 8, position: 7 }
        ]
      }
    end

    def self.wizdaa_nestjs
      {
        title: "Wizdaa NestJS Senior Interview",
        slug: "wizdaa-nestjs-senior",
        introduction: "70-minute NestJS-heavy interview: DI, guards, queues, Postgres, and Rails→Nest migration empathy.",
        duration_minutes: 70,
        difficulty: "medium",
        company_focus: "Wizdaa",
        scoring_rubric: "Nest fluency 30%, coding 30%, Rails migration judgment 20%, culture add 20%.",
        interviewer_notes: "Candidate may come from Rails — map concepts fairly; expect solid TypeScript.",
        items: [
          { section: "introduction", prompt: "Why NestJS over Express for your last backend?", expected_answer: "Structure, DI, testing, OpenAPI, consistency for teams.", follow_ups: "When is Nest overkill?", duration_minutes: 5, position: 1 },
          { section: "theory", prompt: "Explain Nest DI scopes: default, request, transient.", expected_answer: "Singleton default; request for ALS/user context; transient new each inject.", follow_ups: "Memory leaks with request scope?", duration_minutes: 7, position: 2 },
          { section: "practical", prompt: "Map Rails before_action + strong params to Nest.", expected_answer: "Guards + pipes/DTOs; middleware for logging; interceptors for shape.", follow_ups: "Pundit → ?", duration_minutes: 7, position: 3 },
          { section: "coding", prompt: "CRUD + soft delete + filter endpoint for Projects.", expected_answer: "Entity deletedAt; service filters; ValidationPipe; NotFound.", follow_ups: "Unique indexes with soft delete?", duration_minutes: 18, position: 4 },
          { section: "architecture", prompt: "Migrate a Rails monolith module to Nest without big-bang.", expected_answer: "Strangler fig, shared DB carefully, anti-corruption layer, dual write sparingly.", follow_ups: "Auth bridge?", duration_minutes: 12, position: 5 },
          { section: "system_design", prompt: "Notifications: in-app + email with preferences.", expected_answer: "Outbox, templates, preference service, idempotent sends.", follow_ups: "Digest emails?", duration_minutes: 12, position: 6 },
          { section: "behavioral", prompt: "Helping a Rails-heavy team adopt TypeScript/Nest.", expected_answer: "Enablement, paired mapping guides, incremental wins.", follow_ups: "Resistance handling?", duration_minutes: 9, position: 7 }
        ]
      }
    end
  end
end
