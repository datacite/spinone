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
end
