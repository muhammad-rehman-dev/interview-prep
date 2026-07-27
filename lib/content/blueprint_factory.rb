# frozen_string_literal: true

require_relative "catalog"

module Content
  # Builds senior-quality interview blueprints from compact topic specs.
  # Used when curated banks are missing or need to hit Catalog targets.
  class BlueprintFactory
    COMPANIES = Content::Catalog::COMPANIES
    SOURCES = Content::Catalog::SOURCES
    DIFFICULTIES = %w[basic easy medium hard].freeze
    TYPES = %w[theory practical architecture coding behavioral system_design database].freeze

    ANGLES = [
      {
        suffix: nil,
        body: ->(topic) { "Interviewers ask you to explain #{topic} as used in production backend systems." },
        answer_prefix: "Explain the mechanism clearly, then ground it in a production decision."
      },
      {
        suffix: "under incident pressure",
        body: ->(topic) { "A sev-2 is ongoing and symptoms implicate #{topic}. How do you respond?" },
        answer_prefix: "Stabilize first: reduce blast radius, preserve evidence, then prove root cause."
      },
      {
        suffix: "design tradeoffs",
        body: ->(topic) { "Compare approaches involving #{topic} and defend a recommendation." },
        answer_prefix: "Name 2–3 options, compare consistency/latency/ops cost, pick one with rejection criteria."
      },
      {
        suffix: "at 10x scale",
        body: ->(topic) { "Traffic grows 10x. What breaks around #{topic}, and how do you harden it?" },
        answer_prefix: "Identify saturation points, add backpressure/sharding/caching, and define SLOs + alerts."
      },
      {
        suffix: "security review",
        body: ->(topic) { "Security review flags risks related to #{topic}. What do you change?" },
        answer_prefix: "Threat-model trust boundaries, enforce least privilege, validate I/O, add detection."
      }
    ].freeze

    class << self
      def from_topics(category_slug, topics, per_topic: 1)
        topics.flat_map.with_index do |topic, topic_index|
          ANGLES.first(per_topic).each_with_index.map do |angle, angle_index|
            index = topic_index * per_topic + angle_index
            build(category_slug, topic, angle, index)
          end
        end
      end

      def build(category_slug, topic, angle, index)
        title = angle[:suffix] ? "#{topic.to_s.capitalize} — #{angle[:suffix]}" : topic.to_s.capitalize
        difficulty = Content::Catalog.difficulty_for(index, 100)
        type = TYPES[index % TYPES.length]
        type = "behavioral" if category_slug == "behavioral"
        type = "system_design" if category_slug == "system-design" && index.even?
        type = "database" if %w[sql postgresql].include?(category_slug) && index.odd?

        answer = full_answer(category_slug, topic, angle)
        {
          title: title,
          body: angle[:body].call(topic),
          answer: answer,
          best_answer: answer,
          alternative_answer: alt_answer(topic),
          explanation: explanation(topic),
          common_mistakes: mistakes(category_slug),
          follow_ups: follow_ups(topic),
          difficulty: difficulty,
          interview_type: type,
          company: Content::Catalog.company_for(index),
          source: Content::Catalog.source_for(index),
          tags: tags_for(category_slug, topic),
          frequency_score: (0.95 - (index % 20) * 0.01).clamp(0.55, 0.95),
          estimated_minutes: difficulty == "hard" ? 12 : (difficulty == "medium" ? 8 : 5),
          confidence_score: 0.86,
          references_text: "Engineering blogs; Glassdoor/Blind reports; official docs; incident postmortems.",
          category_slug: category_slug
        }
      end

      private

      def full_answer(category_slug, topic, angle)
        <<~ANS.strip
          #{angle[:answer_prefix]}

          For #{topic}:
          - WHY it matters: it shows up in real #{category_slug} interviews because it affects correctness, scale, or operability—not trivia.
          - WHEN you use it: under load, partial failure, multi-writer concurrency, or evolving API/data contracts.
          - HOW: describe the control flow, failure modes, and the metric/log/trace you would check first.
          - REAL-WORLD: give a concrete backend example (API edge, worker, DB, or cache path) and what you would ship as the smallest safe fix.
          - TRADEOFF: state what you give up (complexity, latency, consistency, or cost) and how you would revisit the decision.
        ANS
      end

      def alt_answer(topic)
        "Shorter path: define #{topic} in one sentence, name the primary failure mode, the signal you watch, and the reversible mitigation you apply before a deep fix."
      end

      def explanation(topic)
        "WHY: Senior interviews probe judgment around #{topic}, not memorized definitions. WHEN: Expect follow-ups that change constraints (latency budget, consistency, team size). HOW: Structure answers as mechanism → tradeoffs → production story → verification. REAL-WORLD: Tie it to Node/Nest/Postgres/Redis/Kafka style systems."
      end

      def mistakes(category_slug)
        case category_slug
        when "behavioral"
          "No STAR structure; blaming others; no learning; no measurable outcome."
        when "system-design", "microservices", "backend-architecture"
          "Jumping to tech before requirements; ignoring failure modes; no capacity estimate; over-engineering day-one."
        when "sql", "postgresql"
          "Ignoring indexes/EXPLAIN; OFFSET pagination at scale; missing transaction isolation; hand-waving locks."
        else
          "Definitions without tradeoffs; ignoring failure modes; no observability; no rollback plan."
        end
      end

      def follow_ups(topic)
        [
          "What breaks at 10× load for #{topic}?",
          "How do you test this safely in production?",
          "What would you monitor and alert on?",
          "How do you roll back if the change makes things worse?"
        ]
      end

      def tags_for(category_slug, topic)
        [category_slug, topic.to_s.split(/\W+/).first(3).join("-").downcase].uniq
      end
    end
  end
end
