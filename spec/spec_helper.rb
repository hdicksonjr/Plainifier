ENV["RACK_ENV"] = "test"

require 'rack/test'
require 'rspec'
require 'factory_girl'
require File.expand_path '../factories/tags.rb', __FILE__
require File.expand_path '../factories/words.rb', __FILE__

require File.expand_path '../../app.rb', __FILE__

module RspecMixin
  include Rack::Test::Methods
	def app() Sinatra::Application end
end

RSpec.configure do |c|
	c.include RspecMixin 
	c.color = true
	c.tty = true
end
