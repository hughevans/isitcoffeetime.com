require 'rubygems'
require 'sinatra'
require 'sequel'
require 'tzinfo'
require 'json'
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

class Team < Sequel::Model
  plugin :validation_class_methods
  
  # validates_presence    :name
  # validates_uniqueness  :name
  # validates_format      :name, :with => /^[A-Za-z0-9]+[A-Za-z0-9\-_]*$/
end

class Subscriber < Sequel::Model
  # validates_presence  :team_id
  # validates_presence  :twitter_username
end

helpers do
end

get '/' do
  haml :home
end

get '/:style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :"stylesheets/#{params[:style]}"
end

post '/teams' do
  content_type :json
  @team = Team.new(params[:team])
  
  if @team.save
    status 201
    {:success => true, :team => {:name => @team.name}}.to_json
  else
    status 400
    {:success => false, :team => {:name => @team.name}, :errors => @team.errors}.to_json
  end
end