# frozen_string_literal: true

# Idempotent content seed for BackendForge interview platform.
# Prefer `bin/rails content:seed` or `bin/rails db:seed`.

require Rails.root.join("lib/content/catalog.rb").to_s

%w[
  banks
  question_generator
  question_expander
  coding_generator
  mock_generator
  cheatsheet_generator
  quiz_generator
  seeder
].each do |name|
  path = Rails.root.join("lib/content/#{name}.rb")
  require path.to_s if File.exist?(path)
end

Content::Seeder.run!

require Rails.root.join("lib/content/company_seeder.rb").to_s
Content::CompanySeeder.run!
