# frozen_string_literal: true

require_relative "../blueprint_factory"
require_relative "../catalog"

module Content
  module Banks
    module DesignPatterns
      TOPICS = [
        "strategy for payment providers",
        "factory for multi-tenant clients",
        "abstract factory vs factory method",
        "builder for complex query objects",
        "singleton pitfalls in Nest DI",
        "prototype for costly config clones",
        "adapter for legacy SOAP/HTTP APIs",
        "bridge for multi-channel notifications",
        "composite for permission trees",
        "decorator for cross-cutting policies",
        "facade for checkout orchestration",
        "flyweight for shared catalog data",
        "proxy for lazy remote services",
        "chain of responsibility for middleware",
        "command for auditable mutations",
        "interpreter for rule engines",
        "iterator for paginated resources",
        "mediator for chat room fanout",
        "memento for undo drafts",
        "observer for domain events",
        "state machine for order lifecycle",
        "template method for ingest pipelines",
        "visitor for AST-like policy docs",
        "repository vs DAO boundaries",
        "unit of work / transaction boundary",
        "specification for search filters",
        "circuit breaker around dependencies",
        "retry with jitter and budgets",
        "bulkhead isolation pools",
        "timeout + deadline propagation",
        "saga / process manager",
        "outbox / inbox patterns",
        "CQRS read/write split",
        "event sourcing when justified",
        "anti-corruption layer",
        "hexagonal ports and adapters",
        "dependency inversion in Nest modules",
        "null object for missing integrations",
        "object pool for expensive clients",
        "ambassador sidecar pattern",
        "strangler fig migrations",
        "feature toggle pattern",
        "gateway aggregation pattern",
        "backend for frontend (BFF)",
        "sidecar for auth/rate-limit",
        "leader election pattern",
        "claim check for large payloads",
        "competing consumers",
        "priority queue processing",
        "scheduler agent supervisor",
        "tolerant reader for schema evolution",
        "correlation ID propagation"
      ].freeze

      def self.blueprints
        Content::BlueprintFactory.from_topics("design-patterns", TOPICS, per_topic: 1)
      end
    end
  end
end
