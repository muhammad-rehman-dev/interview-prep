# frozen_string_literal: true

module Content
  # Fills a category up to Catalog target_count with senior-quality scenario
  # variants when bank blueprints are insufficient. Never invents childish filler.
  class QuestionExpander
    ANGLES = [
      {
        key: "production-incident",
        label: "Production incident",
        prompt: "Walk through how you would diagnose and mitigate this in a live production incident",
        answer_lens: "Start with blast radius and SLOs, isolate the failing path, apply a reversible mitigation, then prove the root cause with telemetry before a lasting fix.",
        mistakes: "Restarting blindly, changing multiple variables at once, or skipping a post-incident write-up."
      },
      {
        key: "design-tradeoff",
        label: "Design tradeoff",
        prompt: "Compare the main design tradeoffs and explain when you would choose each approach",
        answer_lens: "Frame options against consistency, latency, operational cost, and team complexity. State a recommendation with explicit rejection criteria.",
        mistakes: "Treating one pattern as universally correct, or ignoring operational ownership cost."
      },
      {
        key: "debugging",
        label: "Debugging angle",
        prompt: "Describe your debugging playbook when symptoms point at this topic under load",
        answer_lens: "Reproduce safely, bisect with metrics/logs/traces, form a falsifiable hypothesis, and validate with a minimal experiment before shipping a fix.",
        mistakes: "Optimizing from intuition, missing saturation signals, or conflating correlation with causation."
      },
      {
        key: "performance",
        label: "Performance angle",
        prompt: "How would you measure and improve performance related to this topic?",
        answer_lens: "Define a latency/throughput budget, profile the hot path, quantify the win, and guard the fix with regression benchmarks and alerts.",
        mistakes: "Micro-optimizing cold paths, skipping p99, or ignoring backpressure and queueing delay."
      },
      {
        key: "security",
        label: "Security angle",
        prompt: "What security risks appear around this topic and how do you harden them?",
        answer_lens: "Threat-model trust boundaries, enforce least privilege, validate inputs/outputs, and add detection for abuse or secret leakage.",
        mistakes: "Security theater, storing secrets in config repos, or trusting internal network traffic by default."
      }
    ].freeze

    # Senior topic seeds used when a category has few or no bank blueprints.
    TOPIC_SEEDS = {
      "javascript" => [
        "event loop phases and microtasks",
        "closures and memory retention",
        "Promises vs async/await error paths",
        "structuredClone and transferable objects",
        "module loading and circular dependencies",
        "WeakMap/WeakRef for cache lifetimes",
        "AbortController for cancellation",
        "prototype chain vs class private fields"
      ],
      "nodejs" => [
        "libuv threadpool saturation",
        "streams backpressure",
        "cluster vs worker_threads",
        "unhandledRejection process policy",
        "N-API / native addon failure modes",
        "HTTP keep-alive and agent pooling",
        "graceful shutdown with open connections",
        "CPU-bound work starving the event loop"
      ],
      "nestjs" => [
        "DI scopes (singleton/request/transient)",
        "guards vs interceptors vs middleware",
        "dynamic modules and config factories",
        "exception filters and error contracts",
        "CQRS / event buses inside Nest",
        "testing with TestingModule",
        "hybrid HTTP + microservice apps",
        "provider lifetime leaks across requests"
      ],
      "sql" => [
        "covering indexes and index-only scans",
        "window functions for ranking",
        "JOIN algorithms and selectivity",
        "NULL semantics in UNIQUE constraints",
        "UPSERT / ON CONFLICT races",
        "pagination keyset vs OFFSET",
        "deadlocks from lock ordering",
        "write amplification from wide indexes"
      ],
      "typescript" => [
        "conditional types and infer",
        "variance in generics",
        "branded types for domain IDs",
        "exhaustive switch with never",
        "declaration merging pitfalls",
        "strict null checks across API boundaries",
        "utility types for DTO mapping",
        "type-safe builder / fluent APIs"
      ],
      "backend-architecture" => [
        "modular monolith boundaries",
        "hexagonal / ports-and-adapters",
        "sync vs async service communication",
        "data ownership and anti-corruption layers",
        "idempotent command handlers",
        "outbox pattern for reliable events",
        "read models and CQRS split",
        "feature flags for dark launches"
      ],
      "rest-apis" => [
        "idempotency keys for POST",
        "resource vs RPC-style endpoints",
        "API versioning strategies",
        "HATEOAS usefulness in practice",
        "partial updates and PATCH semantics",
        "cursor pagination contracts",
        "error envelope design",
        "rate-limit headers and 429 behavior"
      ],
      "authentication" => [
        "sessions vs JWT tradeoffs",
        "refresh token rotation",
        "OAuth/OIDC authorization code + PKCE",
        "MFA enrollment and recovery",
        "service-to-service mTLS",
        "cookie security flags",
        "token revocation and logout",
        "impersonation / break-glass access"
      ],
      "security" => [
        "OWASP injection classes",
        "SSRF from URL fetching",
        "secrets rotation without downtime",
        "CSP and XSS defenses for APIs serving HTML",
        "mass assignment / overposting",
        "timing attacks on comparisons",
        "dependency supply-chain risk",
        "PII minimization and encryption at rest"
      ],
      "performance" => [
        "p99 latency budgets",
        "connection pool sizing",
        "N+1 query elimination",
        "async fan-out and head-of-line blocking",
        "GC / memory churn under load",
        "cache stampede prevention",
        "bulkheads and concurrency limits",
        "load test design that mirrors production"
      ],
      "caching" => [
        "cache-aside vs write-through",
        "TTL vs explicit invalidation",
        "thundering herd / stampede",
        "multi-layer CDN + app + DB caches",
        "negative caching for misses",
        "hot key splitting",
        "consistency windows after writes",
        "serialization cost of large values"
      ],
      "redis" => [
        "Redis data structures for rate limits",
        "Lua for atomic multi-key ops",
        "AOF vs RDB persistence",
        "Redis Cluster hash slots",
        "hot keys and key eviction",
        "pubsub vs streams",
        "memory policies under pressure",
        "distributed locks and fencing tokens"
      ],
      "rabbitmq" => [
        "exchange types and routing keys",
        "ACK / NACK / requeue semantics",
        "dead-letter queues",
        "publisher confirms",
        "prefetch and consumer fairness",
        "poison message handling",
        "quorum queues vs classic",
        "at-least-once delivery duplicates"
      ],
      "kafka" => [
        "partition key design",
        "consumer group rebalancing",
        "exactly-once semantics limits",
        "log compaction use cases",
        "idempotent producers",
        "lag monitoring and backfill",
        "schema evolution with registries",
        "poison pill records in a partition"
      ],
      "docker" => [
        "multi-stage builds",
        "image layer caching",
        "PID 1 and signal handling",
        "read-only root filesystem",
        "network modes and service discovery",
        "resource limits vs thrashing",
        "secrets in containers",
        "healthchecks that reflect readiness"
      ],
      "ci-cd" => [
        "artifact promotion across environments",
        "progressive delivery / canaries",
        "pipeline caching without flakiness",
        "DB migrations in zero-downtime deploys",
        "supply-chain signing of images",
        "rollback criteria and automation",
        "flaky test quarantine policy",
        "environment parity gaps"
      ],
      "testing" => [
        "test pyramid for Nest/Node APIs",
        "contract tests between services",
        "time-dependent test isolation",
        "testcontainers for integration",
        "doubles: mock vs stub vs fake",
        "flaky async assertions",
        "mutating shared fixtures",
        "coverage vs risk-based testing"
      ],
      "design-patterns" => [
        "strategy for payment providers",
        "circuit breaker around dependencies",
        "retry with jitter",
        "saga / process manager",
        "repository vs DAO boundaries",
        "factory for multi-tenant clients",
        "observer for domain events",
        "decorator for cross-cutting policies"
      ],
      "behavioral" => [
        "leading an incident under pressure",
        "disagreement with a staff engineer",
        "owning a missed deadline",
        "mentoring through a production bug",
        "saying no to scope with data",
        "cross-team dependency failure",
        "raising quality bar in reviews",
        "communicating risk to non-engineers"
      ],
      "system-design" => [
        "URL shortener at scale",
        "rate limiter service",
        "chat / presence system",
        "news feed fan-out",
        "file upload and processing pipeline",
        "multi-region active-active",
        "search autocomplete",
        "idempotent payment orchestration"
      ],
      "microservices" => [
        "service boundary design",
        "distributed transactions / sagas",
        "service discovery and mesh",
        "shared database anti-pattern",
        "API gateway responsibilities",
        "resilience: timeouts and retries",
        "eventual consistency UX",
        "deploying breaking contract changes"
      ],
      "postgresql" => [
        "MVCC and bloat",
        "EXPLAIN (ANALYZE, BUFFERS)",
        "advisory locks",
        "partial and expression indexes",
        "LISTEN/NOTIFY patterns",
        "partitioning large tables",
        "transaction isolation levels",
        "connection pooling with PgBouncer"
      ],
      "real-world-debugging" => [
        "CPU pegged on one Node process",
        "memory leak in a long-lived worker",
        "intermittent 504s behind a proxy",
        "DB CPU high with low QPS",
        "mysterious lock waits",
        "GC pauses causing tail latency",
        "wrong region / sticky session bugs",
        "clock skew breaking tokens"
      ],
      "production-issues" => [
        "bad deploy causing error budget burn",
        "cache stampedes after expiry",
        "queue backlog meltdown",
        "certificate expiry outage",
        "noisy neighbor in shared infra",
        "partial region failure",
        "data corruption from dual writes",
        "on-call fatigue and alert noise"
      ],
      "code-reviews" => [
        "API contract review checklist",
        "catching N+1 in a PR",
        "migration safety review",
        "security-sensitive auth changes",
        "giving feedback without bikeshedding",
        "reviewing generated / AI-assisted code",
        "performance regressions in hot paths",
        "rollout and feature-flag review"
      ]
    }.freeze

    class << self
      # Returns an Array of blueprint hashes totaling at least target_count (capped to target).
      def expand(blueprints, category, target_count)
        target = target_count.to_i
        existing = Array(blueprints).map { |bp| stringify_keys(bp) }
        return existing.first(target) if existing.size >= target

        needed = target - existing.size
        seeds = topic_seeds_for(category, existing)
        variants = []
        index = 0

        while variants.size < needed
          topic = seeds[index % seeds.length]
          angle = ANGLES[index % ANGLES.length]
          source_bp = existing[index % [existing.length, 1].max] if existing.any?
          variants << build_variant(topic, angle, category, existing.size + variants.size, source_bp)
          index += 1

          # Safety: avoid infinite loops if seeds somehow empty
          break if index > needed * 5 && variants.size >= needed
        end

        existing + variants.first(needed)
      end

      private

      def stringify_keys(hash)
        return {} unless hash.respond_to?(:each_pair)

        hash.each_with_object({}) do |(key, value), memo|
          memo[key.to_s] = value
        end
      end

      def topic_seeds_for(category, existing)
        from_catalog = Array(TOPIC_SEEDS[category.slug]).dup
        from_titles = existing.map { |bp| extract_topic(bp) }.reject(&:blank?)
        seeds = (from_catalog + from_titles).uniq
        return seeds if seeds.any?

        ["core #{category.name} production concerns"]
      end

      def extract_topic(blueprint)
        title = blueprint["title"].to_s.strip
        return title if title.present?

        blueprint["body"].to_s.split(/[.?\n]/).first.to_s.strip.presence
      end

      def build_variant(topic, angle, category, index, source_bp)
        topic_text = topic.to_s.strip
        tags = %W[#{category.slug} #{angle[:key]} senior]
        tags.concat(Array(source_bp && source_bp["tags"])).map!(&:to_s)
        tags = tags.reject(&:blank?).uniq

        base_answer = source_bp && (source_bp["best_answer"].presence || source_bp["answer"].presence)

        {
          title: "#{angle[:label]}: #{topic_text}",
          body: "#{angle[:prompt]} for: #{topic_text}. Ground the answer in a realistic #{category.name} backend system at senior scope.",
          answer: compose_answer(topic_text, angle, category, base_answer),
          best_answer: compose_best_answer(topic_text, angle, category, base_answer),
          alternative_answer: compose_alternative(topic_text, angle, category),
          explanation: compose_explanation(topic_text, angle, category),
          common_mistakes: angle[:mistakes],
          follow_ups: follow_ups_for(topic_text, angle),
          difficulty: Content::Catalog.difficulty_for(index, category.target_count),
          interview_type: infer_interview_type(angle, category.slug),
          company: Content::Catalog.company_for(index),
          source: Content::Catalog.source_for(index),
          tags: tags,
          frequency_score: (0.9 - (index * 0.002)).clamp(0.4, 0.9).round(2),
          estimated_minutes: angle[:key] == "design-tradeoff" ? 10 : 8,
          confidence_score: 0.78,
          references_text: "Senior interview scenario variant on #{topic_text} (#{angle[:key]})",
          category_slug: category.slug
        }
      end

      def compose_answer(topic, angle, category, base_answer)
        prefix = "#{angle[:answer_lens]} Applied to #{topic} in #{category.name}:"
        if base_answer.present?
          "#{prefix} Reuse the core technical points from the related topic, then emphasize the #{angle[:label].downcase} lens — sequence, instrumentation, and decision criteria matter as much as the mechanism."
        else
          "#{prefix} Explain the mechanism, when it bites in production, how you detect it, and the concrete mitigation you would ship first."
        end
      end

      def compose_best_answer(topic, angle, category, base_answer)
        compose_answer(topic, angle, category, base_answer)
      end

      def compose_alternative(topic, angle, category)
        "Alternative framing: teach the same #{topic} concept via a short war story — symptom, hypothesis, disconfirming evidence, fix, and prevention — tailored to #{category.name} and the #{angle[:label].downcase} angle."
      end

      def compose_explanation(topic, angle, category)
        "Interviewers use the #{angle[:label].downcase} angle on #{topic} to test senior judgment: not just definitions, but production instincts in #{category.name}."
      end

      def follow_ups_for(topic, angle)
        [
          "What metrics would you watch first for #{topic}?",
          "How would you roll back or mitigate if the #{angle[:key].tr('-', ' ')} response made things worse?",
          "What would you automate after seeing this twice?"
        ]
      end

      def infer_interview_type(angle, category_slug)
        return "behavioral" if category_slug == "behavioral"
        return "system_design" if category_slug == "system-design"
        return "database" if %w[sql postgresql].include?(category_slug)
        return "architecture" if %w[design-tradeoff].include?(angle[:key]) ||
                                 %w[backend-architecture microservices design-patterns].include?(category_slug)
        return "practical" if %w[production-incident debugging].include?(angle[:key])

        "theory"
      end
    end
  end
end
