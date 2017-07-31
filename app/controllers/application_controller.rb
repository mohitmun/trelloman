class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  rescue_from ActionController::RoutingError, with: :render_404  
  protect_from_forgery with: :exception
  before_filter :set_user


  def render_404
    respond_to do |format|
      format.html redirect_to :back
    end
  end

  def set_user
    @current_user = current_user
    @root_url = Rails.application.routes.url_helpers.root_url(host: request.host_with_port)
    # @current_user ||= User.find(session[:monologue_user_id]) if session[:monologue_user_id]
  end

  def after_sign_in_path_for(resource)
    session[:monologue_user_id] = current_user.id
    
    
    if resource.admin
      respond_to do |format|
        return Monologue::Engine.routes.url_helpers.admin_posts_path(scope: "blog")
      end
    elsif resource.sign_in_count <2
      respond_to do |format|
        return edit_user_registration_path
      end
    elsif !session[:redirect_to].blank?
      mama = session[:redirect_to]
      session[:redirect_to] = nil
      return mama
    end
    return root_url
  end
  
end
