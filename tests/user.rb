require 'yaml'

USERS_FOLDER = File.join(File.dirname(File.absolute_path(__FILE__)), 'users')
DATA_INIT = {ratings: {}, matches: [], rated: {}, password: ''}

class User
  def self.ensureUsersFolder()
    if File.exists?(USERS_FOLDER) then
      if not File.directory?(USERS_FOLDER) then
        raise Exception("#{USERS_FOLDER} not a directory!")
      end
    else
      Dir.mkdir(USERS_FOLDER)
    end
  end

  def self.ensureUserFile(username)
    User.ensureUsersFolder()
    userpath = File.join(USERS_FOLDER, username)
    if File.exists?(userpath) then
      if not File.file?(userpath) then
        raise Exception("#{userpath} not a file!")
      end
    else
      File.open(userpath, 'w') do |f|
        YAML.dump(DATA_INIT, f)
      end
    end
    return userpath
  end

  def self.loadUserData(username)
    userpath = User.ensureUserFile(username)
    data = DATA_INIT
    File.open(userpath, 'r') do |f|
      data = YAML.load(f)
    end
    if data.class != Hash then
      User.saveUserData(username, DATA_INIT)
      return DATA_INIT
    end
    return data
  end

  def self.saveUserData(username, data)
    if data.class != Hash then
      raise Exception("#{data} not a Hash!")
    end
    userpath = User.ensureUserFile(username)
    File.open(userpath, 'w') do |f|
      YAML.dump(data, f)
    end
  end

  def self.addMatch(username, match_obj)
    userpath = User.ensureUserFile(username)
    data = User.loadUserData(username)
    data[:matches] << match_obj
    User.saveUserData(username, data)

    return data
  end

  def self.rateUser(to_username, from_username, rate)
    User.ensureUserFile(to_username)
    User.ensureUserFile(from_username)

    # process to user
    to_data = User.loadUserData(to_username)
    to_data[:ratings][:from_username] = rate
    User.saveUserData(to_username, to_data)

    # process from user
    from_data = User.loadUserData(from_username)
    from_data[:rated][:to_username] = rate
    User.saveUserData(from_username, from_data)

    return rate
  end

  def self.exists?(username)
    User.ensureUsersFolder()
    userpath = File.join(USERS_FOLDER, username)

    if File.exists?(userpath) and File.file?(userpath) then
      return User.ensureUserFile(username)
    end
    
    return nil
  end

  def self.authorize(username, password)
    if not User.exists(username) then
      raise Exception("#{username} doesn't exist!")
    end

    user_data = User.loadUserData(username)
    if(user_data[:password] != password) then
      return nil
    end

    return User.new(username)
  end

  def self.signup(username, password)
    if User.exists(username) then
      raise Exception("#{username} already exists!")
    end

    userpath = User.ensureUserFile(username)
    data = User.loadUserData(username)
    data[:password] = password.strip()
    User.saveUserData(username, data)
    return User.new(username)
  end


  attr_accessor :username, :data
  def initialize(username)
    @username = username
    @data = User.loadUserData(username)
  end

  def total_matches()
    return @data[:matches].length
  end

  def total_wins()
    return @data[:matches].filter{|m| (m[:apair][@username] and m[:winner]==m[:apair]) or (m[:bpair][@username] and m[:winner]==m[:bpair])}.length
  end

  def total_loss()
    return @data[:matches].filter{|m| (m[:apair][@username] and m[:winner]!=m[:apair]) or (m[:bpair][@username] and m[:winner]!=m[:bpair])}.length
  end

  def ratings()
    return (@data[:ratings].values.sum.to_f / @data[:ratings].length).round(2)
  end

  def matches_with(partner_username)
    return @data[:matches].filter{ |m| 
      (m[:apair].include?(partner_username) and m[:apair].include?(@username)) or (m[:bpair].include?(partner_username) and m[:bpair].include?(@username))
    }
  end

  def matches_against(au, bu)
    return @data[:matches].filter{ |m| 
      (m[:apair].include?(au) and m[:apair].include?(bu)) or (m[:bpair].include?(au) and m[:bpair].include?(bu))
    }
  end
end


