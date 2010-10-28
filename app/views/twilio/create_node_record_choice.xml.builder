xml.instruct!
xml.Response do
  xml.Say("Please record a new choice after the beep.  It may be up to 10 seconds long.  Press any key when you are done.")
  xml.Record(:action => url_for, :maxLength => 10)
end