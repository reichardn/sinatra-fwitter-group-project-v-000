require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions unless test?
    set :session_secret, "secret"
  end

  get '/' do 
    @session = session
    erb :index
  end

  get '/login' do 
    if Helpers.is_logged_in?(session)
      redirect '/tweets'
    else
      erb :'users/login'
    end
  end 

  post "/login" do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect "/tweets"
    else
        redirect "/failure"
    end
  end

  get "/logout" do
    session.clear if Helpers.is_logged_in?(session)
    redirect "/login"
  end

  get '/signup' do
    if Helpers.is_logged_in?(session)
      redirect '/tweets'
    else
      erb :'users/create_user'
    end
  end

  post '/signup' do
    # Receiving sign up
    @user = User.new(username: params[:username], password: params[:password], email: params[:email])
    if @user.save
      session[:user_id] = @user.id
      redirect '/tweets'
    else
      redirect '/signup' 
    end
  end

  get '/tweets' do 
    if Helpers.is_logged_in?(session)
      @user = Helpers.current_user(session)
      erb :'tweets/tweets'
    else
      redirect '/login'
    end
  end

  get '/users/:slug' do 
    @user = User.find_by_slug(params[:slug])
    if @user
      erb :'users/show_user'
    else
      redirect '/login'
    end
  end

  get '/tweets/new' do 
    if Helpers.is_logged_in?(session)
      erb :'tweets/create_tweet'
    else
      redirect '/login'
    end
  end

  post '/tweets/new' do 
    t = Tweet.new(content: params[:content], user: Helpers.current_user(session))
    if t.save
      t.content
    else 
      redirect '/tweets/new'
    end
  end

  get '/tweets/:id' do
    if Helpers.is_logged_in?(session)
      @tweet = Tweet.find(params[:id])
      @match = @tweet.user_id == session[:user_id]
      erb :'tweets/show_tweet'
    else 
      redirect '/login'
    end
  end

  get '/tweets/:id/edit' do
    if !Helpers.is_logged_in?(session)
      redirect '/login'
    end

    @tweet = Tweet.find(params[:id])
    if  @tweet.user_id == session[:user_id]
      erb :'tweets/edit_tweet'
    else 
      redirect '/tweets'
    end
  end

  post '/tweets/:id' do
    @tweet = Tweet.find(params[:id])
    if @tweet.update(content: params[:content])
      redirect '/tweets'
    else
      redirect "tweets/#{params[:id]}/edit" 
    end
  end

  delete '/tweets/:id/delete' do
    @tweet = Tweet.find(params[:id])
    if @tweet.user_id == session[:user_id]
      @tweet.delete
    end
    redirect 'tweets'
  end

end





















































