# frozen_string_literal: true

require "set"

module Content
  class Seeder
    BATCH_SIZE = 500

    class << self
      def run!
        new.run!
      end
    end

    def run!
      puts "[Content::Seeder] starting…"
      wipe_content!
      categories_by_slug = seed_categories!
      blueprints = load_blueprints
      seed_questions!(categories_by_slug, blueprints)
      seed_coding_exercises!
      seed_mock_interviews!
      seed_cheatsheets!
      seed_quizzes!
      print_summary
      puts "[Content::Seeder] done."
    end

    private

    def wipe_content!
      puts "[Content::Seeder] wiping content tables…"
      # Order respects FK constraints (question_tags → questions → categories, items → mocks).
      QuestionTag.delete_all
      MockInterviewItem.delete_all
      Question.delete_all
      CodingExercise.delete_all
      MockInterview.delete_all
      CheatsheetEntry.delete_all
      QuizQuestion.delete_all
      Tag.delete_all
      Category.delete_all
    end

    def seed_categories!
      now = Time.current
      rows = Content::Catalog::CATEGORIES.each_with_index.map do |meta, index|
        {
          name: meta[:name],
          slug: meta[:slug],
          icon: meta[:icon],
          description: meta[:description],
          target_count: meta[:target_count],
          position: index,
          created_at: now,
          updated_at: now
        }
      end

      Category.insert_all(rows)
      Category.all.index_by(&:slug)
    end

    def load_blueprints
      ensure_loaded!("Content::Banks", Rails.root.join("lib/content/banks.rb"))
      Array(Content::Banks.all_blueprints)
    rescue StandardError => e
      warn "[Content::Seeder] Banks unavailable (#{e.message}); continuing with expander seeds only."
      []
    end

    def seed_questions!(categories_by_slug, blueprints)
      ensure_loaded!("Content::QuestionGenerator", Rails.root.join("lib/content/question_generator.rb"))
      ensure_loaded!("Content::QuestionExpander", Rails.root.join("lib/content/question_expander.rb"))

      grouped = blueprints.group_by { |bp| blueprint_category_slug(bp) }
      used_slugs = Set.new
      tag_links = [] # [slug, tags]
      question_rows = []

      Content::Catalog::CATEGORIES.each do |meta|
        category = categories_by_slug[meta[:slug]]
        next unless category

        target = meta[:target_count].to_i
        category_bps = Array(grouped[meta[:slug]])
        expanded = Content::QuestionExpander.expand(category_bps, category, target)

        expanded.each_with_index do |blueprint, index|
          record = Content::QuestionGenerator.build_record(
            blueprint,
            category,
            index,
            used_slugs: used_slugs
          )
          tags = Content::QuestionGenerator.extract_tags(blueprint)
          tags = record[:tags_cache].to_s.split(",").map(&:strip).reject(&:blank?) if tags.empty?
          tag_links << [record[:slug], tags]
          question_rows << record
        end
      end

      insert_in_batches(Question, question_rows)
      seed_tags_for_questions!(tag_links)
    end

    def seed_tags_for_questions!(tag_links)
      tag_names = tag_links.flat_map { |_slug, tags| tags }.uniq
      return if tag_names.empty?

      now = Time.current
      used_tag_slugs = Set.new
      tag_rows = tag_names.map do |name|
        slug = unique_simple_slug(name, used_tag_slugs)
        {
          name: name,
          slug: slug,
          created_at: now,
          updated_at: now
        }
      end
      Tag.insert_all(tag_rows)

      tags_by_name = Tag.all.index_by(&:name)
      questions_by_slug = Question.pluck(:slug, :id).to_h

      join_rows = []
      tag_links.each do |question_slug, tags|
        question_id = questions_by_slug[question_slug]
        next unless question_id

        tags.uniq.each do |name|
          tag = tags_by_name[name]
          next unless tag

          join_rows << {
            question_id: question_id,
            tag_id: tag.id,
            created_at: now,
            updated_at: now
          }
        end
      end

      insert_in_batches(QuestionTag, join_rows.uniq { |row| [row[:question_id], row[:tag_id]] })
    end

    def seed_coding_exercises!
      unless constant_defined?("Content::CodingGenerator")
        warn "[Content::Seeder] CodingGenerator not defined — skipping coding exercises."
        return
      end

      ensure_loaded!("Content::CodingGenerator", Rails.root.join("lib/content/coding_generator.rb"))
      blueprints = Array(Content::CodingGenerator.blueprints)
      now = Time.current
      used = Set.new
      rows = blueprints.each_with_index.map do |bp, index|
        h = stringify_keys(bp)
        title = h["title"].to_s
        slug = unique_simple_slug(h["slug"].presence || title, used)
        {
          title: title,
          slug: slug,
          problem: h["problem"],
          requirements: normalize_text_list(h["requirements"]),
          expected_api: h["expected_api"],
          hints: normalize_text_list(h["hints"]),
          step_by_step: h["step_by_step"],
          complete_solution: h["complete_solution"],
          best_practices: h["best_practices"],
          time_complexity: h["time_complexity"],
          space_complexity: h["space_complexity"],
          senior_improvements: h["senior_improvements"],
          follow_ups: normalize_text_list(h["follow_ups"]),
          difficulty: h["difficulty"],
          category: h["category"],
          estimated_minutes: h["estimated_minutes"] || 45,
          position: h["position"] || index,
          created_at: now,
          updated_at: now
        }
      end
      insert_in_batches(CodingExercise, rows)
    rescue StandardError => e
      warn "[Content::Seeder] CodingGenerator failed: #{e.message}"
    end

    def seed_mock_interviews!
      unless constant_defined?("Content::MockGenerator")
        warn "[Content::Seeder] MockGenerator not defined — skipping mock interviews."
        return
      end

      ensure_loaded!("Content::MockGenerator", Rails.root.join("lib/content/mock_generator.rb"))
      blueprints = Array(Content::MockGenerator.blueprints)
      now = Time.current
      used = Set.new

      blueprints.each_with_index do |bp, index|
        h = stringify_keys(bp)
        title = h["title"].to_s
        slug = unique_simple_slug(h["slug"].presence || title, used)
        mock = MockInterview.create!(
          title: title,
          slug: slug,
          introduction: h["introduction"],
          duration_minutes: h["duration_minutes"] || 75,
          difficulty: h["difficulty"],
          company_focus: h["company_focus"],
          scoring_rubric: h["scoring_rubric"],
          interviewer_notes: h["interviewer_notes"],
          position: h["position"] || index
        )

        items = Array(h["items"] || h["mock_interview_items"])
        item_rows = items.each_with_index.map do |item, item_index|
          ih = stringify_keys(item)
          {
            mock_interview_id: mock.id,
            section: ih["section"],
            prompt: ih["prompt"],
            expected_answer: ih["expected_answer"],
            follow_ups: normalize_text_list(ih["follow_ups"]),
            duration_minutes: ih["duration_minutes"],
            position: ih["position"] || item_index,
            created_at: now,
            updated_at: now
          }
        end
        insert_in_batches(MockInterviewItem, item_rows) if item_rows.any?
      end
    rescue StandardError => e
      warn "[Content::Seeder] MockGenerator failed: #{e.message}"
    end

    def seed_cheatsheets!
      unless constant_defined?("Content::CheatsheetGenerator")
        warn "[Content::Seeder] CheatsheetGenerator not defined — skipping cheatsheets."
        return
      end

      ensure_loaded!("Content::CheatsheetGenerator", Rails.root.join("lib/content/cheatsheet_generator.rb"))
      blueprints = Array(Content::CheatsheetGenerator.blueprints)
      now = Time.current
      used = Set.new
      rows = blueprints.each_with_index.map do |bp, index|
        h = stringify_keys(bp)
        title = h["title"].to_s
        {
          title: title,
          slug: unique_simple_slug(h["slug"].presence || title, used),
          rails_concept: h["rails_concept"],
          rails_explanation: h["rails_explanation"],
          node_equivalent: h["node_equivalent"],
          nest_equivalent: h["nest_equivalent"],
          rails_code: h["rails_code"],
          node_code: h["node_code"],
          nest_code: h["nest_code"],
          category: h["category"],
          position: h["position"] || index,
          created_at: now,
          updated_at: now
        }
      end
      insert_in_batches(CheatsheetEntry, rows)
    rescue StandardError => e
      warn "[Content::Seeder] CheatsheetGenerator failed: #{e.message}"
    end

    def seed_quizzes!
      unless constant_defined?("Content::QuizGenerator")
        warn "[Content::Seeder] QuizGenerator not defined — skipping quiz questions."
        return
      end

      ensure_loaded!("Content::QuizGenerator", Rails.root.join("lib/content/quiz_generator.rb"))
      blueprints = Array(Content::QuizGenerator.blueprints)
      now = Time.current
      rows = blueprints.map do |bp|
        h = stringify_keys(bp)
        options = h["options"]
        options_json =
          case options
          when String then options
          else options.to_json
          end

        {
          prompt: h["prompt"],
          options: options_json,
          correct_index: h["correct_index"],
          explanation: h["explanation"],
          category: h["category"],
          difficulty: h["difficulty"],
          created_at: now,
          updated_at: now
        }
      end
      insert_in_batches(QuizQuestion, rows)
    rescue StandardError => e
      warn "[Content::Seeder] QuizGenerator failed: #{e.message}"
    end

    def insert_in_batches(model, rows)
      return if rows.blank?

      rows.each_slice(BATCH_SIZE) do |batch|
        model.insert_all(batch)
      end
    end

    def blueprint_category_slug(blueprint)
      h = stringify_keys(blueprint)
      (h["category_slug"] || h["category"] || "").to_s
    end

    def stringify_keys(hash)
      return {} unless hash.respond_to?(:each_pair)

      hash.each_with_object({}) do |(key, value), memo|
        memo[key.to_s] = value
      end
    end

    def normalize_text_list(value)
      case value
      when nil then nil
      when Array then value.map { |item| item.to_s.strip }.reject(&:blank?).join("\n")
      else value.to_s
      end
    end

    def unique_simple_slug(base, used)
      root = base.to_s.parameterize
      root = "item" if root.blank?
      candidate = root
      counter = 1
      while used.include?(candidate)
        candidate = "#{root}-#{counter}"
        counter += 1
      end
      used << candidate
      candidate
    end

    def constant_defined?(name)
      nested_const_defined?(name) || File.exist?(path_for_constant(name))
    end

    def nested_const_defined?(name)
      name.split("::").reduce(Object) do |mod, const|
        return false unless mod.const_defined?(const, false)

        mod.const_get(const)
      end
      true
    rescue NameError
      false
    end

    def path_for_constant(name)
      # Content::CodingGenerator -> lib/content/coding_generator.rb
      parts = name.split("::")
      parts.shift if parts.first == "Content"
      Rails.root.join("lib/content", "#{parts.map(&:underscore).join('/')}.rb")
    end

    def ensure_loaded!(const_name, path)
      return if nested_const_defined?(const_name)
      return unless File.exist?(path)

      require path.to_s
    end

    def print_summary
      puts "[Content::Seeder] counts:"
      puts "  categories=#{Category.count}"
      puts "  questions=#{Question.count}"
      puts "  tags=#{Tag.count}"
      puts "  question_tags=#{QuestionTag.count}"
      puts "  coding_exercises=#{CodingExercise.count}"
      puts "  mock_interviews=#{MockInterview.count}"
      puts "  mock_interview_items=#{MockInterviewItem.count}"
      puts "  cheatsheet_entries=#{CheatsheetEntry.count}"
      puts "  quiz_questions=#{QuizQuestion.count}"
    end
  end
end
