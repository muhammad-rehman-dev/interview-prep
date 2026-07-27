# frozen_string_literal: true

module Content
  module Catalog
    CATEGORIES = [
      { name: "JavaScript", slug: "javascript", icon: "js", target_count: 200, description: "Language internals, async model, ESNext patterns, and browser/runtime APIs for senior interviews." },
      { name: "NodeJS", slug: "nodejs", icon: "node", target_count: 100, description: "Event loop, streams, clustering, modules, and production Node.js runtime behavior." },
      { name: "NestJS", slug: "nestjs", icon: "nest", target_count: 100, description: "DI, modules, guards, interceptors, pipes, and NestJS architecture patterns." },
      { name: "SQL", slug: "sql", icon: "sql", target_count: 100, description: "Query design, joins, indexes, window functions, and performance-minded SQL." },
      { name: "TypeScript", slug: "typescript", icon: "ts", target_count: 100, description: "Type system depth, generics, utility types, and safe API/domain modeling." },
      { name: "Backend Architecture", slug: "backend-architecture", icon: "arch", target_count: 100, description: "Layering, modular monoliths, boundaries, and scalable service design." },
      { name: "REST APIs", slug: "rest-apis", icon: "api", target_count: 100, description: "HTTP semantics, resource design, versioning, idempotency, and API contracts." },
      { name: "Authentication", slug: "authentication", icon: "auth", target_count: 50, description: "Sessions, JWT, OAuth/OIDC, MFA, and auth threat models." },
      { name: "Security", slug: "security", icon: "shield", target_count: 50, description: "OWASP risks, secrets, crypto usage, and secure backend defaults." },
      { name: "Performance", slug: "performance", icon: "gauge", target_count: 50, description: "Latency budgets, profiling, concurrency, and throughput tuning." },
      { name: "Caching", slug: "caching", icon: "cache", target_count: 50, description: "Cache strategies, invalidation, stampedes, and multi-layer caching." },
      { name: "Redis", slug: "redis", icon: "redis", target_count: 50, description: "Data structures, persistence, Lua, rate limits, and Redis patterns in production." },
      { name: "RabbitMQ", slug: "rabbitmq", icon: "rabbit", target_count: 50, description: "Exchanges, queues, ACK semantics, DLQs, and messaging reliability." },
      { name: "Kafka", slug: "kafka", icon: "kafka", target_count: 50, description: "Partitions, consumer groups, exactly-once, compaction, and stream processing." },
      { name: "Docker", slug: "docker", icon: "docker", target_count: 50, description: "Images, networking, multi-stage builds, and containerized backend workflows." },
      { name: "CI/CD", slug: "ci-cd", icon: "cicd", target_count: 50, description: "Pipelines, artifact promotion, rollouts, and release safety nets." },
      { name: "Testing", slug: "testing", icon: "test", target_count: 100, description: "Unit/integration/e2e strategy, doubles, contract tests, and CI-friendly suites." },
      { name: "Design Patterns", slug: "design-patterns", icon: "patterns", target_count: 100, description: "GoF and backend patterns applied to Node/Nest services." },
      { name: "Behavioral", slug: "behavioral", icon: "people", target_count: 100, description: "Leadership, conflict, ownership, and STAR stories for senior backend roles." },
      { name: "System Design", slug: "system-design", icon: "design", target_count: 100, description: "Scalable systems: shortener, chat, feed, rate limiter, and storage tradeoffs." },
      { name: "Microservices", slug: "microservices", icon: "mesh", target_count: 100, description: "Service boundaries, sagas, discovery, resilience, and distributed data." },
      { name: "PostgreSQL", slug: "postgresql", icon: "pg", target_count: 100, description: "Indexes, transactions, locking, EXPLAIN, and Postgres-specific features." },
      { name: "Real World Debugging", slug: "real-world-debugging", icon: "bug", target_count: 100, description: "Incident-style debugging across CPU, memory, DB, and network symptoms." },
      { name: "Production Issues", slug: "production-issues", icon: "alert", target_count: 100, description: "Outages, degradations, rollback decisions, and production war stories." },
      { name: "Code Reviews", slug: "code-reviews", icon: "review", target_count: 100, description: "Review craft, API/design critique, and senior feedback patterns." }
    ].freeze

    COMPANIES = %w[
      Meta Google Amazon Netflix Uber Stripe Airbnb Shopify Datadog Cloudflare Wizdaa Startup FAANG
    ].freeze

    SOURCES = [
      "Glassdoor",
      "Reddit r/cscareerquestions",
      "Blind",
      "LeetCode Discuss",
      "Medium",
      "GitHub",
      "Engineering Blog",
      "InterviewBit",
      "GeeksforGeeks",
      "StackOverflow"
    ].freeze

    DIFFICULTY_WEIGHTS = {
      "basic" => 0.15,
      "easy" => 0.25,
      "medium" => 0.35,
      "hard" => 0.25
    }.freeze

    def self.difficulty_for(index, total)
      ratio = (index.to_f / [total, 1].max)
      cumulative = 0.0
      DIFFICULTY_WEIGHTS.each do |difficulty, weight|
        cumulative += weight
        return difficulty if ratio < cumulative
      end
      "hard"
    end

    def self.company_for(index)
      COMPANIES[index % COMPANIES.length]
    end

    def self.source_for(index)
      SOURCES[index % SOURCES.length]
    end
  end
end
