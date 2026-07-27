# frozen_string_literal: true

require_relative "redis"
require_relative "rabbitmq"
require_relative "kafka"
require_relative "docker"
require_relative "ci_cd"
require_relative "testing"
require_relative "behavioral"
require_relative "real_world_debugging"
require_relative "production_issues"
require_relative "code_reviews"

module Content
  module Banks
    module Ops
      module_function

      BANKS = [
        Redis,
        Rabbitmq,
        Kafka,
        Docker,
        CiCd,
        Testing,
        Behavioral,
        RealWorldDebugging,
        ProductionIssues,
        CodeReviews
      ].freeze

      def all
        BANKS.flat_map(&:blueprints)
      end
    end
  end
end
