class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :set_user

  def set_user
    params.permit!
    # headers['Access-Control-Allow-Credentials'] = "true"
    # headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    # headers['Access-Control-Request-Method'] = '*'
    # headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def manifest
    headers['Access-Control-Allow-Origin'] = '*'
    send_file("manifest.json")
  end
  
end
