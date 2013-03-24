require 'sinatra'
require 'rubygems'

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

require './main'
run Sinatra::Application
