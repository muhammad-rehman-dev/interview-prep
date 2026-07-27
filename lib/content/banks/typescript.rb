# frozen_string_literal: true

require_relative "../blueprint_factory"
require_relative "../catalog"

module Content
  module Banks
    module Typescript
      TOPICS = [
        "strict mode flags that change API design",
        "generics variance and extends constraints",
        "conditional types and infer",
        "mapped types for DTO transforms",
        "template literal types for route params",
        "branded/opaque types for IDs",
        "satisfies operator vs type annotation",
        "const assertions and readonly tuples",
        "discriminated unions and exhaustive switches",
        "never for impossibility proofs",
        "unknown vs any at trust boundaries",
        "type predicates and assertion functions",
        "declaration merging pitfalls",
        "module augmentation for third-party libs",
        "enums vs union literals in public APIs",
        "namespace legacy vs ES modules",
        "utility types Pick/Omit/Exclude tradeoffs",
        "ReturnType and Parameters for wrappers",
        "ThisParameterType and fluent APIs",
        "overload signatures for DX vs implementation",
        "function types vs callable interfaces",
        "index signatures vs Records",
        "excess property checks and widening",
        "structural typing surprises across packages",
        "project references in monorepos",
        "path mapping and runtime reality",
        "verbatimModuleSyntax / isolatedModules",
        "emitDecoratorMetadata needs for Nest",
        "zod/io-ts runtime validation with inferred types",
        "type-safe env config parsing",
        "Result/Either patterns in TS",
        "exhaustive API error unions",
        "generic repository interfaces",
        "variance of Array and Promise",
        "covariant callback parameter traps",
        "readonly deep types limitations",
        "satisfies for config objects",
        "import type and elision",
        "ts-reset / stricter defaults philosophy",
        "generating types from OpenAPI",
        "prisma generated types in services",
        "testing types with expectTypeOf",
        "avoiding circular type aliases",
        "JSON typed parse helpers",
        "narrowing with in and instanceof",
        "control flow analysis limits",
        "assertion + validation must stay in sync",
        "public API .d.ts design",
        "semver for type-only breaking changes",
        "gradual migration from JS allowJs",
        "performance of complex conditional types",
        "type instantiation depth errors"
      ].freeze

      def self.blueprints
        Content::BlueprintFactory.from_topics("typescript", TOPICS, per_topic: 1)
      end
    end
  end
end
