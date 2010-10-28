xml.instruct!
xml.Response do
  xml.Say("You recorded:")
  xml.Play(@recording)
  xml.Redirect(@redirect, :method => "GET")
end