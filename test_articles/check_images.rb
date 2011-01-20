require 'yaml'
require 'net/http'
require File.join(File.dirname(__FILE__), 'lib/threadpool.rb')
require File.join(File.dirname(__FILE__), 'lib/string_ext.rb')

PROGRESS_FILE        = 'log/final_images.progress'
LOG_FILE             = 'log/final_images.yaml'
ERROR_FILE           = 'log/final_images.error.yaml'

def main
  work = get_lines('log/all_images.txt~')
  work = get_yaml('log/final_images.yaml')
  p work
  raise "nothing do do!" if work.empty?
  @pool       = Threadpool.new(PROGRESS_FILE, work, LOG_FILE, ERROR_FILE)

  @pool.run do |yaml|
    if yaml.has_key? :work
      url = yaml[:work]
      response = follow_redirects_on URI.parse(url)
      unless response.code.match /^20[0-9]/
        @pool.log_error url, :code=>response.code
      end
      {
        "url" => url,
        "code"=> response.code
      }  
    end
  end #  End of thread work.
  until @pool.done do
    begin
      sleep 1
    rescue Interrupt => e
      @pool.quit
    end
  end
  @pool.quit
end
MAX_REDIRECTS=10

def follow_redirects_on(uri)
  response = head_request(uri)
  redirects_so_far=0
  while response.code.match(/^30./) and redirects_so_far < MAX_REDIRECTS
    host = uri.host
    uri = URI.parse response.header["location"]
    unless uri.absolute?
      uri = URI.parse(File.join('http://', host, response.header["location"]))
    end
    response = head_request(uri)
    redirects_so_far += 1
  end
  if redirects_so_far >= MAX_REDIRECTS
    @pool.log_error("Max redirects encountered", "url" => uri.to_s) 
  end
  response
end

def head_request(uri)
  Net::HTTP.start(uri.host, 80){|h| h.head(uri.request_uri)}
end


def get_yaml(file)
  YAML::load_file(File.open(file))
end


def get_lines(*file)
  File.open(File.join(file)).readlines.map(&:strip).reject{|t| t.empty?}
end


main