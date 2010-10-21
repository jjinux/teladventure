require 'spec_helper'

describe Node do
  before(:each) do
    @node = Factory :node
  end

  it "has all the right attributes" do
    @node.choice.should be_nil
    @node.outcome.should == "http://api.twilio.com/2010-04-01/Accounts/ACec5bb8f63c52532cb3a8c18a1b2e85b1/Recordings/RE48c9b4391d0850546843da3d1c4f1070"
    @node.created_at.should_not be_nil
  end

  it "acts_as_tree" do
    @node.parent.should be_nil
    @node.children.should be_empty
    Node.root.should == @node
  end

  it "uses attr_accessible to lock down some, but not all attributes" do
    node = Node.create!(:parent_id => 5, :choice => "choice", :outcome => "outcome")
    node.parent_id.should be_nil
    node.choice.should == "choice"
    node.outcome.should == "outcome"
  end

  context "create_a_few_nodes" do
    it "creates a few nodes" do
      Node.create_a_few_nodes
      Node.root.children.size.should == 2
    end
  end
end