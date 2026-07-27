# frozen_string_literal: true

module ApplicationHelper
  DIFFICULTY_CLASSES = {
    "basic" => "badge-basic",
    "easy" => "badge-easy",
    "medium" => "badge-medium",
    "hard" => "badge-hard"
  }.freeze

  INTERVIEW_TYPE_LABELS = {
    "technical" => "Technical",
    "theory" => "Theory",
    "practical" => "Practical",
    "architecture" => "Architecture",
    "coding" => "Coding",
    "behavioral" => "Behavioral",
    "system_design" => "System Design",
    "database" => "Database"
  }.freeze

  def difficulty_badge(difficulty)
    return "".html_safe if difficulty.blank?

    key = difficulty.to_s.downcase
    css = DIFFICULTY_CLASSES.fetch(key, "badge-neutral")
    tag.span(key.tr("_", " ").capitalize, class: "badge #{css}")
  end

  def interview_type_badge(interview_type)
    return "".html_safe if interview_type.blank?

    key = interview_type.to_s.downcase
    label = INTERVIEW_TYPE_LABELS.fetch(key, key.tr("_", " ").split.map(&:capitalize).join(" "))
    tag.span(label, class: "badge badge-type")
  end

  def format_rich_text(text)
    return "".html_safe if text.blank?

    html = text.to_s.gsub(/```(\w+)?\n(.*?)```/m) do
      lang = Regexp.last_match(1).to_s
      code = ERB::Util.html_escape(Regexp.last_match(2).to_s.rstrip)
      %(<pre class="code-block" data-lang="#{ERB::Util.html_escape(lang)}"><code>#{code}</code></pre>)
    end

    html = html.gsub(/`([^`\n]+)`/) do
      %(<code class="inline-code">#{ERB::Util.html_escape(Regexp.last_match(1))}</code>)
    end

    sanitized = sanitize(
      simple_format(html, {}, sanitize: false),
      tags: %w[p br pre code strong em ul ol li a h1 h2 h3 h4],
      attributes: %w[href class data-lang]
    )

    tag.div(sanitized, class: "rich-text")
  end

  alias formatted_content format_rich_text

  def page_title(title)
    content_for(:title, "#{title} · BackendForge")
  end

  def nav_link_to(name, path, icon: nil)
    active = nav_link_active?(path)
    classes = [
      "nav-link",
      ("nav-link-active" if active)
    ].compact.join(" ")

    link_to path, class: classes, aria: { current: ("page" if active) } do
      safe_join([
        (tag.span(icon, class: "nav-icon", aria: { hidden: true }) if icon),
        tag.span(name)
      ].compact)
    end
  end

  def empty_state(title:, body:, cta: nil, href: nil)
    tag.div(class: "empty-state") do
      safe_join([
        tag.h3(title, class: "empty-state-title"),
        tag.p(body, class: "empty-state-body"),
        (link_to(cta, href, class: "btn btn-primary") if cta.present? && href.present?)
      ].compact)
    end
  end

  def progress_bar(percent)
    percent = [[percent.to_i, 0].max, 100].min
    tag.div(class: "progress-track") do
      tag.div(
        class: "progress-fill",
        style: "width: #{percent}%",
        role: "progressbar",
        aria: { valuemin: 0, valuemax: 100, valuenow: percent }
      )
    end
  end

  def app_shell?
    !current_page?(root_path)
  end

  def companies_nav_open?
    request.path.start_with?("/companies")
  end

  def company_nav_active?(company)
    current_page?(company_path(company)) ||
      request.path.start_with?("/companies/#{company.slug}/")
  end

  def percent_complete(completed, total)
    return 0 if total.to_i.zero?

    ((completed.to_f / total) * 100).round
  end

  private

  def nav_link_active?(path)
    return current_page?(path) if path == root_path

    current_page?(path) || request.path.start_with?("#{path}/") || request.path == path
  end
end
