xml.instruct!
xml.Response do
  xml.Say("Hello.")
  xml.Say("Teladventure is an interactive, phone-based adventure game.")
  xml.Say("You play Teladventure not just by exploring the story, but also by adding to it.")
  xml.Say("Now, let's get started.")

  xml.Redirect(url_for(:action => "introduce_node"), :method => :GET)
end