module DashboardHelper
  def render_layout(layout)
    case layout[:type]
    when 'column'
      content_tag :div, class: 'dashboard-column', style: "width: #{layout[:width]};" do
        layout[:children].map { |child| render_layout(child) }.join.html_safe
      end
    when 'row'
      content_tag :div, class: 'dashboard-row', style: "height: #{layout[:height]};" do
        layout[:children].map { |child| render_layout(child) }.join.html_safe
      end
    when 'widget'
      content_tag :div, class: 'dashboard-widget', id: layout[:id], style: "width: #{layout[:width]};" do
        render "widgets/#{layout[:id]}"
      end
    end
  end
end
