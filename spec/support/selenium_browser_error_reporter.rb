# frozen_string_literal: true

class SeleniumBrowserErrorReporter
  SEVERE_LOG_LEVEL = 'SEVERE'

  def self.call(page)
    new(page).report!
  end

  def self.clear_error_logs!(page)
    new(page).clear_error_logs!
  end

  def initialize(page)
    self.page = page
  end

  def report!
    raise error_messages if severe_errors.any?
  end

  def clear_error_logs!
    logs.clear
  end

  private

  attr_accessor :page

  def error_report_for(errors)
    errors
      .map(&:message)
      .map { |message| message.gsub('\\n', "\n") }
      .join("\n\n")
  end

  def logs
    @logs ||= page.driver.browser.logs.get(:browser)
  end

  def severe_errors
    @severe_errors ||= logs.select { |log| log.level == SEVERE_LOG_LEVEL }
  end

  def errors_description
    if severe_errors.one?
      'There was 1 JavaScript error:'
    else
      "There were #{severe_errors.size} JavaScript errors:"
    end
  end

  def error_messages
    [errors_description, error_report_for(severe_errors)].join "\n\n"
  end
end
