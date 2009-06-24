require 'rubygems'
require 'sinatra'
require 'yaml'
require 'sequel'
require 'tzinfo'
require 'json'
require 'haml'
require 'httparty'
gem 'twitter'
require 'twitter'
require 'twitter/httpauth'
require 'chronic'

configure do
  DB     = Sequel.sqlite('db.sqlite3')
  CONFIG = YAML.load(File.read 'config.yml')
end

DB.create_table :teams do
  primary_key :id

  String :name
  String :time_zone
  String :twitter_account
end unless DB.table_exists?(:teams)

module TwitterSession
  def twitter_session
    @twitter_session ||= Twitter::Base.new(twitter_auth)
  end
  
  def twitter_auth
    @twitter_auth ||= Twitter::HTTPAuth.new(
        CONFIG['twitter']['username'],
        CONFIG['twitter']['password']
      )
  end
end

class Team < Sequel::Model
  plugin :validation_class_methods

  validates_presence_of :name,
    :message => "Can't be blank"

  validates_format_of :name, 
    :with    => /^[A-Za-z0-9]+[A-Za-z0-9\-_]*$/,
    :message => 'Can only include a-z, dashes and unerscores'

  validates_uniqueness_of :name,
    :message => 'Not available'

  validates_presence_of :time_zone,
    :message => "Can't be blank"

  validates_presence_of :twitter_account,
    :message => "Can't be blank"

  def validate
    Team.validate(self)

    if errors.empty? && Twitter.user(self.twitter_account).error?
      errors[:twitter_account] << 'Does not exist'
    end
  end
  
  def messages
    DirectMessage.messages_for(self.twitter_account)
  end
  
  def coffee_times
    messages.map do |msg|
      Chronic.parse(msg, :now)
    end
  end
  
  include TwitterSession
  
  def after_save
    begin
      twitter_session.friendship_create(self.twitter_account)
    rescue Twitter::General
      # bah, already following - pre-check?
    end
  end
end

class DirectMessage
  attr_accessor :username, :created_at

  def initialize(attributes = {})
    @username   = attributes[:username]
    @created_at = attributes[:created_at]
  end
  
  self.extend(TwitterSession)

  def self.get_messages
    twitter_session.direct_messages.map do |msg|
      self.new(
          :username   => msg.sender_screen_name,
          :created_at => Time.parse(msg.created_at),
          :message    => msg.txt
        )
    end
  end
  
  def self.messages_for(user, since=20)
    get_messages.select do |msg|
      msg.username == user && msg.created_at > (Time.now.utc - (since*60))
    end
  end
end

helpers do
  include Rack::Utils; alias_method :h, :escape_html
  
  def random_quip
    quips = [
        'it sure is...',
        "and don't you know it...",
        'finally!',
        'go get it!',
        'why not try a ristretto?',
        'emphatically'
      ]
    quips[rand(quips.size)]
  end
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
  @yes = !!DirectMessage.messages_for(@team.twitter_account, 1)
  haml :team
end