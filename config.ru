require "rubygems"
require "./app.rb"
require "sass/plugin/rack"

use Sass::Plugin::Rack

run Sinatra::Application
