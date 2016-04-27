class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :queryArticles
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def queryArticles
    @key_word = params[:key_word]
    @tag = params[:tag]

    if (@key_word)
      @articles  = Article.where("text like ? or title like ?", "%" + params[:key_word] + "%", "%" + params[:key_word] + "%").order(updated_at: :desc).page(params[:page]).per(Settings.page_size)
    elsif(@tag)
      @articles = Article.tagged_with(@tag).page(params[:page]).per(Settings.page_size)
    else
      @articles = Article.page(params[:page]).per(Settings.page_size).order(updated_at: :desc)
    end
    @hot_comments = Comment.order(updated_at: :desc).limit(Settings.hot_comments_size)

    @hot_articles = Article.order(view_count: :desc).limit(Settings.hot_articles_size)
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      if User.count == 1
        resource.add_role 'admin'
      end
      resource
    end
    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password,
                                                            :password_confirmation, :remember_me, :avatar, :avatar_cache) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password,
                                                                   :password_confirmation, :current_password, :avatar, :avatar_cache) }
  end

end
