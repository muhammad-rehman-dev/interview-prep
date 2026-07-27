# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "home#index"

  get "dashboard", to: "dashboard#show"

  resources :categories, only: %i[index show], param: :slug

  resources :questions, only: %i[index show], param: :slug do
    member do
      post :toggle_bookmark
      post :toggle_complete
    end
  end

  get "search", to: "search#index"

  resources :coding_exercises, only: %i[index show], param: :slug
  resources :mock_interviews, only: %i[index show], param: :slug

  resource :flashcards, only: [:show], controller: "flashcards" do
    post :next
  end

  resource :quiz, only: %i[show create], controller: "quiz"

  get "cheatsheet", to: "cheatsheet#index"
  get "cheatsheet/:slug", to: "cheatsheet#show", as: :cheatsheet_entry

  resources :companies, only: %i[index show], param: :slug do
    resources :questions, only: %i[show], controller: "company_questions", param: :slug
  end

  resource :mock_session, only: %i[show update], controller: "mock_sessions"
end
