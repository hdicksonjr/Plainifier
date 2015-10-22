ENV["RACK_ENV"] = "test"

require "rspec"
require "rspec/core/rake_task"

task :run_test do
  RSpec::Core::RakeTask.new(:spec) do |t|
	  t.pattern = "./spec/app_spec.rb"
	end
	Rake::Task["spec"].execute
end

namespace :db do
  require "sequel"
	require "yaml"
	Sequel.extension :migration
	namespace :migrate do
	db_config = YAML.load(File.read("config/database.yml"))
	DB = Sequel.connect(db_config[ENV["RACK_ENV"]])
	  
	  task :all_up do
			Sequel::Migrator.apply(DB, "./db/migrations")
		end

		task :to_num, [:num] do |t, args|
		  Sequel::Migrator.apply(DB, "./db/migrations", args[:num].to_i)
		end
	end
end

