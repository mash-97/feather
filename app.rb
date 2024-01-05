require 'sinatra'
require 'json'

require_relative('vote.rb')

set(:bind, '0.0.0.0')
set(:port, '8080')
enable(:sessions)
set(:session_store, Rack::Session::Pool)
set(:views, settings.root + '/templates')
set(:public_folder, settings.root + '/statics')

get('/') do
  @title = 'Feather'
  @request = request

  erb :default_layout, :layout => false do
    erb :index
  end
end

get('/vote') do
  @title = 'Feather | Vote'
  @request = request
  if not getVotedIPs().include?(@request.ip.strip()) then
    erb :default_layout, :layout => false do
      erb :vote, locals: {players: votesOfPlayerAgainst(@request.ip.to_s)}
    end
  else
    erb :default_layout, :layout => false do
      erb <<~HTML
        <h1 class='w3-text-red w3-margin-top'>You already voted!</h1>
        <script type='text/javascript'>
          setTimeout(()=>{location.replace('/')}, 2000)
        </script>
      HTML
    end
  end
end

post('/vote') do
  @title = 'Feather | Vote'
  @request = request
  @data = @request.params

  players = getAllPlayerList()
  votes = {}
  players.each do |player|
    votes[player] = @data[player].to_i || 0 
  end
  updateVotesForIP(@request.ip, votes)
  redirect to('/avg-votes-of-players')
end

get('/admin') do 
  @title = 'Feather | Admin'
  @request = request
  redirect to('/') if not @request.session['admin']
  erb :default_layout, :layout => false do
    erb :admin, locals: {data: loadVoteData()}
  end
end

get('/admin-access') do
  @title = 'Feather | Admin Access'
  @request = request
  redirect to('/admin') if @request.session['admin']
  erb :default_layout, :layout => false do
    erb :admin_access
  end
end
post('/admin-access') do
  @title = 'Feather | Admin Access'
  @request = request
  @data = request.params

  if @data['admin-password'] == 'feather box' then
    @request.session['admin'] = true
    redirect to('/admin')
  end
  redirect to('/')
end

get('/admin-insert-players') do
  @title = 'Feather | Insert Player'
  @request = request

  erb :default_layout, :layout => false do
    erb :admin_insert_players
  end
end

post('/admin-insert-players') do
  @title = 'Feather | Insert Player'
  @request = request
  @data = request.params
  player_names = @data['player_names'].split(',').collect{|n| n.strip}
  insertPlayers(player_names)
  redirect to('/avg-votes-of-players')
end

get('/avg-votes-of-players') do
  @title = 'Feather | Avg. Votes of Player'
  @request = request

  players = averageVoteOfAllPlayers()
  players = players.to_a.sort{|x, y| x[1]<=>y[1]}.reverse.to_h

  pp = []

  if getPairGenerationStatus() then 
    pp = players.to_a.sort{|x, y| x[1]<=>y[1]}
    pp = pp.zip(pp.reverse)
  end

  erb :default_layout, layout: false do
    erb :avg_votes_of_players, locals: {players: players, possible_pairs: pp}
  end
end

get('/admin-reset-votes') do 
  @title = 'Feather | Admin | Reset Votes'
  @request = request

  resetVotes()
  
  erb :default_layout, :layout => false do
    erb <<~HTML
      <h1 class='w3-text-red w3-margin-top'>Votes Has Been Discarded!</h1>
      <script type='text/javascript'>
        setTimeout(()=>{location.replace('/admin')}, 2000)
      </script>
    HTML
  end
end

get('/admin-reset-votes-for-ips') do
  @title = 'Feather | Admin | Reset Votes for IPs'
  @request = request


  erb :default_layout, :layout => false do
    erb :admin_reset_votes_for_ips
  end
end

post('/admin-reset-votes-for-ips') do
  @title = 'Feather | Admin | Reset Votes for IPs'
  @request = request
  @data = request.params

  ip_addresses = @data['ip_addresses'].split(',').collect{|ip| ip.strip()}.filter{|ip| ip=~/^(\d{1,3}\.){3}\d{1,3}$/}
  resetForIPs(ip_addresses)

  erb :default_layout, :layout => false do
    erb <<~HTML
      <h1 class='w3-text-red w3-margin-top'>Votes Discarded for: #{ip_addresses}!</h1>
      <script type='text/javascript'>
        setTimeout(()=>{location.replace('/admin')}, 5000)
      </script>
    HTML
  end
end

get('/admin-generate-pairs') do
  @title = 'Feather | Admin | Generate Pairs'
  @request = request
  generatePairs()
  erb :default_layout, :layout => false do
    erb <<~HTML
      <h1 class='w3-text-red w3-margin-top'>People can See Pairs now!</h1>
      <script type='text/javascript'>
        setTimeout(()=>{location.replace('/admin')}, 2000)
      </script>
    HTML
  end
end

get('/admin-ungenerate-pairs') do
  @title = 'Feather | Admin | Un Generate Pairs'
  @request = request
  unGenerate()
  erb :default_layout, :layout => false do
    erb <<~HTML
      <h1 class='w3-text-red w3-margin-top'>People won't See Pairs now!</h1>
      <script type='text/javascript'>
        setTimeout(()=>{location.replace('/admin')}, 2000)
      </script>
    HTML
  end
end

get('/admin-hard-reset') do
  @title = 'Feather | Admin | Hard Reset'
  @request = request
  hardReset()

  erb :default_layout, :layout => false do
    erb <<~HTML
      <h1 class='w3-text-red w3-margin-top'>A Hard Reset Has Been Made!</h1>
      <script type='text/javascript'>
        setTimeout(()=>{location.replace('/admin')}, 10000)
      </script>
    HTML
  end
end

get('/sleep/:seconds') do |seconds|
  puts("#>> Threaded: #{settings.threaded}")
  sleep(seconds.to_i)
  redirect back
end

