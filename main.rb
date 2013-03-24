require 'sinatra'
require 'json'
require "net/https"
require "uri"

@config = JSON.load(open('config.json').read)

post '/github_hook' do
  push = JSON.parse(params[:payload])
  repo_name = push['repository']['name']
  url = push['repository']['url']
  commiters = []
  push['commits'].each do |commit|
    name = commit['commiter']['name']
    commiters << name unless commiters.include?(name)
  end

  commiter_name = commiters.join(', ')
  message = "@all #{commiter_name} just pushed something to #{repo_name}, check it out here: #{url}"

  @config['message'] = message


  url = "https://api.hipchat.com/v1/rooms/message?auth_token=#{@config['auth_token']}"
  uri = URI.parse(url)
  res = Net::HTTP.post_form(uri, @config)
  puts res.body
end
