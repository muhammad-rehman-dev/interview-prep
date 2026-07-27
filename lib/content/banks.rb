# frozen_string_literal: true

module Content
  module Banks
    def self.all_blueprints
      Dir[Rails.root.join("lib/content/banks/**/*.rb")].sort.each do |file|
        require file
      rescue LoadError, NameError => e
        warn "[Content::Banks] failed to load #{file}: #{e.message}"
      end

      collect_blueprints_from(self)
    end

    def self.collect_blueprints_from(mod, seen = {})
      return [] if seen[mod.object_id]

      seen[mod.object_id] = true
      blueprints = []

      if mod.respond_to?(:blueprints) && mod.method(:blueprints).arity == 0
        begin
          blueprints.concat(Array(mod.blueprints))
        rescue StandardError => e
          warn "[Content::Banks] #{mod}.blueprints failed: #{e.message}"
        end
      end

      mod.constants(false).each do |const_name|
        child =
          begin
            mod.const_get(const_name)
          rescue NameError
            next
          end

        next unless child.is_a?(Module)

        blueprints.concat(collect_blueprints_from(child, seen))
      end

      blueprints
    end
    private_class_method :collect_blueprints_from
  end
end
