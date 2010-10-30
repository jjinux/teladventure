class TwilioController < ApplicationController
  # This breaks Twilio applications.
  before_filter :verify_authenticity_token, :only => []

  before_filter :find_node, :only => [:show_node]
  helper_method :give_user_choices

  def index
    say_message_and_redirect(
      %{
        Hello.
        Teladventure is an interactive, phone-based adventure game.
        You play Teladventure not just by exploring the story, but also by adding to it.
        Let's get started.
      },
      url_for(:action => "show_node"))
  end

  def show_node
    @choices = []

    @node.children.each_with_index do |child, i|
      @choices << Choice.new(
        label("child(#{i + 1})"),
        digits(i + 1),
        view_block { @xml.Play(child.choice) },
        controller_block { redirect_to :action => :show_node, :id => child.id }
      )
    end

    # It's too confusing if people edit a parent node because usually they'll
    # break the stories in the child nodes.
    i = 1
    if @node.children.empty?
      @choices << Choice.new(
        label(:edit_node),
        digits("*#{i}"),
        view_block { @xml.Say("edit the current choice and outcome.") },
        controller_block { redirect_to :action => :edit_node, :id => @node }
      )
    end

    i += 1
    @choices << Choice.new(
      label(:create_node),
      digits("*#{i}"),
      view_block { @xml.Say("create a new choice and outcome.") },
      controller_block { redirect_to :action => :create_node, :parent_id => @node }
    )

    i += 1
    if @node.parent
      @choices << Choice.new(
        label("parent"),
        digits("*#{i}"),
        view_block { @xml.Say("go back a step.") },
        controller_block { redirect_to :action => :show_node, :id => @node.parent_id }
      )
    end

    @choices << Choice.new(
      label(:start_over),
      digits(0),
      view_block { @xml.Say("start over.") },
      controller_block { redirect_to :action => :index }
    )

    if request.post?
      handle_choice
    else
      render_xml
    end
  end

  def create_node
    raise ArgumentError.new("No 'parent_id' parameter passed") unless params[:parent_id]
    session[:node] = {:parent_id => params[:parent_id]}
    redirect_to :action => :create_node_pause
  end

  def create_node_pause
    pause("You are about to create a new choice and outcome.", :create_node_record_choice)
  end

  def create_node_record_choice
    record_node_attr(:record_choice, :choice, :create_node_verify_choice)
  end

  def create_node_verify_choice
    confirm(:incorrect => :create_node_record_choice, :correct => :create_node_record_outcome)
  end

  def create_node_record_outcome
    record_node_attr(:record_outcome, :outcome, :create_node_verify_outcome)
  end

  def create_node_verify_outcome
    confirm(:incorrect => :create_node_record_outcome, :correct => :create_node_congratulations)
  end

  def create_node_congratulations
    parent = Node.find(session[:node][:parent_id])
    parent.children.create!(session[:node])
    say_message_and_redirect(
      %Q{
        You have created a new choice and outcome.
        You can now continue the adventure where you left off.
      },
      url_for(:action => :show_node, :id => parent)
    )
  end

  def edit_node
    raise ArgumentError.new("No 'id' parameter passed") unless params[:id]
    session[:node] = {:id => params[:id]}
    redirect_to :action => :edit_node_pause
  end

  def edit_node_pause
    pause("You are about to edit the current choice and outcome.", :edit_node_record_choice)
  end

  def edit_node_record_choice
    record_node_attr(:record_choice, :choice, :edit_node_verify_choice)
  end

  def edit_node_verify_choice
    confirm(:incorrect => :edit_node_record_choice, :correct => :edit_node_record_outcome)
  end

  def edit_node_record_outcome
    record_node_attr(:record_outcome, :outcome, :edit_node_verify_outcome)
  end

  def edit_node_verify_outcome
    confirm(:incorrect => :edit_node_record_outcome, :correct => :edit_node_congratulations)
  end

  def edit_node_congratulations
    node = Node.find(session[:node][:id])
    node.update_attributes!(session[:node])
    whats_next = node.parent || node
    say_message_and_redirect(
      %Q{
        You have edited the current choice and outcome.
        You can now continue the adventure where you left off.
      },
      url_for(:action => :show_node, :id => whats_next)
    )
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

  # If we received params[:Digits], return true.
  #
  # Otherwise, render a response (redirecting to the current URL) and return false.
  def received_digits?
    if params[:Digits]
      true
    else
      say_message_and_redirect("I'm sorry.  I didn't get a response.  Let's try again.", url_for)
      false
    end
  end

  # If this is a GET, call render_xml.  Otherwise, call handle_choice.
  #
  # options are passed to render_xml so that you can override the action.
  def get_and_handle_choice(options = {})
    if request.post?
      handle_choice
    else
      render_xml(options)
    end
  end

  # Respond to the user's choice.
  def handle_choice
    return unless received_digits?

    digits = params[:Digits]
    choice = @choices.find { |c| [c.label, c.digits].include?(digits) }
    unless choice
      return say_message_and_redirect("#{digits} is not a valid entry.  Let's try again.", url_for)
    end

    choice.controller_block.call
  end

  # Render a TwiML response to the user.
  def say_message_and_redirect(message, url)
    @message = message
    @redirect = url
    render_xml(:action => :say_message_and_redirect)
  end

  # Render an XML response to the user.  Pass options to render.
  def render_xml(options = {})
    options[:layout] ||= false
    respond_to do |format|
      format.xml { render options }
    end
  end

  # This is an "action macro" to confirm something.
  #
  # Pass two options, :correct and :incorrect.  These are the actions to go to if
  # the user says the value is correct or incorrect.
  #
  # The method that calls this method shouldn't do anything else.  You must
  # take care of saying or playing the thing the user is confirming before the
  # user gets to the action that invokes this method.
  def confirm(options)
    raise ArgumentError unless options[:correct]
    raise ArgumentError unless options[:incorrect]

    @choices = [
      Choice.new(
        label(:continue),
        digits(1),
        view_block { @xml.Say("continue.") },
        controller_block { redirect_to :action => options[:correct] }
      ),

      Choice.new(
        label(:try_again),
        digits(3),
        view_block { @xml.Say("try again.") },
        controller_block { redirect_to :action => options[:incorrect] }
      )
    ]
    get_and_handle_choice :action => :gather_one_digit_choice
  end

  # Add spaces between all the letters in a string.
  #
  # This makes the text-to-speech engine speak phone numbers one digit at a time.
  def space_out(s)
    s.split(//).join(' ')
  end

  # Give the user a chance to think.
  def pause(message, next_action)
    if request.get?
      @message = %Q{
        #{message}
        Take a couple minutes to think about what you will say and press any key when you are ready to continue.
      }
      render_xml :action => :pause
    else
      redirect_to :action => next_action
    end
  end

  # Record something and save it to session[:node][attr_name].
  # 
  # Redirect to next_action.
  def record_node_attr(template, attr_name, next_action)
    if request.get?
      render_xml :action => template
    else
      @recording = session[:node][attr_name] = params[:RecordingUrl]
      raise ArgumentError.new("No 'RecordingUrl' parameter passed") unless @recording
      @redirect = url_for :action => next_action
      render_xml :action => :play_recording_and_redirect
    end
  end
end