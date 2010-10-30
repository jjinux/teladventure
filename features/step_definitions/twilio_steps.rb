# Return "get" or "post" based on method which may be nil.
#
# "post" is the default.
def sanitize_method(method)
  method = (method || "post").to_s.downcase
  %w(get post).should include(method)
  method
end

When /^I follow the redirect$/ do
  redirect = @doc.xpath("/Response/Redirect").first
  redirect.should_not be_nil
  request_via_redirect(sanitize_method(redirect[:method]), redirect.content)
end

When /^I enter "([^"]*)"$/ do |digits|
  gather = @doc.xpath("/Response/Gather").first
  gather.should_not be_nil
  request_via_redirect(sanitize_method(gather[:method]), gather[:action], {:Digits => digits})
end

When /^I record something with the URL "([^"]*)"$/ do |url|
  record = @doc.xpath("/Response/Record").first
  record.should_not be_nil
  request_via_redirect(sanitize_method(record[:method]), record[:action], {:RecordingUrl => url})
end

Then /^I should get a valid TwiML response$/ do
  assert_response :success
  @doc = Nokogiri::XML(response.body)
  @doc.xpath("/Response").size.should == 1
end

Then /^it should (not |)(say|play) "([^"]*)"$/ do |not_present, verb, msg|
  @doc.xpath("//#{verb.titlecase}").any? { |e| e.content.include?(msg) }.should == (not_present == "")
end

Then /^it should record something$/ do
  @doc.xpath("/Response/Record").should_not be_empty
end

Then /^it should redirect me if I time out$/ do
  @doc.xpath("/Response/Redirect").should_not be_empty
end

Given /^there are a few nodes$/ do
  Node.create_a_few_nodes
end

Given /^there is a root node$/ do
  Node.create_a_root_node
end

When /^I receive a phone call$/ do
  get url_for(:controller => :twilio)
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

When /^I enter "([^"]*)" when I am on the root node$/ do |digits|
  post_via_redirect url_for(:controller => :twilio, :action => :show_node, :Digits => digits)
end

When /^I enter "([^"]*)" when I am on the root node's first child$/ do |digits|
  id = Node.root.children.first.id
  post_via_redirect url_for(:controller => :twilio, :action => :show_node, :id => id, :Digits => digits)
end

Then /^there should be a child of the root node with choice "([^"]*)" and outcome "([^"]*)"$/ do |choice, outcome|
  Node.root.children.find_by_choice_and_outcome(choice, outcome).should_not be_nil
end