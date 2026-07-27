# frozen_string_literal: true

require_relative "../blueprint_factory"
require_relative "../catalog"

module Content
  module Banks
    module SystemDesign
      TOPICS = [
        "URL shortener at scale",
        "rate limiter service",
        "chat messaging and presence",
        "news feed fan-out strategies",
        "notification system (push/email/SMS)",
        "file upload and async processing",
        "search autocomplete",
        "idempotent payment orchestration",
        "distributed cache for sessions",
        "metrics ingestion pipeline",
        "log aggregation architecture",
        "multi-region active-active API",
        "CDN + origin shield design",
        "ticket booking / inventory holds",
        "ride matching dispatch",
        "video streaming metadata service",
        "collaborative document editing backend",
        "feature store for ML online serving",
        "webhook delivery with retries",
        "API gateway responsibilities",
        "service discovery and config",
        "distributed locking service",
        "leaderboards with Redis",
        "timeline/activity streams",
        "content moderation pipeline",
        "fraud detection streaming",
        "e-commerce checkout consistency",
        "inventory reservation with TTL",
        "coupon/redemption race safety",
        "search indexing near-realtime",
        "photo sharing thumbnail pipeline",
        "key-value store design sketch",
        "object storage metadata DB",
        "pub/sub at company scale",
        "job scheduler / cron at scale",
        "password reset secure flow design",
        "OTP / MFA enrollment system",
        "audit log immutable store",
        "GDPR deletion workflow",
        "multi-tenant SaaS isolation",
        "billing usage metering",
        "rate-limited public developer API",
        "GraphQL federation tradeoffs",
        "websocket fanout architecture",
        "geo-sharded data design",
        "read-heavy product catalog",
        "write-heavy event analytics",
        "exactly-once effect with at-least-once queues",
        "backfill and reprocessing design",
        "disaster recovery RPO/RTO design",
        "capacity planning interview approach",
        "SLO/SLA and error budget design"
      ].freeze

      def self.blueprints
        Content::BlueprintFactory.from_topics("system-design", TOPICS, per_topic: 1)
      end
    end
  end
end
