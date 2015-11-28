helpers do
  def worker_label(status)
    case status
    when "working" then "panel-success"
    when "waiting" then "panel-default"
    else "panel-warning"
    end
  end

  def doi_as_url(doi)
    "http://doi.org/" + doi
  end

  def number_with_delimiter(number, default_options = {})
    options = { :delimiter => ',' }.merge(default_options)
    number.to_s.reverse.gsub(/(\d{3}(?=(\d)))/, "\\1#{options[:delimiter]}").reverse
  end
end
