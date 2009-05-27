require 'rubygems'
require 'sequel'
require 'sinatra'
require 'haml'

DB = Sequel.sqlite('coffeetime.db')

DB.create_table :teams do
  primary_key :id
  String :name
end unless DB.table_exists?(:teams)

DB.create_table :subscribers do
  Integer :team_id
  String :twitter_username
end unless DB.table_exists?(:subscribers)

helpers do
end

get '/' do
  haml :home
end

get '/:style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :"stylesheets/#{params[:style]}"
end