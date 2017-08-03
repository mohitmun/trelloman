class WelcomeController < ApplicationController 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  def index
  	
  end

  def powerup_index
    headers["X-Frame-Options"] = "ALLOWALL"
    render "welcome/powerup_index"
  end

  def save_token
    User.create_user_from_trello_token(params[:token])
    render json: {success: true}
  end

  def incoming_trello
    # test_json = JSON.parse(File.read("incoming_trello.json"))
    if request.post?
      User.handle_webhook(params[:welcome])
    end
    render json: {success: true}
  end

end
