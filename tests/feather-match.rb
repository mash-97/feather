require 'yaml'

MATCHES_FOLDER = File.join(File.dirname(File.absolute_path(__FILE__)), 'matches')

class FeatherMatch
  def self.ensureMatchFolder()
    if File.exists?(MATCHES_FOLDER) then
      if not File.directory?(MATCHES_FOLDER) then
        raise Exception("#{MATCHES_FOLDER} not a directory!")
      end
    else
      Dir.mkdir(MATCHES_FOLDER)
    end
  end

  def self.saveNewMatch(apair, bpair, winner)
    time = Time.now.strftime("%d-%m-%Y-%H-%M-%S")
    file_path = File.join(MATCHES_FOLDER, time)

    data = {
      time: time,
      apair: apair,
      bpair: bpair,
      winner: winner 
    }

    File.open(file_path, 'w') {|f|
      YAML.dump(data, f)
    }

    return data
  end

end
