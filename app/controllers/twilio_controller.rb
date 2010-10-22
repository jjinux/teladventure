class TwilioController < ApplicationController
  before_filter :find_node, :only => [:show_node]
  helper_method :give_user_choices

  def index
    render_xml
  end

  def show_node
    @choices = []

    @node.children.each_with_index do |child, i|
      @choices << Choice.new(
        digits(i + 1),
        view_block { @xml.Play(child.choice) },
        controller_block { redirect_to :action => :show_node, :id => child.id }
      )
    end

    i = 0
    @choices << Choice.new(
      digits("*#{i += 1}"),
      view_block { @xml.Say("create a new choice and outcome.") },
      controller_block { redirect_to :action => :create_node, :parent_id => @node.id }
    )

    @choices << Choice.new(
      digits("*#{i += 1}"),
      view_block { @xml.Say("edit the current choice and outcome.") },
      controller_block { redirect_to :action => :edit_node, :id => @node.id }
    )

    if @node.parent
      @choices << Choice.new(
        digits("*#{i += 1}"),
        view_block { @xml.Say("go back a step.") },
        controller_block { redirect_to :action => :show_node, :id => @node.parent_id }
      )
    end

    if request.post?
      if params[:Digits]
        @choices[params[:Digits].to_i].controller_block.call
        # XXX Do more.
      else
        @error = "I'm sorry.  I didn't get a response.  Let's try again."
        @redirect = url_for
        render_xml(:action => :error)
      end
    else
      render_xml
    end
  end

  private

  def find_node
    @node = params[:id] ? Node.find(params[:id]) : Node.root
  end

  # This is a little DSL for choices:
  #
  #   Choice.new(digits("*2"),
  #              view_block { @xml... },
  #              controller_block { redirect_to... })
  Choice = Struct.new(:digits, :view_block, :controller_block)

  def digits(value)
    value.to_s
  end

  def view_block(&block)
    block
  end

  alias :controller_block :view_block

  # Tell the user his choices.
  def give_user_choices
    @choices.each do |choice|
      @xml.Say("Press #{choice.digits} if you would like to ")
      choice.view_block.call
    end
  end
end