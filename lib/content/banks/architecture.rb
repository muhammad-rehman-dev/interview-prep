# frozen_string_literal: true

module Content
  module Banks
    module Architecture
      def self.all
        %w[
          backend_architecture
          rest_apis
          authentication
          security
          performance
          caching
          design_patterns
          system_design
          microservices
        ].flat_map do |name|
          require_relative name
          mod = {
            "backend_architecture" => BackendArchitecture,
            "rest_apis" => RestApis,
            "authentication" => Authentication,
            "security" => Security,
            "performance" => Performance,
            "caching" => Caching,
            "design_patterns" => DesignPatterns,
            "system_design" => SystemDesign,
            "microservices" => Microservices
          }.fetch(name)
          Array(mod.blueprints)
        rescue LoadError, NameError => e
          warn "[Architecture] #{name}: #{e.message}"
          []
        end
      end
    end
  end
end
