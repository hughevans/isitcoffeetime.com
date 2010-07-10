require "rubygems"
require "sinatra"
require "yaml"
require "active_model"
require "mongoid"
require "tzinfo"
require "json"
require "haml"
# require "httparty"
gem "twitter"
require "twitter"
require "twitter/httpauth"
require "chronic"

configure do  
  Mongoid::Config.instance.from_hash(YAML.load(File.read("config/database.yml")))
  CONFIG = YAML.load(File.read("config/config.yml"))
end

module TwitterSession
  def twitter_session
    @twitter_session ||= Twitter::Base.new(twitter_auth)
  end

  def twitter_auth
    @twitter_auth ||= Twitter::HTTPAuth.new(
        CONFIG["twitter"]["username"],
        CONFIG["twitter"]["password"]
      )
  end
end

class Team
  include Mongoid::Document

  field :name
  field :time_zone
  field :twitter_account

  validates_presence_of :name, :time_zone, :twitter_account

  validates_format_of :name,
    :with    => /^[A-Za-z0-9]+[A-Za-z0-9\-_]*$/, 
    :message => "Can only include a-z, dashes and unerscores"

  validates_uniqueness_of :name, :message => "Not available"

  def validate
    if errors.empty? && Twitter.user(self.twitter_account).error?
      errors[:twitter_account] << "Does not exist"
    end
  end

  def messages
    # @messages ||= DirectMessage.messages_for(self.twitter_account)
    DirectMessage.messages_for(self.twitter_account)
  end

  def coffee_times
    messages.map { |msg|
      time = Chronic.parse(msg.text)
      time..(time + 20*60) if time
    }.compact
  end

  def coffee_time_now?
    coffee_times.any? {|d| d.include?(Time.now)}
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
  attr_accessor :username, :created_at, :text

  def initialize(attributes = {})
    @username   = attributes[:username]
    @created_at = attributes[:created_at]
    @text       = attributes[:text]
  end

  self.extend(TwitterSession)

  def self.get_messages
    twitter_session.direct_messages.map do |msg|
      self.new(
          :username   => msg.sender_screen_name,
          :created_at => Time.parse(msg.created_at),
          :text       => msg.text
        )
    end
  end

  def self.messages_for(user, since=24*60)
    get_messages.select do |msg|
      msg.username == user && msg.created_at > (Time.now.utc - (since*60))
    end
  end
end

helpers do
  include Rack::Utils; alias_method :h, :escape_html

  def random_quip
    quips = [
      "it sure is...",
      "and don’t you know it...",
      "finally!",
      "go get it!",
      "why not try a ristretto?",
      "emphatically",
      "so hit up <a href=\"http://decafsucks.com\">decafsucks.com</a>"
    ]
    quips[rand(quips.size)]
  end
end

get "/" do
  haml :home
end

get "/:style.css" do
  content_type "text/css", :charset => "utf-8"
  sass :"stylesheets/#{params[:style]}"
end

post "/teams" do
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
    rescue # TODO: mongoid exception failed save
      status 200
      {:success => false, :errors => team.errors}.to_json
    end
  end
end

get "/:team_name" do
  @team = Team.find(:first, :conditions => {:name => params[:team_name]})
  # raise(Sinatra::NotFound)
  haml :team
end
