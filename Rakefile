# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "bf4-browsercms"
    gem.summary = %Q{BrowserCMS is a general purpose, open source Web Content Management System (CMS), written in Ruby on Rails.}
    gem.description = "A fork that can be used as a gem with Bundler as the model Task has been changed to Task_Item to remove a reserved word namespace issue in Rails. There is also a corresponding bf4-bcms_news. You'll likely want to require active_support and cms/init in your rails initializer."
    gem.email = "dev@benjaminfleischer.com"
    gem.homepage = "http://www.browsercms.org"
    gem.authors = ["BrowserMedia", "Benjamin Fleischer"]
    gem.rubyforge_project = 'browsercms' # This line would be new

    gem.files = Dir["rails/*.rb"]
    gem.files += Dir["bf4-browsercms.gemspec"]
    gem.files += Dir["doc/app/**/*"]
    gem.files += Dir["doc/guides/html/**/*"]
    gem.files += Dir["app/**/*"]
    gem.files += Dir["db/migrate/[0-9]*_*.rb"]
    gem.files += Dir["db/demo/**/*"]
    gem.files += Dir["lib/**/*"]
    gem.files += Dir["rails_generators/**/*"]
    gem.files += Dir["public/stylesheets/cms/**/*"]
    gem.files += Dir["public/javascripts/jquery*"]
    gem.files += Dir["public/javascripts/cms/**/*"]
    gem.files += Dir["public/fckeditor/**/*"]
    gem.files += Dir["public/site/**/*"]
    gem.files += Dir["public/images/cms/**/*"]
    gem.files += Dir["public/themes/**/*"]
    gem.files += Dir["templates/*.rb"]

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://rubygems.com"
end

# These are new tasks
begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do

    desc "Release gem to RubyForge"
    task :release => ["rubygems:release:gem"]


  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubygems environment is not configured."
end
