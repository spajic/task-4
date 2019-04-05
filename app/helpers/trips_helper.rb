module TripsHelper
  def render_service(service)
    "<li>#{service.name}</li>".html_safe
  end

  def render_services(services)
    services.map do |service|
      <<~HTML
        <li>Сервисы в автобусе:</li>
        <ul>
          #{render_service(service)}
        </ul>
      HTML
    end.join('').html_safe
  end
end
