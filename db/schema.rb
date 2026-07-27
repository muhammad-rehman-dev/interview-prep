# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_07_24_181642) do
  create_table "bookmarks", force: :cascade do |t|
    t.string "visitor_token"
    t.string "bookmarkable_type"
    t.integer "bookmarkable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visitor_token", "bookmarkable_type", "bookmarkable_id"], name: "idx_bookmarks_unique", unique: true
    t.index ["visitor_token"], name: "index_bookmarks_on_visitor_token"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.string "icon"
    t.integer "position", default: 0
    t.integer "target_count", default: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "cheatsheet_entries", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "rails_concept"
    t.text "rails_explanation"
    t.text "node_equivalent"
    t.text "nest_equivalent"
    t.text "rails_code"
    t.text "node_code"
    t.text "nest_code"
    t.string "category"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_cheatsheet_entries_on_category"
    t.index ["slug"], name: "index_cheatsheet_entries_on_slug", unique: true
  end

  create_table "coding_exercises", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "problem"
    t.text "requirements"
    t.text "expected_api"
    t.text "hints"
    t.text "step_by_step"
    t.text "complete_solution"
    t.text "best_practices"
    t.string "time_complexity"
    t.string "space_complexity"
    t.text "senior_improvements"
    t.text "follow_ups"
    t.string "difficulty"
    t.string "category"
    t.integer "estimated_minutes", default: 45
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_coding_exercises_on_category"
    t.index ["difficulty"], name: "index_coding_exercises_on_difficulty"
    t.index ["slug"], name: "index_coding_exercises_on_slug", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "tagline"
    t.text "description"
    t.string "interview_focus"
    t.string "website"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_companies_on_slug", unique: true
  end

  create_table "company_questions", force: :cascade do |t|
    t.integer "company_id", null: false
    t.text "title"
    t.string "slug"
    t.text "body"
    t.text "answer"
    t.text "best_answer"
    t.text "explanation"
    t.text "common_mistakes"
    t.text "follow_ups"
    t.string "difficulty"
    t.string "interview_round"
    t.string "source"
    t.string "tags_cache"
    t.integer "estimated_minutes"
    t.integer "position"
    t.float "frequency_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "slug"], name: "index_company_questions_on_company_id_and_slug", unique: true
    t.index ["company_id"], name: "index_company_questions_on_company_id"
    t.index ["difficulty"], name: "index_company_questions_on_difficulty"
    t.index ["interview_round"], name: "index_company_questions_on_interview_round"
  end

  create_table "mock_interview_items", force: :cascade do |t|
    t.integer "mock_interview_id", null: false
    t.string "section"
    t.text "prompt"
    t.text "expected_answer"
    t.text "follow_ups"
    t.integer "duration_minutes"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mock_interview_id"], name: "index_mock_interview_items_on_mock_interview_id"
  end

  create_table "mock_interviews", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "introduction"
    t.integer "duration_minutes", default: 75
    t.string "difficulty"
    t.string "company_focus"
    t.text "scoring_rubric"
    t.text "interviewer_notes"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_mock_interviews_on_slug", unique: true
  end

  create_table "progress_records", force: :cascade do |t|
    t.string "visitor_token"
    t.string "record_type"
    t.integer "record_id"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visitor_token", "record_type", "record_id"], name: "idx_progress_unique", unique: true
    t.index ["visitor_token"], name: "index_progress_records_on_visitor_token"
  end

  create_table "question_tags", force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "tag_id"], name: "index_question_tags_on_question_id_and_tag_id", unique: true
    t.index ["question_id"], name: "index_question_tags_on_question_id"
    t.index ["tag_id"], name: "index_question_tags_on_tag_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "title"
    t.text "body"
    t.text "answer"
    t.text "best_answer"
    t.text "alternative_answer"
    t.text "explanation"
    t.text "common_mistakes"
    t.text "follow_ups"
    t.text "theory"
    t.text "practical"
    t.string "difficulty"
    t.string "interview_type"
    t.integer "category_id", null: false
    t.string "company"
    t.string "source"
    t.string "tags_cache"
    t.float "frequency_score", default: 0.5
    t.integer "estimated_minutes", default: 5
    t.float "confidence_score", default: 0.8
    t.text "references_text"
    t.text "related_slugs"
    t.string "slug"
    t.integer "bookmarked_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "difficulty"], name: "index_questions_on_category_id_and_difficulty"
    t.index ["category_id"], name: "index_questions_on_category_id"
    t.index ["company"], name: "index_questions_on_company"
    t.index ["difficulty"], name: "index_questions_on_difficulty"
    t.index ["interview_type"], name: "index_questions_on_interview_type"
    t.index ["slug"], name: "index_questions_on_slug", unique: true
    t.index ["source"], name: "index_questions_on_source"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.text "prompt"
    t.text "options"
    t.integer "correct_index"
    t.text "explanation"
    t.string "category"
    t.string "difficulty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_quiz_questions_on_category"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  add_foreign_key "company_questions", "companies"
  add_foreign_key "mock_interview_items", "mock_interviews"
  add_foreign_key "question_tags", "questions"
  add_foreign_key "question_tags", "tags"
  add_foreign_key "questions", "categories"
end
