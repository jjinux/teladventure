class TwilioController < ApplicationController
  before_filter :find_node, :only => [:introduce_node]

  def index
    render_xml
  end

  def introduce_node
    render_xml
  end

  private

  def find_node
    @node = params[:id] ? Node.find(params[:id]) : Node.root
  end
end