def assert_valid_xml_document
  assert_response :success
  @doc = Nokogiri::XML(response.body)
end

When /^I receive a phone call$/ do
  get url_for(:controller => :twilio)
end

Then /^it should say hello$/ do
  assert_valid_xml_document
  @doc.xpath("/Response/Say")[0].content.should == "Hi"
end