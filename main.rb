require 'sinatra'
require 'json'
require "net/https"
require "uri"

@config = JSON.load(open('config.json').read)

post '/github_hook' do
  push = JSON.parse(params[:payload])
  puts push
  repo_name = push['repository']['name']
  puts repo_name
  url = push['repository']['url']
  puts url
  commiters = []
  push['commits'].each do |commit|
    name = commit['commiter']['name']
    commiters << name unless commiters.include?(name)
  end
  puts commiters

  commiter_name = commiters.join(', ')
  puts commiter_name

  message = "@all #{commiter_name} just pushed something to #{repo_name}, check it out here: #{url}"
  puts message

  @config['message'] = message
  puts @config

  url = "https://api.hipchat.com/v1/rooms/message?auth_token=#{@config['auth_token']}"
  uri = URI.parse(url)
  res = Net::HTTP.post_form(uri, @config)
  puts res.body
end
