require 'rubygems'
require 'sinatra'
require 'haml'

helpers do
end

get '/' do
  haml :home
end

get '/:style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :"stylesheets/#{params[:style]}"
end

post '/team' do
  teams = DB[:teams]
  teams.insert(params[:team]) do
    raise "Eeek!"
  end
  redirect('/')  
end