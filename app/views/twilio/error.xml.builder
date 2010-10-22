xml.instruct!
xml.Response do
  xml.Say(@error)
  xml.Redirect(@redirect, :method => "GET")
end