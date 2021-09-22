class AnalyticsReportService
  def initialize(subdomain)
    @subdomain = subdomain
    @report_since = eval(@subdomain.analytics_report_frequency).ago
  end

  def call
    analytics_report_json
  end

  private

  attr_reader :report_since

  def analytics_report_json
    {
      ctas: cta_json,
      visits: visits_json,
      users: users_json,
      macros: macros_json
    }
  end

  def cta_json
    ctas = []
    CallToAction.all.each do |cta|
      ctas << {
        title: cta.title,
        id: cta.id,
        response_count: cta.call_to_action_responses.where('created_at > ?', report_since).count
      }
    end

    ctas
  end

  def visits_json
    response = {}
    visits = @subdomain.ahoy_visits.unscoped.where('started_at >= ?', report_since)
    visited_by = %i[country region city referring_domain landing_page]

    visited_by.each do |each_elm|
      response[each_elm] = visits.group(each_elm).count
    end
    response
  end

  def users_json
    @subdomain.users.where('created_at >= ?', report_since).as_json(only: User.public_attributes)
  end

  def macros_json
    {
      users: {
        total: @subdomain.users.size,
        added: @subdomain.users.where('created_at >= ?', report_since).size
      },
      pages: {
        total: @subdomain.pages.size,
        added: @subdomain.pages.where('created_at >= ?', report_since).size
      },
      storage: {
        total: "#{@subdomain.storage_used} Bytes",
        added: "#{@subdomain.storage_used_since(report_since)} Bytes"
      }
    }
  end
end
