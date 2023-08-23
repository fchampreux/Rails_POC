class HomeController < ApplicationController

# Check for active session. Comment this out if this home page remains public
#before_action :authenticate_user!
load_and_authorize_resource

  def show
  end
  
end