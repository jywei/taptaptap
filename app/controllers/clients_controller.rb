class ClientsController < ApplicationController
  layout 'payments'

  def login
    session[:requst_url] = request.original_url

    if session[:client] && session[:client].authenticated?
      flash[:success] = "You are logged in"
      redirect_to(payment_home_path) and return
    end
    # add_breadcrumb "Login"
  end

  def logout
    session.delete(:client)

    flash[:success] = "Logout"

    redirect_to login_path and return
  end

  def authenticate
    client = session[:client] || Client.new(params[:username], params[:password], params[:auth_token])

    if client.authenticated?
      session[:client] = client

      path = session[:request_url] ? session[:request_url] : payment_home_path

      flash[:success] = "Welcome!"

      redirect_to path and return
    else
      @username = params[:username]
      @password = params[:password]
      @auth_token = params[:auth_token]

      if client.response_by_token[:status] == false
        flash[:error] = "API key is not correct!"
      else
        flash[:error] = "Username or password is not correct!"
      end

      redirect_to login_path and return
    end
  end

end