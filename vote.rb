require 'yaml'

VOTES_FOLDER = File.join(File.dirname(File.absolute_path(__FILE__)), 'votes')
VOTES_FILE = File.join(VOTES_FOLDER, 'votes.yaml')
VOTES_DATA_INIT = {
  players: [],
  votes: {}, 
  pairs_generated: false
}

<<~D
  {
    players: ['a', 'b', 'c'],
    votes: {
      '2.2.1.3': {
        a: 3,
        b: 4
      },
      '192.168.1.1': {
        b: 3,
        a: 1
      }
    }
    voted: []
    pairs_generated: false
  }
D


if not File.exists?(VOTES_FOLDER) then 
  Dir.mkdir(VOTES_FOLDER)
  File.open(VOTES_FILE, 'w') do |f|
    YAML.dump(VOTES_DATA_INIT, f)
  end

elsif File.file?(VOTES_FOLDER) then
  Dir.rmdir(VOTES_FOLDER)
  Dir.mkdir(VOTES_FOLDER)
  File.open(VOTES_FILE, 'w') do |f|
    YAML.dump(VOTES_DATA_INIT, f)
  end
end

class String
  def snakeCase()
    return self.split(' ').map{|s| s=s.downcase(); s[0]=s[0].upcase(); s}.join(' ')
  end
end 

def loadVoteData()
  data = VOTES_DATA_INIT
  File.open(VOTES_FILE, 'r') do |f|
    data = YAML.load(f)
  end
  return data
end

def saveVoteData(data)
  if data.class != Hash then
    raise Exception.new("#{data} is not a Hash!")
  end
  File.open(VOTES_FILE, 'w') do |f|
    YAML.dump(data, f)
  end
  return data
end

def resetVotes()
  data = loadVoteData()
  data[:votes].keys.each do |ip|
    data[:votes][ip] = {}
    data[:players].each do |player|
      data[:votes][ip][player] = 0
    end
  end
  data[:voted] = []
  data[:pairs_generated] = false
  saveVoteData(data)
  return data[:votes].keys()
end

def resetForIPs(ips)
  data = loadVoteData()
  ips.each do |ip|
    data[:votes][ip] = {}
    data[:players].each do |player|
      data[:votes][ip][player] = 0
    end
    data[:voted].delete(ip)
  end
  saveVoteData(data)
end

def playerExists?(player_name)
  player_name = player_name.strip.downcase()
  data = loadVoteData()

  return data[:players].include?(player_name)
end

def getAllPlayerList()
  data = loadVoteData()
  return data[:players]
end

def insertPlayers(player_names)
  data = loadVoteData()
  player_names.each do |player_name|
    player_name = player_name.strip.downcase()
    if data[:players].include?(player_name)  then
      next
    else
      data[:players] << player_name
      data[:votes].keys.each {
        |ip| 
        data[:votes][ip][player_name] = 0
      }
    end
  end
  saveVoteData(data)
  return true
end

def deletePlayer(player_name)
  player_name = player_name.strip.downcase()
  data = loadVoteData()
  data[:players].delete(player_name)
  data[:votes].each{|ip, votes|
    data[:votes][ip].delete(player_name)
  }
  saveVoteData(data)
end

def updateVote(ip, player_name, vote)
  ip = ip.strip()
  player_name = player_name.strip.downcase()
  data = loadVoteData()
  if not data[:votes][ip] then
    data[:votes][ip] = {player_name => vote}
  else
    data[:votes][ip][player_name] = vote
  end
  saveVoteData(data)
end

def averageVotesOfPlayer(player_name)
  player_name = player_name.strip.downcase()
  data = loadVoteData()

  votes = []
  data[:votes].each{
    |ip, votes|
    if data[:votes][ip][player_name] then
      votes << data[:votes][ip][player_name].to_i
    end
  }

  return (votes.sum.to_f/votes.length).round(2)
end

def averageVoteOfAllPlayers()
  data = loadVoteData()

  players_votes = {}
  data[:players].each {|p| players_votes[p] = []}
  data[:votes].each{
    |ip, votes|
    votes.each{|player_name, vote| players_votes[player_name] << vote}
  }
  players_votes.each{|player, votes|
    players_votes[player] = (votes.sum.to_f/votes.length).round(2)
  }

  return players_votes
end


def votesOfPlayerAgainst(ip)
  ip = ip.strip()
  data = loadVoteData()

  if not data[:votes][ip] then
    data[:votes][ip] = {}
    data[:players].each{|p| data[:votes][ip][p]=0}
    saveVoteData(data)
  end

  return data[:votes][ip]
end

def updateVotesForIP(ip, votes)
  ip = ip.strip()
  data = loadVoteData()
  
  data[:votes][ip] = votes
  data[:voted] << ip
  saveVoteData(data)
end

def updateVotedForIP(ip)
  ip = ip.strip()
  data = loadVoteData()
  data[:voted].include?(ip) ? nil : data[:voted] << ip
  saveVoteData(data)
  return ip
end

def getVotedIPs()
  data = loadVoteData()
  return data[:voted]
end


def unGenerate()
  data = loadVoteData()
  data[:pairs_generated] = false
  saveVoteData(data)
end

def generatePairs()
  data = loadVoteData()
  data[:pairs_generated] = true
  saveVoteData(data)
end

def getPairGenerationStatus()
  data = loadVoteData()
  return data[:pairs_generated]
end
