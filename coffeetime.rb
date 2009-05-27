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

class Team < Sequel::Model
  validates_presence_of   :name
  validates_uniqueness_of :name
  validates_format_of     :name, :with => /^[A-Za-z0-9]+[A-Za-z0-9\-_]*$/
end

class Subscriber < Sequel::Model
  validates_presence_of :team_id
  validates_presence_of :twitter_username
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

post '/team.json' do
  @team = Team.new(params[:team])
  if @team.save
    # return success json
  else
    # return error json
  end
end