require 'sinatra'
require 'json'
require "net/https"
require "uri"
require "erb"

post '/github_hook' do
  config = JSON.load(open('config.json').read)
  push = JSON.parse(params[:payload])
  repo_name = push['repository']['name']
  url = push['repository']['url']
  commiters = []
  commits = push['commits']
  commits.each do |commit|
    name = commit['author']['name']
    commiters << name unless commiters.include?(name)
  end

  commiter_name = commiters.join(', ')

  template = ERB.new(open('digest_template.erb').read)

  config['message'] = template.result(binding)

  uri = URI("https://api.hipchat.com/v1/rooms/message?auth_token=#{config['auth_token']}")
  Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https') do |http|

    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data(config)
    http.request req # Net::HTTPResponse object
  end
end
