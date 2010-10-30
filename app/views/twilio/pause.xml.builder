xml.instruct!
xml.Response do
  # Pause for up to 15 minutes.
  xml.Gather(:action => url_for, :method => "POST", :numDigits => 1, :timeout => 60 * 15) do
    xml.Say(@message)         if @message
    @controller_callback.call if @controller_callback
  end

  # Timeout.
  xml.Redirect(url_for, :method => "POST")
end