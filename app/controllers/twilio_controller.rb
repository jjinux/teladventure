class TwilioController < ApplicationController
  # This breaks Twilio applications.
  before_filter :verify_authenticity_token, :only => []

  before_filter :find_node, :only => [:show_node]
  helper_method :give_user_choices

  def index
    render_xml
  end

  def show_node
    @choices = []

    @node.children.each_with_index do |child, i|
      @choices << Choice.new(
        label("show_node(#{i + 1})"),
        digits(i + 1),
        view_block { @xml.Play(child.choice) },
        controller_block { redirect_to :action => :show_node, :id => child.id }
      )
    end

    i = 0
    @choices << Choice.new(
      label(:create_node),
      digits("*#{i += 1}"),
      view_block { @xml.Say("create a new choice and outcome.") },
      controller_block { redirect_to :action => :create_node, :parent_id => @node.id }
    )

    @choices << Choice.new(
      label(:edit_node),
      digits("*#{i += 1}"),
      view_block { @xml.Say("edit the current choice and outcome.") },
      controller_block { redirect_to :action => :edit_node, :id => @node.id }
    )

    if @node.parent
      @choices << Choice.new(
        label("show_node(#{@node.parent_id})"),
        digits("*#{i += 1}"),
        view_block { @xml.Say("go back a step.") },
        controller_block { redirect_to :action => :show_node, :id => @node.parent_id }
      )
    end

    if request.post?
      handle_choice
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
  #   Choice.new(label(:action_name),
  #              digits("*2"),
  #              view_block { @xml... },
  #              controller_block { redirect_to... })
  Choice = Struct.new(:label, :digits, :view_block, :controller_block)

  def label(value)
    value.to_s
  end

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

  # Respond to the user's choice.
  def handle_choice
    digits = params[:Digits]
    unless digits
      @error = "I'm sorry.  I didn't get a response.  Let's try again."
      @redirect = url_for
      return render_xml(:action => :error)
    end

    choice = @choices.find { |c| [c.label, c.digits].include?(digits) }
    unless choice
      @error = "#{digits} is not a valid entry.  Let's try again."
      @redirect = url_for
      return render_xml(:action => :error)
    end

    choice.controller_block.call
  end
end