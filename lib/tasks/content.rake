# frozen_string_literal: true

namespace :content do
  desc "Wipe and re-seed interview content (categories, questions, tags, coding, mocks, cheatsheets, quizzes)"
  task seed: :environment do
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
  end

  desc "Seed company previous-question tracks only (e.g. Wizdaa)"
  task seed_companies: :environment do
    require Rails.root.join("lib/content/company_seeder.rb").to_s
    Content::CompanySeeder.run!
  end
end
