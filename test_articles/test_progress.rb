require 'thread'
YAML_START = "--- \n"
class TestProgress
  def initialize(progress_file, contents, log_file, error_file)
    @log_file      = log_file
    @error_file    = error_file
    @quit          = false
    @work_lock     = Mutex.new
    @print_lock    = Mutex.new
    @error_lock    = Mutex.new
    @progress_file = progress_file
    @progress      = File.exist?(progress_file) ? File.open(progress_file, 'r').read.strip.to_i : 0
    @work          = contents[@progress..contents.size-1]

    puts "Starting at number #{@progress}"
    
    File.open(log_file, 'w')   {|file| file.write YAML_START}
    File.open(error_file, 'w') {|file| file.write YAML_START}
  end
  
  def quit
    @work_lock.synchronize {
      @quit = true
    }
  end
  
  def done
    @work_lock.synchronize {
      @work.size == 0
    }
  end
  
  def get_work
    @work_lock.synchronize {
      p "#{@work.size} jobs left."
      @work.shift unless @quit
    }
  end
  
  def error(obj)
    @error_lock.synchronize {
      File.open(@error_file, 'a'){|file| file.write [obj].to_yaml.gsub(YAML_START, "")}
    }
  end
  
  def complete(obj)
    @work_lock.synchronize {
      File.open(@log_file, 'a'){|file| file.write [obj].to_yaml.gsub(YAML_START, "")} unless obj.nil?
      @progress += 1
      File.open(@progress_file, 'w'){|file| file.write @progress}
    }
  end
  
  def errormsg(message, url=nil, other=nil)
    @print_lock.synchronize {
      puts message
      puts "  #{other}" if other
      puts "  URL: #{url.to_s}" if url
      info = {"message" => message}
      info["url"] = url if url
      info["other"]   = other if other
      self.error info
    }
  end

end

class String
  def normalize
    HTMLEntities::Decoder.new('expanded').decode(self).gsub(/[^a-zA-Z\s]/,'').gsub(/\s+/, ' ').strip
  end
end
