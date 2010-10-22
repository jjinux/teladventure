xml.instruct!
xml.Response do
  xml.Say(@message)
  xml.Redirect(@redirect, :method => "GET")
end