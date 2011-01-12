require 'net/http'


class RedirectChecker  
  def initialize(error_file='redirect_errors.log')
    self.urls          = {}
    self.dest_host     = dest_host
    self.error_file    = error_file
    self.max_redirects = 10
    initialize_log_file()
  end

  def add_redirect(old_url, new_url)
    old_uri                      = URI.parse(old_url.to_s)
    new_uri                      = URI.parse(new_url.to_s)
    src_host                     = old_uri.host
    self.urls[src_host]          = {} unless self.urls.has_key?(src_host)
    self.urls[src_host][old_uri] = new_uri
  end
  
  def run
    urls.each do |host, uris|
      uris.each do |old_uri, new_uri|
        begin
          response, dest_uri = follow_redirects_on head_request(old_uri), old_uri
          unless new_uri.to_s == dest_uri.to_s
            error "Redirect mismatch:\n\t" +
                    "Source: #{old_uri.to_s}\n\t" +
                    "Expect: #{new_uri.to_s}\n\t" +
                    "Actual: #{dest_uri.to_s}"
          end
          if response.code.match(/^20./)
            p "200 #{dest_uri.to_s}"
          else
            error "HTTP Error: #{response.code}" +
              "\n\tSource: #{old_uri.to_s}"
          end
        rescue Exception => e
          error("Exception checking #{old_uri}: #{e.message}\n#{e.backtrace}")
        end
      end
    end
  end
  
  attr_accessor :urls, :dest_host, :error_file, :max_redirects
  
  private
    def error(msg)
      p msg
      File.open(error_file, 'a'){|f| f.write(msg+"\n")}
    end

    def initialize_log_file()
      File.open(error_file, 'w') {|file| file.write('')}
    end
    
    def follow_redirects_on(response, uri)
      redirects_so_far=0
      while response.code.match(/^30./) and redirects_so_far < self.max_redirects
        host = uri.host
        uri = URI.parse response.header["location"]
        unless uri.absolute?
          uri = URI.parse(File.join('http://', host, response.header["location"]))
        end
        response = head_request(uri)
        redirects_so_far += 1
      end
      error "Max redirects encountered on #{uri.to_s}" if redirects_so_far >= self.max_redirects
      [response, uri]
    end
    
    def head_request(uri)
      Net::HTTP.start(uri.host, 80){|h| h.head(uri.request_uri)}
    end
end
