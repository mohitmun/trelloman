class WelcomeController < ApplicationController 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def index
  	
  end

  def contact_us
    puts "=="*50  
    puts params.inspect

    puts "=="*50
    # UserMailer.send_email("abc.mail@gmail.com", "Message from #{params[:name]}", "Subject: #{params[:subject]} \n\nMessage: #{params[:message]}").deliver_now!
  end


end
