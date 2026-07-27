# frozen_string_literal: true

require "set"

module Content
  class QuestionGenerator
    class << self
      def build_record(blueprint, category, index, used_slugs: nil)
        bp = stringify_keys(blueprint)
        tags = normalize_tags(bp["tags"])
        title = bp["title"].to_s.strip
        title = "Untitled #{category.slug} question #{index + 1}" if title.blank?

        total = category.target_count.to_i
        total = 1 if total <= 0

        {
          title: title,
          body: bp["body"].to_s.presence,
          answer: bp["answer"].to_s.presence || bp["best_answer"].to_s.presence,
          best_answer: bp["best_answer"].to_s.presence || bp["answer"].to_s.presence,
          alternative_answer: bp["alternative_answer"].to_s.presence,
          explanation: bp["explanation"].to_s.presence,
          common_mistakes: bp["common_mistakes"].to_s.presence,
          follow_ups: normalize_follow_ups(bp["follow_ups"]),
          theory: bp["theory"].to_s.presence,
          practical: bp["practical"].to_s.presence,
          difficulty: normalize_difficulty(bp["difficulty"], index, total),
          interview_type: normalize_interview_type(bp["interview_type"], category.slug),
          category_id: category.id,
          company: bp["company"].presence || Content::Catalog.company_for(index),
          source: bp["source"].presence || Content::Catalog.source_for(index),
          tags_cache: tags.join(", "),
          frequency_score: float_or(bp["frequency_score"], default_frequency(index, total)),
          estimated_minutes: int_or(bp["estimated_minutes"], default_minutes(bp["difficulty"], index, total)),
          confidence_score: float_or(bp["confidence_score"], 0.8),
          references_text: bp["references_text"].to_s.presence,
          related_slugs: normalize_related_slugs(bp["related_slugs"]),
          slug: unique_slug(bp["slug"].presence || title, category.slug, index, used_slugs),
          bookmarked_count: 0,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      def extract_tags(blueprint)
        bp = stringify_keys(blueprint)
        normalize_tags(bp["tags"])
      end

      private

      def stringify_keys(hash)
        return {} unless hash.respond_to?(:each_pair)

        hash.each_with_object({}) do |(key, value), memo|
          memo[key.to_s] = value
        end
      end

      def normalize_tags(raw)
        Array(raw).flat_map { |item| item.to_s.split(",") }.map(&:strip).reject(&:blank?).uniq
      end

      def normalize_follow_ups(value)
        case value
        when nil
          nil
        when Array
          value.map { |item| item.to_s.strip }.reject(&:blank?).join("\n")
        else
          value.to_s
        end
      end

      def normalize_related_slugs(value)
        case value
        when nil
          nil
        when Array
          value.map { |item| item.to_s.strip }.reject(&:blank?).join("\n")
        else
          value.to_s
        end
      end

      def normalize_difficulty(value, index, total)
        allowed = Question::DIFFICULTIES
        candidate = value.to_s.strip.downcase
        return candidate if allowed.include?(candidate)

        Content::Catalog.difficulty_for(index, total)
      end

      def normalize_interview_type(value, category_slug)
        allowed = Question::INTERVIEW_TYPES
        candidate = value.to_s.strip.downcase
        return candidate if allowed.include?(candidate)

        default_interview_type(category_slug)
      end

      def default_interview_type(category_slug)
        case category_slug.to_s
        when "behavioral" then "behavioral"
        when "system-design" then "system_design"
        when "sql", "postgresql" then "database"
        when "backend-architecture", "microservices", "design-patterns" then "architecture"
        when "real-world-debugging", "production-issues", "code-reviews" then "practical"
        else "theory"
        end
      end

      def default_frequency(index, total)
        ratio = index.to_f / [total, 1].max
        (0.95 - (ratio * 0.45)).clamp(0.35, 0.95).round(2)
      end

      def default_minutes(difficulty, index, total)
        case normalize_difficulty(difficulty, index, total)
        when "basic" then 3
        when "easy" then 5
        when "medium" then 8
        else 12
        end
      end

      def float_or(value, default)
        return default if value.nil? || value.to_s.strip.empty?

        Float(value)
      rescue ArgumentError, TypeError
        default
      end

      def int_or(value, default)
        return default if value.nil? || value.to_s.strip.empty?

        Integer(value)
      rescue ArgumentError, TypeError
        default
      end

      def unique_slug(base, category_slug, index, used_slugs)
        used = used_slugs || Set.new
        root = base.to_s.parameterize
        root = "#{category_slug}-q#{index + 1}" if root.blank?
        candidate = root
        counter = 1

        while used.include?(candidate)
          candidate = "#{root}-#{counter}"
          counter += 1
        end

        used << candidate
        candidate
      end
    end
  end
end
