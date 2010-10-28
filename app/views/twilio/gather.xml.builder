xml.instruct!
xml.Response do
  xml.Gather(:action => url_for, :method => "POST") do
    xml.Say(@message) if @message
  end

  # Timeout.
  xml.Redirect(url_for, :method => "POST")
end