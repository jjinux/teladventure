def assert_valid_xml_document
  assert_response :success
  @doc = Nokogiri::XML(response.body)
end

When /^I receive a phone call$/ do
  get url_for(:controller => :twilio)
end

Then /^it should introduce me to the game$/ do
  assert_valid_xml_document
  @doc.xpath("/Response/Say").first.content.should == "Hello."
end

When /^I follow the redirect$/ do
  redirect = @doc.xpath("/Response/Redirect").first
  redirect.should_not be_nil

  method = redirect[:method].to_s || "POST"
  %w(GET POST).should include(method)

  request_via_redirect(method.downcase, redirect.content)
end

Then /^it should introduce me to the node$/ do
  assert_valid_xml_document
  @doc.xpath("/Response/Play").first.should_not be_nil
end