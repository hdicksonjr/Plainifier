require 'sinatra'
require 'sinatra/partial'
require 'slim'
require 'dotenv'
require 'sequel'
require 'verbs'
require 'yaml'

configure :development do
  require 'better_errors'
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

set :partial_template_engine, :slim
enable :partial_underscores

db_config = YAML.load(File.read("config/database.yml"))
DB = Sequel.connect(db_config[ENV["RACK_ENV"]])

Dotenv.load

Dir["./models/*.rb"].each {|file| require file }
Dir["./modules/*.rb"].each {|file| require file }

get "/" do
  slim :index
end

post "/sentence-submit" do
  sentence = Sentence.new(params["sentence"])

  sentence.word_array.each do |w|
    p w.pos_tag
    p w.final_use
  end

  sentence.final_translated
end

