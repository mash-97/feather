require 'yaml'

USERS_FOLDER = File.join(File.dirname(File.absolute_path(__FILE__)), 'users')

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
        YAML.dump({ratings: 0.0, wins: 0, total_matches: 0, matches: []}, f)
      end
    end
    return userpath
  end

  def self.loadUserData(username)
    userpath = User.ensureUserFile(username)
    data = {}
    File.open(userpath, 'r') do |f|
      data = YAML.load(f)
    end
    return data
  end

  def self.saveUserData(username, data)
    if data.class != Hash then
      raise Exception("#{data} not a Hash!")
    end
    userpath = User.ensureUserFile(username)
    File.open(userpath, )