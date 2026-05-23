class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_locale

  private

  def set_locale
    I18n.locale = preferred_locale
  end

  def preferred_locale
    accepted = request.env["HTTP_ACCEPT_LANGUAGE"].to_s
    parsed = accepted.gsub(/\s+/, "").split(",").map do |lang|
      parts = lang.split(";q=")
      [parts[0].split("-").first.downcase, parts[1]&.to_f || 1.0]
    end
    parsed.sort_by { |_, q| -q }.each do |lang, _|
      locale = lang.to_sym
      return locale if I18n.available_locales.include?(locale)
    end
    I18n.default_locale
  end
end
