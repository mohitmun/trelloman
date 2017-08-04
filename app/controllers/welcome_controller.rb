class WelcomeController < ApplicationController 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  def index
  	
  end

  def powerup_index
    headers["X-Frame-Options"] = "ALLOWALL"
    #todo if audo due date then dont show button
    gon.host = User::HOST
    gon.card_button_text = User.get_manifest.name
    gon.application_name = User.get_manifest.name
    render "welcome/powerup_index"
  end

  def send_email
    url = nil
    if !params[:to].blank? && !params[:sub].blank? && !params[:body].blank?
      res = current_user.send_email(params)
      url = "https://mail.google.com/mail/u/0/?ibxr=0#all/" + res.id
    end

    render json: {success: true, url: url}
  end

  def oauth2callback
    if current_user
      current_user.get_access_token(params[:code])
    end
    render json: {success: true}
  end

  def oauth
    redirect_to User::GMAIL_AUTH_URL
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
    u = User.create_user_from_trello_token(params[:token], tz: params[:tz])
    if !u.blank?
      sign_in u
    end
    if !params[:wh].blank?
      u.set_trello_webhook
    end
    render json: {success: u.authorized?}
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
