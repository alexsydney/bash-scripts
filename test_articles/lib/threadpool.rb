require 'thread'
require 'yaml'

class Threadpool
  YAML_START = "--- \n"
  def initialize(progress_file, work, log_file, error_file, threads=10)
    @thread_count  = threads
    @log_fname     = log_file
    @err_fname     = error_file
    @quit          = false
    @work_lock     = Mutex.new
    @print_lock    = Mutex.new
    @error_lock    = Mutex.new
    @progress_file = progress_file
    @progress      = File.exist?(progress_file) ? File.open(progress_file, 'r').read.strip.to_i : 0
    @work          = work[@progress..work.size-1]
    raise "wtf" if @work.nil?

  end
  
  def run(&block)
    puts "Starting at number #{@progress}"
    initialize_logs
    
    @threads = []
    (1..@thread_count).each do |i|
      t = Thread.new { 
        thread_method i do |val| 
          block.call(val)
        end
      }
      @threads << t  
    end
  end
  
  def quit
    @quit = true
    @threads.each do |thread|
      thread.join
    end
    close_logs
  end
  
  def done
    @work.empty? or @quit
  end

  def log_error(message, other={})
    @print_lock.synchronize {
      puts message
      puts "  #{other.inspect}" if other
    }
    error({"message" => message}.merge(other))
  end
  
  private
    #  The actual workhorse.
    def thread_method(i, &block)
      my_num = i
      p "Thread #{i} starting up."
      while work = get_work and !done
        begin
          complete block.call(work)
        rescue Interrupt => int
          quit
        rescue Exception => e
          log_error "Thread #{i} caught an exception.", :work=>work, :exception=>e.message, :backtrace=>e.backtrace
        end
      end
      p "Thread #{i} all done."
    end

    def get_work
      @work_lock.synchronize {
        p "#{@work.size} jobs left."
        @work.shift unless @quit
      }
    end
    
    def initialize_logs
      new_logs    = !File.exist?(@progress_file)
      mode_str    = new_logs ? 'w' : 'a'
      @log_file   = File.open(@log_fname, mode_str)
      @error_file = File.open(@err_fname, mode_str)
      if new_logs
        @log_file.write YAML_START
        @error_file.write YAML_START
      end
    end
    
    def close_logs
      @log_file.close
      @error_file.close
    end
  
    def complete(obj)
      @work_lock.synchronize {
        @progress += 1
        @log_file.write [obj].to_yaml.gsub(YAML_START, "") unless obj.empty?
        File.open(@progress_file, 'w'){|file| file.write @progress}
      }
    end
    
    def error(obj, info={})
      @error_lock.synchronize {
        @error_file.write [obj].to_yaml.gsub(YAML_START, "")
      }
    end
end

