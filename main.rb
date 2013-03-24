require 'sinatra'

post '/github_hook' do
  push = JSON.parse(params[:payload])
  "I got some JSON: #{push.inspect}"
end
