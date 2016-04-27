class ArticlesController < ApplicationController
  load_and_authorize_resource
  layout 'blog'

  def index
    respond_to do |format|
      format.html
      format.rss { @articles = Article.all() }
    end
  end

  def new
    @article = Article.new
  end

  def create
    #render plain: params[:article].inspect
    @article = Article.new(article_params)

    if @article.save
     redirect_to @article
    else
      render 'new'
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render 'edit'
    end
  end
  def show
    @article = Article.find(params[:id])
    currentViewCount = @article.view_count || 0

    logger.info "currentViewCount: " + currentViewCount.to_s
    @article.update(view_count: currentViewCount+1)
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to articles_path
  end

  private
  def article_params
    params.require(:article).permit(:title, :text, :tag_list, :tag_list => [])
  end
end
