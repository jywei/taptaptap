class Admin::AuthTokensController < Admin::ApplicationController

  before_action :check_sources, only: [:update, :create]
  before_action :set_token, only: [:show, :edit, :update, :destroy, :settings]
  
  def index
    @tokens = AuthToken.all
    add_breadcrumb 'Auth tokens', :admin_auth_tokens_path  
  end 

  def new
    @token = AuthToken.new
    add_breadcrumb 'Auth token', :admin_auth_tokens_path
    add_breadcrumb 'New'
  end 

  def create
    @token = AuthToken.new(token_params)
    if @token.save
      redirect_to admin_auth_tokens_path
    else
      render :new
    end
  end  

  def edit
    add_breadcrumb 'Auth token', :admin_auth_tokens_path
    add_breadcrumb 'Edit'
  end  

  def update
    if @token.update(token_params)
      redirect_to admin_auth_tokens_path, notice: 'Token was successfully updated.'  
    else
      render :edit 
    end
  end  

  def destroy
    @token.destroy
    redirect_to admin_auth_tokens_path, notice: 'Token was successfully destroyed.' 
  end

  def settings
    @sources = PostingConstants::SOURCES 
  end 

  def generate_token
    token = Digest::MD5.new
    token.update Time.now.to_s

    render json: { token: token.hexdigest }.to_json
  end 

  private

  def set_token
    @token = AuthToken.find(params[:id])
  end


  def token_params
    params.require(:auth_token).permit!
  end 

  def check_sources
    if token_params[:sources].blank?
      token_params[:sources] = []
    else
      token_params[:sources] = token_params[:sources].select{|source| source.present?}
    end   
  end  
end  