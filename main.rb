require 'sinatra'
require 'json'
require "net/https"
require "uri"

post '/github_hook' do
  config = JSON.load(open('config.json').read)
  push = JSON.parse(params[:payload])
  repo_name = push['repository']['name']
  url = push['repository']['url']
  commiters = []
  push['commits'].each do |commit|
    name = commit['author']['name']
    commiters << name unless commiters.include?(name)
  end

  commiter_name = commiters.join(', ')

  message = "@all `#{commiter_name}` just pushed something to #{repo_name}, check it out here: `#{url}`"

  config['message'] = message

  uri = URI("https://api.hipchat.com/v1/rooms/message?auth_token=#{config['auth_token']}")
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') do |http|

    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data(config)
    http.request req # Net::HTTPResponse object
  end
end
