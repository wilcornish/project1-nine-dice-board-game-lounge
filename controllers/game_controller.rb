require( 'sinatra' )
require( 'sinatra/contrib/all' )
require_relative( '../models/game.rb' )
also_reload( '../models/*' )
require('pry-byebug')
#index
get '/games' do
  @games = Game.all()
  erb ( :'games/index' )
end

#new
get '/games/new' do
  erb( :'games/new' )
end

#edit
get '/games/:id/edit' do
  @game = Game.find(params['id'].to_i)
  erb ( :'games/edit' )
end

#show
get '/games/:id' do
  @game = Game.find(params['id'].to_i)
  erb ( :'games/show' )
end

#create
post '/games' do
  game = Game.new(params)
  game.save
  redirect to ('/games')
end

#update
post '/games/:id' do
  @game = Game.new(params)
  @game.update()
  # binding.pry
  redirect to ("/games/#{params[:id]}")
end
