# frozen_string_literal: true

module Content
  module Banks
    # Compiled from Wizdaa public job specs (Node/Nest senior roles), leadership notes on
    # AI-allowed assessments (ownership/architecture over generated code), and commonly
    # reported Back-End Technical Interview | Node.js – Nest.js themes.
    # Glassdoor has little Wizdaa-specific dumps (often confused with "Wiz"); content is
    # grounded in Wizdaa's published hiring signal instead of inventing fake Glassdoor IDs.
    module Wizdaa
      module_function

      def company_attrs
        {
          name: "Wizdaa",
          slug: "wizdaa",
          tagline: "Back-End Technical Interview · Node.js · Nest.js",
          description: <<~DESC.strip,
            Wizdaa screens senior backend engineers for NestJS/TypeScript ownership in an AI-first workflow.
            Expect Node/Nest depth, Postgres design, GraphQL/microservices judgment, and the ability to defend
            architecture when AI tools are allowed on assessments. Their published bar: clean structure,
            production-minded code, and explaining every decision—not paste-and-pray generation.
          DESC
          interview_focus: "Node.js, NestJS, TypeScript, Postgres, GraphQL, microservices, AI-first delivery",
          website: "https://www.wizdaa.com/",
          position: 1
        }
      end

      def blueprints
        [
          q(
            "Walk us through your NestJS module boundaries on a non-trivial service",
            "technical", "medium",
            "Wizdaa job specs emphasize designing/owning NestJS services end-to-end.",
            "I group by domain capability (OrdersModule, BillingModule), not by technical layer alone. Controllers stay thin; domain rules live in services/use-cases; persistence behind repositories/ports. Shared Kernel stays tiny. Circular deps are a smell—I extract a new module or use events. Config via dynamic ConfigModule.registerAsync. This keeps AI-generated code from sprawling into a god module.",
            "Layer-only modules (controllers/services/repos folders) that couple all domains together.",
            ["How do you decide when to split a module into a microservice?", "Where do DTOs vs domain entities live?"],
            %w[nestjs modules architecture]
          ),
          q(
            "Explain NestJS dependency injection scopes and when request scope is justified",
            "technical", "medium",
            "Nest DI is a core senior signal for Wizdaa Nest interviews.",
            "Default singleton is correct for most services. Request scope is for per-request state (tenant, ALS context) but multiplies allocations and complicates trees—any dependency of a request-scoped provider becomes request-scoped. Transient for lightweight non-shared helpers. I prefer AsyncLocalStorage + singleton services over request-scoped graphs unless a library forces it.",
            "Marking everything request-scoped 'to be safe' and tanking throughput.",
            ["How does REQUEST scope interact with GraphQL resolvers?", "How do you test request-scoped providers?"],
            %w[nestjs di scopes]
          ),
          q(
            "Guards vs interceptors vs pipes vs middleware — pick the right tool",
            "technical", "easy",
            "Classic NestJS discrimination question in Node/Nest technical rounds.",
            "Middleware: Express/Fastify-level, limited Nest DI, early. Guards: authorization gate (canActivate) after route resolved. Pipes: transform/validate params/body (ValidationPipe + DTOs). Interceptors: AOP around handler (logging, cache, map RxJS, timeout). Filters: exception → HTTP mapping. Senior answer names execution order and shows one production example each.",
            "Putting auth in interceptors or validation in controllers.",
            ["What is the Nest execution order?", "Can a guard inject a request-scoped tenant service?"],
            %w[nestjs guards interceptors pipes]
          ),
          q(
            "Design JWT auth in Nest: access + refresh, revocation, and guards",
            "technical", "medium",
            "Auth appears in Nest senior screens and take-homes.",
            "Access JWT short-lived in Authorization header; refresh in httpOnly Secure SameSite cookie or rotating store. Passport JWT strategy + AuthGuard. Roles via custom RolesGuard reading claims. Revocation: denylist jti in Redis, or version claim on user row. Never store long-lived access tokens in localStorage for sensitive apps. Document clock skew and issuer/audience checks.",
            "Infinite-lived JWTs with no revocation story.",
            ["How do you rotate refresh tokens safely?", "Session cookies vs JWT for a BFF?"],
            %w[nestjs auth jwt security]
          ),
          q(
            "How do you validate input in Nest without scattering checks?",
            "technical", "easy",
            "DTO/pipe quality is a common Nest take-home fail.",
            "class-validator + class-transformer DTOs with global ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }). Custom pipes for domain IDs. Never trust query params as numbers without transform. For GraphQL, use class-validator on input types or schema validation. Errors map to stable problem+json style envelopes.",
            "Manual if-checks in controllers; whitelist:false allowing mass assignment.",
            ["How do you version DTOs?", "How do you validate nested arrays efficiently?"],
            %w[nestjs validation dto]
          ),
          q(
            "Postgres schema design for a multi-tenant Nest API",
            "technical", "hard",
            "Wizdaa JDs explicitly require Postgres design/optimization ownership.",
            "Prefer row-level tenancy (tenant_id on tables) with composite indexes (tenant_id, …) and RLS if threat model needs DB enforcement. Avoid shared sequences that leak counts across tenants. Unique constraints must include tenant_id. Connection pooling via PgBouncer transaction mode carefully with prepared statements. Migrations expand/contract for zero-downtime.",
            "One database per tenant on day one without cost model; forgetting tenant_id in uniques.",
            ["When would you choose schema-per-tenant?", "How do you prevent cross-tenant IDOR?"],
            %w[postgresql multi-tenant schema]
          ),
          q(
            "Diagnose and fix an N+1 in Nest + ORM (TypeORM/Prisma)",
            "technical", "medium",
            "Performance ownership expected for senior Nest roles.",
            "Reproduce with query logging. Eager-load relations or use DataLoader for GraphQL. For lists, select only needed columns and paginate with keyset. Add covering indexes matching WHERE/ORDER BY. Avoid loading full graphs in loops from AI-generated repositories—review relation includes in PRs.",
            "find({ relations: everything }) on hot paths.",
            ["How do you catch N+1 in CI?", "DataLoader vs JOIN tradeoffs?"],
            %w[performance orm nestjs]
          ),
          q(
            "GraphQL in Nest microservices: when and how?",
            "architecture", "hard",
            "Multiple Wizdaa senior postings call out GraphQL across microservices.",
            "Use GraphQL as an edge BFF/federation layer, not as chatty inter-service protocol. Nest GraphQL code-first or schema-first with DataLoader. Internal service-to-service stays gRPC/REST/events. Federation/subgraph ownership boundaries match domains. Auth via context. Complexity limits and persisted queries for abuse control.",
            "Exposing every microservice as a public GraphQL endpoint.",
            ["Federation vs BFF aggregation?", "How do you version breaking GraphQL changes?"],
            %w[graphql microservices nestjs]
          ),
          q(
            "Idempotent POST /payments in Nest under retries",
            "coding", "hard",
            "Production reliability themes in Wizdaa AI-first senior roles.",
            "Require Idempotency-Key. Persist key→response in unique table inside the same transaction as the side effect (or outbox). Replay returns stored response. Combine with DB uniqueness on provider_payment_id. Controllers stay thin; domain service owns the invariant. Tests cover double-submit and concurrent keys.",
            "Relying only on client 'don't retry' guidance.",
            ["Where do you store keys—Redis or Postgres?", "How long is key TTL?"],
            %w[idempotency payments nestjs]
          ),
          q(
            "Transactional outbox from a Nest service to Kafka/Rabbit",
            "architecture", "hard",
            "Microservices reliability expected at senior level.",
            "Write business row + outbox row in one DB transaction. Publisher poller/CDC emits to broker; mark published. Consumers use inbox for idempotency. In Nest, OutboxService + cron/worker. Never 'save then publish' without dual-write protection—AI often generates that anti-pattern.",
            "Dual writes without outbox; publishing inside HTTP request without failure handling.",
            ["Polling vs Debezium?", "How do you handle poison outbox rows?"],
            %w[outbox kafka microservices]
          ),
          q(
            "Wizdaa allows AI on assessments — how do you use it without failing their bar?",
            "ai_first", "medium",
            "Leadership public note: AI allowed; <0.5% submit clean explainable code after 2000+ submissions.",
            "I use AI for scaffolding and boilerplate, then I own architecture: folder structure by domain, explicit modules, tests I can defend, no hallucinated APIs, remove dead abstractions. I can explain every tradeoff on a screen-share. I run tests locally, check security (validation, authz), and treat AI output like a junior PR—review ruthlessly.",
            "Paste generated code with AI comments, inconsistent layers, untested happy path only.",
            ["Show me a decision you overruled the model on.", "How do you keep prompts from leaking secrets?"],
            %w[ai-first ownership wizdaa]
          ),
          q(
            "Show a production-minded Nest folder structure for a take-home",
            "take_home", "medium",
            "Candidates report Wizdaa judges folder structure and purpose-driven abstractions.",
            "src/modules/<domain>/{domain.module.ts,controllers,dto,services,repositories,entities}; src/common/{filters,guards,interceptors}; src/config; test/e2e. README with how to run, env vars, design decisions. No random utils dumping ground. Feature flags/config via env validation (zod/joi). Docker-compose for Postgres when relevant.",
            "Flat src/ with 40 files; abstractions with no callers.",
            ["Why is this interface present?", "Where would auth live as the app grows?"],
            %w[take-home structure nestjs]
          ),
          q(
            "Event loop: what blocks Node in a Nest app under load?",
            "technical", "medium",
            "Node.js fundamentals in Back-End Technical Interview | Node.js – Nest.js.",
            "CPU-heavy sync work, JSON.parse of huge payloads, bcrypt sync, tight loops, and libuv threadpool saturation (fs/crypto/dns) starve the loop. Fix: move CPU to worker_threads, stream bodies, async crypto, size threadpool, break work into chunks. Measure with clinic/0x and event-loop lag metrics.",
            "Blaming Nest DI for latency that is sync crypto on the main thread.",
            ["How do you monitor event-loop delay in prod?", "When do you choose Bun/Go for a worker?"],
            %w[nodejs event-loop performance]
          ),
          q(
            "Design rate limiting for a public Nest API",
            "architecture", "medium",
            "Abuse control is part of production reliability expectations.",
            "Gateway + Redis token bucket/sliding window via atomic Lua. Key by API key/user/IP depending on trust. Return 429 with Retry-After. Fail-open vs fail-closed is a product decision—auth endpoints often fail-closed. Nest guard wrapping a RateLimitService. Separate limits for expensive routes.",
            "In-memory Map per process behind multiple replicas.",
            ["How do you rate-limit GraphQL by cost?", "What if Redis is down?"],
            %w[redis rate-limit security]
          ),
          q(
            "Testing strategy for Nest: unit vs e2e vs contract",
            "technical", "medium",
            "Wizdaa architect roles mention testing strategy ownership.",
            "Unit: TestingModule with mocked ports for domain rules. E2E: supertest against AppModule with testcontainers Postgres. Contract tests for public APIs. Prefer fewer brittle e2e, strong domain unit tests. AI-generated tests often assert mocks—rewrite to assert business outcomes.",
            "100% coverage on getters; zero failure-path tests.",
            ["How do you keep e2e hermetic in CI?", "What do you mock vs not?"],
            %w[testing nestjs jest]
          ),
          q(
            "Zero-downtime Postgres migration with Nest TypeORM/Prisma",
            "technical", "hard",
            "DB reliability ownership in Wizdaa postings.",
            "Expand/contract: add nullable column → deploy dual-write/read → backfill → constrain → remove old. Avoid long locks; use CONCURRENTLY for indexes in Postgres. Separate migration job from app boot when possible. Feature-flag readers. Never drop columns in the same release that removes code reads.",
            "ALTER TABLE rewrite locking production on large tables.",
            ["How do you backfill safely?", "Online DDL tools you trust?"],
            %w[postgresql migrations]
          ),
          q(
            "Microservices vs modular monolith for a Wizdaa-style product team",
            "architecture", "hard",
            "JDs ask for microservices judgment, not dogma.",
            "Start modular monolith with clear Nest modules and DB boundaries if team is lean. Split when independent deploy/scale/failure domains justify network cost. Use async events for decoupling. Avoid distributed monolith (shared DB + chatty sync calls). I can draw the boundary criteria: change frequency, data ownership, scale cube.",
            "Ten repos on day one with two engineers.",
            ["What metrics tell you to split?", "How do you share auth across services?"],
            %w[microservices architecture]
          ),
          q(
            "Secure a Nest file-upload endpoint",
            "technical", "medium",
            "Practical Nest coding/security theme.",
            "Presigned S3 uploads preferred; if proxied, enforce size/MIME via magic bytes not extension, virus scan async, store outside web root, authz on object ACL, random keys, rate limit. Never trust client Content-Type alone. Process images in workers.",
            "Saving user filenames into public/ and serving statically.",
            ["How do you handle multipart in Nest?", "Image bombs?"],
            %w[security uploads nestjs]
          ),
          q(
            "Explain graceful shutdown for a Nest HTTP + queue worker",
            "practical", "medium",
            "Production operations signal for senior Node.",
            "Enable Nest shutdown hooks; on SIGTERM stop traffic (K8s preStop), close server, wait in-flight with timeout, pause queue consumers, flush telemetry. Don't accept new jobs mid-drain. Health: liveness vs readiness split so LB stops routing before hard kill.",
            "process.exit(0) in the signal handler immediately.",
            ["How long should terminationGracePeriodSeconds be?", "What about WebSocket drains?"],
            %w[nodejs kubernetes kubernetes]
          ),
          q(
            "CQRS in Nest: when is it worth it?",
            "architecture", "hard",
            "Advanced Nest pattern sometimes probed for architect-track roles.",
            "Use when read/write models diverge and scale differently, or complex domain commands. Nest CQRS module: commands → handlers, events → projections. Don't use for simple CRUD—AI loves scaffolding CQRS prematurely. Start with modular services; introduce when query pain is real.",
            "CQRS folder theater with one SQL table behind both sides.",
            ["How do you handle eventual consistency UX?", "Outbox with CQRS events?"],
            %w[cqrs nestjs]
          ),
          q(
            "How would you review AI-generated Nest PR in a Wizdaa AI-first team?",
            "ai_first", "medium",
            "Core cultural ask: enforce quality on agent-generated and human code.",
            "Checklist: correct module boundaries, validation/authz, transactions/idempotency, no secrets, indexes for new queries, tests for failure paths, observability (request id, metrics), migration safety, complexity justified. I reject 'looks right' diffs. I require the author (human) to explain design aloud.",
            "Approving because tests (written by AI) are green.",
            ["Give an example of a subtle AI bug you caught.", "How do you document standards for agents?"],
            %w[code-review ai-first]
          ),
          q(
            "Live coding: implement a Nest CRUD with pagination and filtering",
            "coding", "medium",
            "Practical Back-End Technical Interview style task.",
            "Module + controller + service + DTO. Keyset pagination (id/created_at), filter whitelist mapped to query builder/Prisma where. Return { data, nextCursor }. Validate limit max. Indexes for filter+sort. E2E test for empty page and stable ordering.",
            "OFFSET pagination without warning; SQL string concat filters.",
            ["How do you sort by multiple columns stably?", "Total count expensive—what do you do?"],
            %w[coding nestjs pagination]
          ),
          q(
            "Caching strategy for a Nest read-heavy endpoint",
            "architecture", "medium",
            "Performance + Redis themes for senior backend screens.",
            "Cache-aside Redis with key versioning or tag invalidation on writes. Short TTL + jitter. Single-flight on miss. Don't cache personalized data under shared keys. Measure hit rate and stampede. Interceptor can wrap GETs carefully with auth-aware keys.",
            "Caching authenticated responses keyed only by URL.",
            ["How do you invalidate on admin updates?", "Local LRU + Redis tiering?"],
            %w[caching redis nestjs]
          ),
          q(
            "Error handling and API error contracts in Nest",
            "practical", "easy",
            "Take-homes and technical rounds expect consistent errors.",
            "Domain exceptions → HttpException filter mapping. Stable code/message/details; no stack traces to clients. Log with request id. Distinguish 400/401/403/404/409/422/429/5xx. For GraphQL, formatted errors with extensions.code. Avoid throwing raw Error from services.",
            "Returning 500 for validation failures.",
            ["Problem+JSON vs custom envelope?", "How do you map Prisma known errors?"],
            %w[nestjs errors api]
          ),
          q(
            "Behavioral: tell me about owning an ambiguous backend problem end-to-end",
            "behavioral", "medium",
            "Wizdaa emphasizes high ownership and shaping requirements before tickets.",
            "STAR: situation with fuzzy product ask → I clarified success metrics/SLOs → proposed 2 options with tradeoffs → shipped iteratively with feature flag → measured → documented. Emphasize communication with product and production accountability, not just coding speed.",
            "Story with no measurable outcome or blame-only narrative.",
            ["What would you do differently?", "How did you handle disagreement?"],
            %w[behavioral ownership]
          ),
          q(
            "System design lite: URL shortener backend on Nest + Postgres + Redis",
            "system_design", "hard",
            "Architecture depth for senior/architect tracks.",
            "API: create/redirect. ID gen (Snowflake/hash) → base62. Postgres for source of truth; Redis cache-aside on redirect hot path; 302 vs 301 tradeoff; rate limit creates; Kafka/async for click analytics. Discuss capacity, failure modes, abuse. Nest modules: Links, Analytics, edge caching.",
            "Only mentioning Redis with no durability story.",
            ["How do you handle custom aliases?", "Global unique ID without single DB bottleneck?"],
            %w[system-design nestjs]
          ),
          q(
            "EST timezone overlap and remote senior expectations",
            "screening", "basic",
            "Reported Wizdaa screening themes include timezone overlap and process fit.",
            "I confirm working hours overlapping EST/PST as required, async communication habits (clear written updates), and ownership across time zones. I ask about on-call and meeting norms. This is fit signal—be direct and professional.",
            "Dodging timezone constraints after applying to EST-aligned roles.",
            ["What does your overlap window look like?", "How do you hand off work async?"],
            %w[screening culture]
          ),
          q(
            "Security: prevent IDOR in a Nest multi-user API",
            "technical", "medium",
            "Security judgment expected when reviewing AI-generated CRUD.",
            "Every read/write scopes by currentUser.id/tenant. Prefer policy guards/CASL. Never trust client-supplied userId for ownership. Add e2e tests attempting cross-user access. Log authz failures. Review AI controllers that fetch by id without ownership clause.",
            "findById(params.id) with only JwtAuthGuard.",
            ["How do you test authz systematically?", "Row Level Security as defense in depth?"],
            %w[security idor nestjs]
          ),
          q(
            "BullMQ/queues: background jobs from Nest the right way",
            "practical", "medium",
            "Common Nest production pattern in senior interviews.",
            "Enqueue from request after commit (or via outbox). Idempotent processors, retries with backoff, DLQ, concurrency limits, named queues per workload. Don't do heavy work in HTTP handlers. Observability on job lag. Separate worker process/deployable when needed.",
            "Awaiting 30s image processing inside the controller.",
            ["How do you dedupe jobs?", "Poison message handling?"],
            %w[queues bullmq nestjs]
          ),
          q(
            "What questions would you ask Wizdaa/the client team at the end?",
            "behavioral", "basic",
            "Senior candidates should interview the company too.",
            "Ask about service ownership, on-call, AI tooling standards, code review bar, deploy frequency, Postgres ops ownership, and how architecture decisions are made on a lean team. Shows seriousness about production ownership.",
            "No questions, or only salary.",
            ["How is AI usage governed day-to-day?", "What does success look like in 90 days?"],
            %w[behavioral closing]
          )
        ]
      end

      def q(title, round, difficulty, body, answer, mistakes, follow_ups, tags)
        {
          title: title,
          body: body,
          answer: answer,
          best_answer: answer,
          explanation: "WHY this shows up for Wizdaa: their Node/Nest senior bar stresses ownership, Nest architecture, Postgres, and AI-era judgment. WHEN: #{round} round. HOW: answer with mechanism, tradeoff, and a production example. REAL-WORLD: tie to Nest modules, data safety, and explainability of your design.",
          common_mistakes: mistakes,
          follow_ups: follow_ups,
          difficulty: difficulty,
          interview_round: round,
          source: source_for(round),
          tags_cache: tags.join(", "),
          estimated_minutes: difficulty == "hard" ? 12 : (difficulty == "medium" ? 8 : 5),
          frequency_score: 0.9
        }
      end

      def source_for(round)
        case round
        when "ai_first", "take_home"
          "Wizdaa leadership notes / AI assessment guidance"
        when "screening"
          "Candidate process reports"
        when "behavioral"
          "Wizdaa senior role expectations"
        else
          "Wizdaa Back-End Technical Interview | Node.js – Nest.js themes (JD + Nest senior screens)"
        end
      end
    end
  end
end
