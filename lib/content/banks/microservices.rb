# frozen_string_literal: true

require_relative "../blueprint_factory"
require_relative "../catalog"

module Content
  module Banks
    module Microservices
      TOPICS = [
        "service boundary design heuristics",
        "distributed transactions and sagas",
        "2PC why it hurts availability",
        "choreography vs orchestration sagas",
        "API gateway vs service mesh",
        "mTLS between services",
        "service discovery (DNS vs registry)",
        "client-side vs server-side load balancing",
        "circuit breakers in mesh vs app",
        "timeout budgets across hop chains",
        "distributed tracing propagation",
        "correlation IDs in logs",
        "contract testing consumer-driven",
        "schema registry for events",
        "backward compatible event evolution",
        "versioned HTTP APIs across teams",
        "shared database anti-pattern",
        "data ownership and joins across services",
        "CQRS across service boundaries",
        "outbox for reliable event publish",
        "inbox for idempotent consumers",
        "deduplication stores",
        "async communication default vs sync",
        "bulkheads between critical paths",
        "multi-service authn (JWT vs opaque)",
        "service accounts and least privilege",
        "canary deployments per service",
        "database per service migrations",
        "strangler migration from monolith",
        "modular monolith as stepping stone",
        "team topology and service ownership",
        "platform engineering interface",
        "chaos testing microservices",
        "partial failure UX design",
        "compensation transactions",
        "eventual consistency user messaging",
        "read models rebuilt from events",
        "fan-out write amplification",
        "hot partitions in event streams",
        "poison message quarantine",
        "backfill without downtime",
        "multi-region service failover",
        "sticky sessions avoidance",
        "BFF per client experience",
        "GraphQL gateway over services",
        "gRPC vs REST for internal RPC",
        "protobuf compatibility rules",
        "sidecars for cross-cutting concerns",
        "cost of microservice sprawl",
        "observability minimum viable stack",
        "SLO composition across dependencies",
        "dependency risk scoring"
      ].freeze

      def self.blueprints
        Content::BlueprintFactory.from_topics("microservices", TOPICS, per_topic: 1)
      end
    end
  end
end
