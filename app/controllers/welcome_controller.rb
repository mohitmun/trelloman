class WelcomeController < ApplicationController 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  def index
  	
  end

  def powerup_index
    headers["X-Frame-Options"] = "ALLOWALL"
    gon.card_button_text = "Auto Due Date"
    gon.application_name = User.get_manifest.name
    render "welcome/powerup_index"
  end

  def auto_due
    if current_user
      current_user.auto_update_card = params[:enable]
      current_user.save
      render json: {auto_due: current_user.auto_update_card}
    else
      render json: {message: "User not signed in"}
    end
  end

  def save_token
    u = User.create_user_from_trello_token(params[:token])
    if !u.blank?
      sign_in u
    end
    render json: {success: true}
  end

  def incoming_trello
    # test_json = JSON.parse(File.read("incoming_trello.json"))
    if request.post?
      User.handle_webhook(params[:welcome])
    end
    render json: {success: true}
  end

  def incoming_sutime
    User.incoming_sutime(params[:welcome])
    render json: {success: true}
  end

end
