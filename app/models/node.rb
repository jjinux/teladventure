class Node < ActiveRecord::Base
  acts_as_tree
  attr_accessible :choice, :outcome
end
