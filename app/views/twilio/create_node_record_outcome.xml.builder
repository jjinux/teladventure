xml.instruct!
xml.Response do
  xml.Say("Now, record a new outcome after the beep.  It may be up to 60 seconds long.  Press any key when you are done.")
  xml.Record(:action => url_for, :maxLength => 60)
end