# frozen_string_literal: true

%w[javascript nodejs nestjs typescript sql postgresql].each do |name|
  begin
    require_relative name
  rescue LoadError
    # optional bank file may be missing during partial checkouts
  end
end

module Content
  module Banks
    module Languages
      module_function

      BANKS = [
        (Javascript if defined?(Javascript)),
        (Nodejs if defined?(Nodejs)),
        (Nestjs if defined?(Nestjs)),
        (Typescript if defined?(Typescript)),
        (Sql if defined?(Sql)),
        (Postgresql if defined?(Postgresql))
      ].compact.freeze

      def all
        BANKS.flat_map(&:blueprints)
      end
    end
  end
end
