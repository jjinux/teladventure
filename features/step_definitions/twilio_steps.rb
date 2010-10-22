Given /^there are a few nodes$/ do
  Node.create_a_few_nodes
end

When /^I receive a phone call$/ do
  get url_for(:controller => :twilio)
end

Then /^it should introduce me to the game$/ do
  @doc.xpath("/Response/Say").first.content.should == "Hello."
end

When /^I follow the redirect$/ do
  redirect = @doc.xpath("/Response/Redirect").first
  redirect.should_not be_nil

  method = redirect[:method].to_s || "POST"
  %w(GET POST).should include(method)

  request_via_redirect(method.downcase, redirect.content)
end

Then /^I should get a valid TwiML response$/ do
  assert_response :success
  @doc = Nokogiri::XML(response.body)
  @doc.xpath("/Response").size.should == 1
end

Then /^it should tell me the current outcome$/ do
  @doc.xpath("/Response/Gather/Play").should_not be_empty
end

Then /^it should ask me for the next choice$/ do
  @doc.xpath("/Response/Gather").should_not be_empty
end

Then /^it should redirect me to the current node if I haven't made a choice$/ do
  @doc.xpath("/Response/Redirect").should_not be_empty
end