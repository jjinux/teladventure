controller.instance_variable_set("@xml", xml)
xml.instruct!
xml.Response do

  # Play the current outcome and ask for the next choice.
  xml.Gather(:action => url_for, :method => "POST", :timeout => 3) do
    xml.Play(@node.outcome)
    give_user_choices
  end

  # Timeout.
  xml.Redirect(:action => url_for, :method => "POST")
end