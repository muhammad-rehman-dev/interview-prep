# frozen_string_literal: true

module Content
  class CompanySeeder
    def self.run!
      new.run!
    end

    def run!
      require_relative "banks/wizdaa"

      puts "[Content::CompanySeeder] seeding companies…"
      wizdaa = seed_company!(Content::Banks::Wizdaa.company_attrs)
      seed_questions!(wizdaa, Content::Banks::Wizdaa.blueprints)
      puts "[Content::CompanySeeder] #{Company.count} companies, #{CompanyQuestion.count} company questions"
    end

    private

    def seed_company!(attrs)
      company = Company.find_or_initialize_by(slug: attrs[:slug])
      company.assign_attributes(attrs)
      company.save!
      company
    end

    def seed_questions!(company, blueprints)
      company.company_questions.delete_all
      now = Time.current

      rows = blueprints.each_with_index.map do |bp, index|
        {
          company_id: company.id,
          title: bp[:title],
          slug: bp[:title].to_s.parameterize,
          body: bp[:body],
          answer: bp[:answer],
          best_answer: bp[:best_answer],
          explanation: bp[:explanation],
          common_mistakes: bp[:common_mistakes],
          follow_ups: Array(bp[:follow_ups]).join("\n"),
          difficulty: bp[:difficulty],
          interview_round: bp[:interview_round],
          source: bp[:source],
          tags_cache: bp[:tags_cache],
          estimated_minutes: bp[:estimated_minutes] || 8,
          position: index + 1,
          frequency_score: bp[:frequency_score] || 0.85,
          created_at: now,
          updated_at: now
        }
      end

      # ensure unique slugs within batch
      seen = {}
      rows.each do |row|
        base = row[:slug]
        n = 1
        while seen[row[:slug]]
          row[:slug] = "#{base}-#{n}"
          n += 1
        end
        seen[row[:slug]] = true
      end

      CompanyQuestion.insert_all(rows) if rows.any?
    end
  end
end
