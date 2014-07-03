require 'rubygems'
require 'bundler/setup'

task :console do
  require 'pry'
  require 'trepscore-services'
  Service.load_services
  ARGV.clear
  Pry.start
end