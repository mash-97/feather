require 'sinatra'
require 'json'


set(:bind, '0.0.0.0')
set(:port, '8080')
enable(:sessions)
set(:session_store, Rack::Session::Pool)

set(:views, settings.root + '/templates')

get('/') do
  puts("authorized: #{@authorized}")
  puts("request.session: #{request.session.inspect}")
  @request = request
  @title = 'Feather'
  if not @request.session['username'] then
    @authorized = false
  else
    @authorized = true
  end
  erb :index, locals: {events: [1,2,3]}
end

post('/') do
  puts("request: #{request.inspect}")
  
  @request = request
  @request.body.rewind
  # data = JSON.parse request.body.read
  data = @request.params
  puts("data: #{data}")

  @title = 'Feather'
  if not data['username'].empty? and data['username']=='mash' then
    if not data['password'].empty? and data['password']=='hash' then
      @authorized = true
      request.session['username'] = data['username']
    end
  end
  redirect to('/')
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

