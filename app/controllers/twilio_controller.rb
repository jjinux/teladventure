class TwilioController < ApplicationController
  def index
    respond_to do |format|
      format.xml { render :layout => false }
    end
  end
end