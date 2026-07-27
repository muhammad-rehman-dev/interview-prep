# frozen_string_literal: true

require_relative "../blueprint_factory"
require_relative "../catalog"

module Content
  module Banks
    module Nodejs
      TOPICS = [
        "libuv threadpool saturation from fs/crypto/dns",
        "event loop phases in Node (timers, poll, check)",
        "streams backpressure and pipe error handling",
        "readable highWaterMark tuning",
        "cluster module vs worker_threads tradeoffs",
        "worker_threads shared memory and message cost",
        "unhandledRejection and uncaughtException policy",
        "graceful shutdown with open HTTP connections",
        "HTTP keep-alive agent pooling",
        "http.Server timeouts (headers/request/keepAlive)",
        "N-API / native addon crash isolation",
        "ESM vs CJS in Node packaging",
        "NODE_OPTIONS and runtime flags in production",
        "async_hooks / AsyncLocalStorage for request context",
        "diagnostics_channel for low-overhead instrumentation",
        "child_process vs worker for CPU-bound tasks",
        "buffer pooling and zero-fill semantics",
        "fs.promises vs sync APIs in request path",
        "path traversal safety with path.resolve",
        "crypto timingSafeEqual for secrets",
        "TLS session resumption and cipher config",
        "HTTP/2 multiplexing caveats in Node",
        "websocket sticky sessions behind LB",
        "memory leak: global caches without bounds",
        "heap snapshots and allocation timelines",
        "CPU profiling event-loop blocked by sync work",
        "dns.setDefaultResultOrder and Happy Eyeballs",
        "undici / fetch agent configuration",
        "multipart uploads streaming to disk/S3",
        "backpressure from slow clients (request storms)",
        "connection queueing and server.maxConnections",
        "PM2/systemd vs container orchestration responsibilities",
        "corepack/npm lockfile reproducibility",
        "native module ABI and Node upgrade pain",
        "signal handling SIGTERM vs SIGINT",
        "stdin/stdout piping in CLI tools",
        "structured clone in worker messages",
        "MessagePort as request/response channels",
        "inspector protocol for production-safe debugging",
        "OpenTelemetry context propagation in Node",
        "error-first callbacks vs promisify edge cases",
        "EventEmitter memory leaks (maxListeners)",
        "domain module deprecation lessons",
        "vm module sandbox is not a security boundary",
        "permission model / experimental policy awareness",
        "test runner vs jest in Node ecosystem",
        "SQLite in Node for local sidecars",
        "file watchers (fs.watch) reliability across OS",
        "atomic writes (write temp + rename)",
        "rate limiting at Node process edge before Redis",
        "multi-tenant AsyncLocalStorage isolation pitfalls",
        "avoiding sync require in hot paths after boot"
      ].freeze

      def self.blueprints
        Content::BlueprintFactory.from_topics("nodejs", TOPICS, per_topic: 1)
      end
    end
  end
end
