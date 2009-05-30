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

Sequel::Model.plugin(:validation_class_methods)

class Team < Sequel::Model
  # raise_on_save_failure = true
  validates_presence_of :name,
    :message => "Can't be blank"
  validates_format_of :name, 
    :with => /^[A-Za-z0-9]+[A-Za-z0-9\-_]*$/,
    :message => 'Can only include a-z, dashes and unerscores'
  validates_uniqueness_of :name,
    :message => 'Not available'
  validates_presence_of :time_zone,
    :message => "Can't be blank"
  validates_presence_of :twitter_account,
    :message => "Can't be blank"
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
  if attribute = params[:validate]
    status 200
    team.valid?
    if team.errors[attribute.to_sym].empty?
      {:no_errors => true}.to_json
    else
      {:no_errors => false, :errors => team.errors[attribute.to_sym]}.to_json
    end
  else
    begin
      team.save
      status 201
      {:success => true, :team => {:name => team.name}}.to_json
    rescue Sequel::ValidationFailed
      status 200
      {:success => false, :errors => team.errors}.to_json
    end
  end
end

get '/:team_name' do
  @team = Team[:name => params[:team_name]] || raise(Sinatra::NotFound)
  haml :team
end