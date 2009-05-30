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
  String :time_zone
  String :twitter_account
end unless DB.table_exists?(:teams)

DB.create_table :subscribers do
  Integer :team_id
  String :twitter_username
end unless DB.table_exists?(:subscribers)

Sequel::Model.plugin(:validation_class_methods)

class Team < Sequel::Model
  validates_presence_of :name,
    :message => "Can't be blank"
  validates_format_of :name, 
    :with => /^[A-Za-z0-9]+[A-Za-z0-9\-_]*$/,
    :message => 'Can only include a-z, dashes and unerscores'
  validates_uniqueness_of :name,
    :message => 'Not available'
end

class Subscriber < Sequel::Model
  # validates_presence  :team_id
  # validates_presence  :twitter_username
end

helpers do
  include Rack::Utils; alias_method :h, :escape_html
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
  team = Team.new(params[:team])
  if params[:validate_only]
    status 200
    team.valid?
    if team.errors.empty?
      {:no_errors => true}.to_json
    else
      {:no_errors => false, :errors => team.errors}.to_json
    end
  elsif team.save
    status 201
    {:success => true, :team => {:name => team.name}}.to_json
  else
    status 200
    {:success => false, :errors => team.errors.name[0]}.to_json
  end
end