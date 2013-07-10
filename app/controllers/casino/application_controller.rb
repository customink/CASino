require 'casino'
require 'casino_core'
require 'http_accept_language'

class CASino::ApplicationController < ::ApplicationController
  include ApplicationHelper

###########

helper_method :current_user, :user_signed_in?
before_filter :authenticate!

def authenticate!
  processor(:CurrentUser).process(cookies, request.user_agent)
end

def current_user
  @current_user
end

def user_signed_in?
  !!current_user
end

###########

  layout 'application'
  before_filter :set_locale

  def cookies
    super
  end

  protected
  def processor(processor_name, listener_name = nil)
    listener_name ||= processor_name
    listener = CASino::Listener.const_get(listener_name).new(self)
    @processor = CASinoCore::Processor.const_get(processor_name).new(listener)
  end

  def set_locale
    I18n.locale = extract_locale_from_accept_language_header || I18n.default_locale
  end

  def extract_locale_from_accept_language_header
    if request.env['HTTP_ACCEPT_LANGUAGE']
      http_accept_language.preferred_language_from(I18n.available_locales)
    end
  end

  def http_accept_language
    HttpAcceptLanguage::Parser.new request.env['HTTP_ACCEPT_LANGUAGE']
  end
end
