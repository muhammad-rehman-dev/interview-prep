# frozen_string_literal: true

module Content
  class CodingGenerator
    EXERCISES = [
      ["CRUD Products API", "crud", "Build NestJS CRUD for products with validation.", "REST"],
      ["JWT Auth Login", "auth-jwt", "Implement register/login/refresh with JWT.", "Auth"],
      ["Cursor Pagination", "pagination", "List endpoint with keyset pagination.", "REST"],
      ["Filtering & Sorting", "filter-sort", "Query products by price/category with sort.", "REST"],
      ["DB Transactions Checkout", "transactions", "Place order deducting inventory atomically.", "Database"],
      ["Eager Relations", "relations", "Orders with line items and user includes.", "Database"],
      ["Redis Rate Limiter", "rate-limit", "Per-API-key sliding window limiter.", "Redis"],
      ["BullMQ Email Queue", "queues", "Enqueue welcome emails with retries/DLQ.", "Queues"],
      ["Chat WebSockets", "websockets", "Room-based chat gateway with presence.", "Realtime"],
      ["Cache-Aside Posts", "caching", "Cache post by id with invalidation on update.", "Caching"],
      ["Push Notifications", "notifications", "Notify user on order status change.", "Messaging"],
      ["Order Processing FSM", "orders", "Order state machine with valid transitions.", "Domain"],
      ["Inventory Reservation", "inventory", "Hold stock with TTL then confirm/release.", "Domain"],
      ["Payment Intent Flow", "payment", "Create payment intent + webhook confirm.", "Payments"],
      ["Email Template Service", "email", "Send templated email via provider adapter.", "Messaging"],
      ["URL Shortener", "url-shortener", "Create/redirect short links with analytics event.", "System"],
      ["Chat Message History", "chat", "Persist and page chat history.", "Realtime"],
      ["File Upload S3", "file-upload", "Presigned upload + virus scan hook.", "Files"],
      ["CSV Import Jobs", "csv-import", "Stream CSV import with row error report.", "Jobs"],
      ["Full-Text Search", "search", "Search products with Postgres tsvector or OpenSearch.", "Search"],
      ["Analytics Events API", "analytics", "Ingest click events async to warehouse path.", "Analytics"],
      ["Background Image Resize", "background-jobs", "Resize images in worker process.", "Jobs"],
      ["Cron Digest Emails", "cron", "Daily digest cron with leader lock.", "Jobs"],
      ["Structured Logging", "logging", "Request-scoped logger with correlation id.", "Observability"],
      ["Health & Metrics", "monitoring", "Health checks + Prometheus metrics.", "Observability"],
      ["Idempotent POSTs", "idempotency", "Idempotency-Key middleware for payments.", "REST"],
      ["Soft Delete Users", "soft-delete", "Soft delete with unique email partial index.", "Database"],
      ["RBAC Guards", "rbac", "Role/permission guards on admin routes.", "Auth"],
      ["OAuth Login", "oauth", "Google OAuth code flow + account link.", "Auth"],
      ["Webhook Receiver", "webhooks", "Verify signatures and process webhooks idempotently.", "Integrations"],
      ["Feature Flags", "feature-flags", "Flag service with percentage rollout.", "Platform"],
      ["Multi-tenant Isolation", "multi-tenant", "Tenant id on requests + row scoping.", "Architecture"],
      ["Optimistic Locking", "optimistic-lock", "Version column conflict handling.", "Database"],
      ["Outbox Publisher", "outbox", "Transactional outbox to Kafka/Rabbit.", "Messaging"],
      ["Inbox Consumer", "inbox", "Idempotent consumer with inbox table.", "Messaging"],
      ["GraphQL Products", "graphql", "Products query with DataLoader.", "API"],
      ["gRPC Internal API", "grpc", "Expose inventory.Get via gRPC.", "API"],
      ["SSE Notifications", "sse", "Server-sent events for live order status.", "Realtime"],
      ["Search Autocomplete", "autocomplete", "Prefix autocomplete with Redis sorted sets.", "Search"],
      ["Leaderboard API", "leaderboard", "Top-N scores with Redis ZSET.", "Redis"],
      ["Slug Redirects", "redirects", "301/302 policy for short links.", "System"],
      ["Audit Log Trail", "audit-log", "Append-only audit entries on mutations.", "Security"],
      ["Password Reset", "password-reset", "Secure tokenized reset flow.", "Auth"],
      ["2FA TOTP", "totp", "Enroll and verify TOTP codes.", "Auth"],
      ["File Download ACL", "download-acl", "Authorized download of private files.", "Files"],
      ["Batch Admin Actions", "batch", "Bulk update with job progress.", "Jobs"],
      ["Saga Checkout", "saga", "Orchestrated checkout across services.", "Architecture"],
      ["Circuit Breaker Client", "circuit-breaker", "HTTP client wrapper with breaker.", "Resilience"],
      ["Config Hot Reload", "config", "Reload feature config without downtime.", "Platform"],
      ["API Versioning", "api-version", "v1/v2 products with deprecation headers.", "REST"],
      ["Contract Test Suite", "contract-tests", "Consumer-driven contract for orders API.", "Testing"],
      ["E2E Order Happy Path", "e2e", "Supertest e2e for order placement.", "Testing"]
    ].freeze

    def self.blueprints
      EXERCISES.each_with_index.map do |(title, slug, problem, category), index|
        difficulty = %w[easy easy medium medium hard][index % 5]
        {
          title: title,
          slug: slug,
          problem: "#{problem} Interviewers expect a working NestJS (or Express) design with clear modules, validation, and tests.",
          requirements: requirements_for(title, slug),
          expected_api: expected_api_for(slug),
          hints: hints_for(slug),
          step_by_step: step_by_step_for(slug),
          complete_solution: solution_for(title, slug),
          best_practices: "Validate input with DTOs; use transactions where multi-row; structured logs; idempotency for writes; tests for happy + failure paths.",
          time_complexity: "Typically O(n) over page size or batch; avoid O(n²) N+1 queries.",
          space_complexity: "O(page size) response buffers; stream large uploads/imports.",
          senior_improvements: "Add OpenTelemetry, outbox, rate limits, feature flags, and clear SLO-oriented metrics (latency, error rate, saturation).",
          follow_ups: "How do you test this? What fails at 10x load? How do you make writes idempotent? How do you observe it in production?",
          difficulty: difficulty,
          category: category,
          estimated_minutes: difficulty == "hard" ? 60 : 45,
          position: index + 1
        }
      end
    end

    def self.requirements_for(title, slug)
      <<~REQ.strip
        - Implement #{title} (#{slug}) with clear module boundaries.
        - Include validation, error mapping, and at least one persistence path.
        - Document API contracts and failure modes (400/401/404/409/429/500).
        - Provide unit or e2e test outline.
      REQ
    end

    def self.expected_api_for(slug)
      <<~API.strip
        REST-style example for #{slug}:
        POST /#{slug}
        GET /#{slug}/:id
        PATCH /#{slug}/:id
        DELETE /#{slug}/:id
        (Adjust verbs/resources to the domain; include auth headers where relevant.)
      API
    end

    def self.hints_for(slug)
      "Start from DTO + controller + service + repository. For #{slug}, identify the consistency boundary first, then pick sync vs async."
    end

    def self.step_by_step_for(slug)
      <<~STEPS.strip
        1. Clarify functional + non-functional requirements for #{slug}.
        2. Model data and invariants (uniqueness, state machine, tenancy).
        3. Define API/contracts and error taxonomy.
        4. Implement service logic with transactions/queues as needed.
        5. Add tests for success, validation failure, and concurrency/idempotency.
        6. Add logs/metrics and discuss rollout/rollback.
      STEPS
    end

    def self.solution_for(title, slug)
      <<~SOL.strip
        // NestJS sketch for: #{title}
        // app/#{slug}/#{slug}.module.ts
        import { Module } from '@nestjs/common';
        import { #{class_name(slug)}Controller } from './#{slug}.controller';
        import { #{class_name(slug)}Service } from './#{slug}.service';

        @Module({
          controllers: [#{class_name(slug)}Controller],
          providers: [#{class_name(slug)}Service],
          exports: [#{class_name(slug)}Service],
        })
        export class #{class_name(slug)}Module {}

        // service.ts — keep business rules here, not in controllers
        import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';

        @Injectable()
        export class #{class_name(slug)}Service {
          // Inject repository / queue / cache clients
          async execute(input: Record<string, unknown>) {
            // 1) validate domain invariants
            // 2) begin transaction or enqueue job when crossing systems
            // 3) persist + emit events (prefer outbox)
            // 4) return stable DTO
            if (!input) throw new NotFoundException();
            return { ok: true, feature: '#{slug}', input };
          }

          async conflictExample() {
            throw new ConflictException('idempotency or state conflict');
          }
        }

        // controller.ts — HTTP mapping only
        import { Body, Controller, Get, Param, Post } from '@nestjs/common';

        @Controller('#{slug}')
        export class #{class_name(slug)}Controller {
          constructor(private readonly service: #{class_name(slug)}Service) {}

          @Post()
          create(@Body() body: Record<string, unknown>) {
            return this.service.execute(body);
          }

          @Get(':id')
          get(@Param('id') id: string) {
            return this.service.execute({ id });
          }
        }
      SOL
    end

    def self.class_name(slug)
      slug.split("-").map(&:capitalize).join
    end
  end
end
