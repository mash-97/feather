require 'sinatra'

enable(:sessions)
set(:session_store, Rack::Session::Pool)

set(:views, settings.root + '/templates')

get('/') do
  
end

get('/session') do
  puts(session.keys(), session.values().map{|x|x.class})
  puts("tracking: #{session['tracking'].map{|x|x.class}}")
  session.inspect.to_s
end


get('/request') do
  puts(request)
  puts(request.class)
  puts(request.methods)
  return request.to_s
end

get('/stream') do
  stream do |out|
    out << "It's gonna be legen -\n"
    sleep(0.5)
    out << " (wait for it) \n"
    sleep(1)
    out << "- dary!\n"
  end
end


get('/events') do
  events = Dir["**/*"]
  erb :index, :locals => {:events => events}
end

