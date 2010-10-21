require 'spec_helper'

describe Node do
  before(:each) do
    @valid_attributes = {
      :parent_id => 1,
      :choice => "value for choice",
      :outcome => "value for outcome"
    }
  end

  it "should create a new instance given valid attributes" do
    Node.create!(@valid_attributes)
  end
end
