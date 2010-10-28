controller.instance_variable_set("@xml", xml)

xml.instruct!
xml.Response do
  xml.Gather(:action => url_for, :method => "POST", :numDigits => 1) do
    xml.Say(@message)         if @message
    @controller_callback.call if @controller_callback
    give_user_choices
  end

  # Timeout.
  xml.Redirect(url_for, :method => "POST")
end