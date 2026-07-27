# frozen_string_literal: true

require_relative "../blueprint_factory"
require_relative "../catalog"

module Content
  module Banks
    module Nestjs
      TOPICS = [
        "DI container scopes: singleton, request, transient",
        "module boundaries and circular dependency avoidance",
        "dynamic modules and registerAsync config factories",
        "guards for authz vs middleware responsibilities",
        "interceptors for cross-cutting caching/logging",
        "pipes for validation with class-validator DTOs",
        "exception filters and stable error contracts",
        "custom providers and useFactory patterns",
        "TestingModule unit vs e2e strategies",
        "CQRS module: commands, queries, events",
        "hybrid application HTTP + microservice transport",
        "RabbitMQ/Kafka microservice message patterns",
        "GraphQL resolvers with DataLoader to avoid N+1",
        "Passport strategies integrated via guards",
        "ConfigModule namespaces and validation schema",
        "bull/bullmq queues with Nest processors",
        "scheduled tasks (@Cron) and leader election",
        "Versioning (URI/header) in Nest controllers",
        "Serialization interceptors and class-transformer",
        "request-scoped providers and performance cost",
        "module ref and lazy getting providers",
        "health checks Terminus patterns",
        "OpenAPI/Swagger plugin accuracy limits",
        "global vs feature module providers",
        "forwardRef when circular is unavoidable",
        "custom decorators with createParamDecorator",
        "execution context switching HTTP/RPC/WS",
        "WebSockets gateway auth and rooms",
        "SSE streaming responses",
        "file upload with multer limits and storage",
        "Prisma/TypeORM integration boundaries",
        "transactions with CLS / Unit of Work",
        "outbox publisher as a Nest injectable",
        "multi-tenancy with request-scoped tenancy",
        "rate limiting guards with Redis",
        "idempotency interceptor design",
        "graceful shutdown hooks in Nest",
        "monorepo Nest apps and shared libraries",
        "hexagonal ports as Nest providers",
        "strangler pattern migrating Express to Nest",
        "logging with Pino and request ids",
        "metrics interceptor for RED method",
        "contract testing Nest controllers",
        "feature flags provider",
        "policy-based authorization beyond roles",
        "DTO versioning and mapping layers",
        "background job retries and DLQ handling",
        "Nest microservices acknowledgement semantics",
        "avoiding god modules",
        "lifecycle events onModuleInit ordering",
        "hot reload vs production bootstrap differences",
        "security headers middleware in Nest"
      ].freeze

      def self.blueprints
        Content::BlueprintFactory.from_topics("nestjs", TOPICS, per_topic: 1)
      end
    end
  end
end
