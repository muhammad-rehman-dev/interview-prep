# frozen_string_literal: true

module Content
  class QuizGenerator
    BANK = [
      ["What phase runs Promise microtasks relative to setTimeout(0)?", ["Before the next macrotask", "After all timers only", "Only on next tick of OS", "Never interleaved"], 0, "javascript", "Microtasks drain after the current task and before the next macrotask (including timers)."],
      ["Which Node pool do fs/crypto/dns DNS lookups often share?", ["libuv threadpool", "V8 GC threads only", "Only the main thread always", "PostgreSQL pool"], 0, "nodejs", "Many expensive ops use libuv's threadpool; saturation blocks unrelated work."],
      ["NestJS Guard primary purpose?", ["Authorization/authentication gates", "Transform response bodies", "Validate DTO fields only", "Open DB transactions"], 0, "nestjs", "Guards decide whether a route can run; pipes validate; interceptors wrap."],
      ["Best pagination at scale?", ["Keyset/cursor", "Large OFFSET", "SELECT * client filter", "Random SAMPLE always"], 0, "sql", "OFFSET scans/discards rows; keyset uses a seek on indexed columns."],
      ["Postgres MVCC helps with?", ["Readers not blocking writers (generally)", "Eliminating VACUUM forever", "Replacing all indexes", "Guaranteeing exactly-once Kafka"], 0, "postgresql", "MVCC keeps row versions; VACUUM still required to reclaim."],
      ["JWT vs session cookie tradeoff?", ["JWT: stateless API scaling; sessions: easier revocation", "JWT always more secure", "Sessions cannot be horizontal", "No difference"], 0, "authentication", "Revocation and rotation differ; choose based on threat model."],
      ["Cache stampede mitigation?", ["Single-flight + jittered TTL", "TTL=0 for all keys", "Disable cache on error forever", "Store only on client"], 0, "caching", "Prevent thundering herd with coalescing and TTL jitter."],
      ["Redis sliding window limiter structure?", ["Sorted set + Lua atomic trim/count", "STRING INCR only forever", "LIST without TTL", "GRAPH"], 0, "redis", "ZSET scores as timestamps + Lua keeps check atomic."],
      ["Kafka consumer group purpose?", ["Partition work across consumers", "Encrypt messages", "Replace ZooKeeper always", "Guarantee sync HTTP"], 0, "kafka", "Groups share partitions; rebalances on membership change."],
      ["At-least-once delivery implies?", ["Consumers must be idempotent", "Duplicates never happen", "Exactly-once free", "No need for acks"], 0, "rabbitmq", "Retries/redelivery create duplicates; design idempotent handlers."],
      ["Docker multi-stage builds help?", ["Smaller final images / hide build tools", "Faster CPU in prod", "Replace healthchecks", "Avoid networking"], 0, "docker", "Build stages compile; runtime stage copies artifacts only."],
      ["Canary deploy key metric?", ["Error rate/latency vs baseline", "Only CPU of canary", "Git commit count", "Number of feature flags"], 0, "ci-cd", "Promote when SLOs hold; auto-rollback on regression."],
      ["Circuit breaker opens when?", ["Error rate/latency exceeds threshold", "First timeout ever", "Deploy starts", "GC runs"], 0, "design-patterns", "Fail fast to protect dependency and caller; half-open to probe."],
      ["Saga pattern used for?", ["Multi-service business transaction with compensations", "Local DB unique index", "TLS termination", "CSS bundling"], 0, "microservices", "Coordinate steps without 2PC; compensate on failure."],
      ["URL shortener hot path optimization?", ["Cache short→long in Redis", "Join 12 tables sync", "Store only in CDN logs", "SHA plaintext passwords"], 0, "system-design", "Redirects are read-heavy; cache-aside is classic."],
      ["N+1 in Nest/ORM fixed by?", ["Eager load / DataLoader / join", "More nested loops", "Disable indexes", "Larger Docker mem only"], 0, "performance", "Batch associations; measure query count."],
      ["Idempotency-Key header helps?", ["Safe retries of POST payments", "Faster GET caching only", "CORS", "Gzip"], 0, "rest-apis", "Store request hash→response for replay."],
      ["Row Level Security in Postgres?", ["DB-enforced per-row policies", "App-only middleware", "Redis ACL", "JWT signature"], 0, "postgresql", "Policies apply even if app bugs."],
      ["AsyncLocalStorage use?", ["Request-scoped context without param drilling", "Replace Redis", "Stop GC", "Compile TypeScript"], 0, "nodejs", "Propagate request ids/tenant across async hops."],
      ["TypeScript satisfies keyword?", ["Check type without widening value", "Emit runtime checks", "Replace zod", "Disable strictNullChecks"], 0, "typescript", "Validates value against type while keeping inferred form."]
    ].freeze

    CATEGORIES = %w[
      javascript nodejs nestjs typescript sql postgresql backend-architecture rest-apis
      authentication security performance caching redis rabbitmq kafka docker ci-cd
      testing design-patterns behavioral system-design microservices real-world-debugging
      production-issues code-reviews
    ].freeze

    def self.blueprints
      base = BANK.each_with_index.map do |(prompt, options, correct_index, category, explanation), i|
        {
          prompt: prompt,
          options: options,
          correct_index: correct_index,
          explanation: explanation,
          category: category,
          difficulty: %w[basic easy medium hard][i % 4]
        }
      end

      # Expand to 150+ with templated but distinct prompts
      extra = []
      CATEGORIES.each_with_index do |cat, ci|
        6.times do |n|
          idx = ci * 6 + n
          correct = idx % 4
          options = [
            "Prefer measurable SLOs and failure-mode thinking",
            "Ignore observability and ship fastest prototype",
            "Always pick the newest database",
            "Optimize before measuring"
          ]
          # rotate correct answer text into correct index
          options[0], options[correct] = options[correct], options[0] if correct != 0
          extra << {
            prompt: "Senior #{cat} check ##{n + 1}: which answer best reflects production judgment?",
            options: options,
            correct_index: correct,
            explanation: "For #{cat}, seniors prioritize failure modes, measurements, and reversible changes over dogma.",
            category: cat,
            difficulty: %w[basic easy medium hard][n % 4]
          }
        end
      end

      (base + extra).first(160)
    end
  end
end
