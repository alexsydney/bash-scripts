require 'yaml'
require 'net/http'
require File.join(File.dirname(__FILE__), 'lib/threadpool.rb')
require File.join(File.dirname(__FILE__), 'lib/string_ext.rb')

PROGRESS_FILE        = 'log/all_images.progress'
LOG_FILE             = 'log/all_images.yaml'
ERROR_FILE           = 'log/all_images.error.yaml'
TEXT_MATCH_TOLERANCE = 0.333
BASE_DIR             = '/Users/tyler/article_test/articles'
CHUNK_SIZE           = 6

#  /Users/tyler/article_test/articles/19563/new_article.yaml

@all_images = []

def main
  directories = Dir[File.join(BASE_DIR, '*')]

  directories.each do |dir|
    article = get_yaml File.join(dir, 'new_article.yaml')
    next if article.nil?
    print "."
    STDOUT.flush
    if article.has_key? "img_src"
      relative_urls = article["img_src"].select{|url|
        !URI.parse(url).absolute?  
      }
      host = URI.parse(get_file dir, 'old_path').host
      @all_images << relative_urls.map{|u| File.join("http://#{host}", u)}
      #      @all_images << article["img_src"]
    end
  end #  End of thread work.
    
  File.open("log/all_images.txt", "w") do |file|
    @all_images.flatten.uniq.sort.each do |img|
      file.write img.strip + "\n"
    end
  end
  puts "\n\nWrote #{@all_images.size} image sources to log/all_images.txt"
end

def get_yaml(file)
  YAML::load_file(File.open(file)) if File.exist? file
end

def get_file(*file)
  File.open(File.join(file)).read.strip
end

main
