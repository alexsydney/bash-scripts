require 'yaml'
require 'net/http'
require File.join(File.dirname(__FILE__), 'lib/threadpool.rb')
require File.join(File.dirname(__FILE__), 'lib/string_ext.rb')

PROGRESS_FILE        = 'log/external_images.progress'
LOG_FILE             = 'log/external_images.yaml'
ERROR_FILE           = 'log/external_images.error.yaml'
TEXT_MATCH_TOLERANCE = 0.333
BASE_DIR             = '/Users/tyler/article_test/articles'
CHUNK_SIZE           = 6

def main
  directories = Dir[File.join(BASE_DIR, '*')]
  @pool       = Threadpool.new(PROGRESS_FILE, directories, LOG_FILE, ERROR_FILE)

  @pool.run do |dir|
    article = get_yaml File.join(dir, 'new_article.yaml')
    result  = {}
    if article.has_key? "img_src"
      external_refs = article["img_src"].select{|url|
        uri = URI.parse(url)
        uri.absolute? ? uri.host != "www.ucsf.edu" : false
      }
      unless external_refs.empty?
        result = {
          "page" => article["url"],
          "refs" => external_refs
        }
      end
    end
    result
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

def get_yaml(file)
  YAML::load_file(File.open(file))
end

main