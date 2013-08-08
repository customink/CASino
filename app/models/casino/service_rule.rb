require 'casino/url_cleaner'

class CASino::ServiceRule < ActiveRecord::Base
  extend CASino::UrlCleaner

  attr_accessible :enabled, :order, :name, :url, :regex
  validates :name, presence: true
  validates :url, uniqueness: true, presence: true

  # Adds a service rule (prefix the url parameter with "regex:" to add a regular expression)
  def self.add(name, url)
    service_rule = new name:name
    match = /^regex:(.*)/.match(url)
    if match
      service_rule.url = match[1]
      service_rule.regex = true
    else
      service_rule.url = self.clean_service_url(url)
    end

    service_rule.save!

    if service_rule.unsafe_regex?
      Rails.logger.warn 'Potentially unsafe regex! Use ^ to match the ' \
                        'beginning of the URL. Example: ^https://'
    end
  end

  def self.allowed?(service_url)
    rules = self.where(enabled: true)
    if rules.empty?
      true
    else
      rules.any? { |rule| rule.allows?(service_url) }
    end
  end

  def allows?(service_url)
    if self.regex.blank?
      self.url == service_url
    else
      Regexp.new(url, true) =~ service_url
    end
  end

  def unsafe_regex?
    return false unless regex

    url[0] != '^'
  end
end
