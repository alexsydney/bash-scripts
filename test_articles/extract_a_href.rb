require 'yaml'
require 'net/http'
require File.join(File.dirname(__FILE__), 'lib/string_ext.rb')

BASE_DIR             = '/Users/tyler/article_test/articles'

#  /Users/tyler/article_test/articles/19563/new_article.yaml

@all_hrefs = []
@log_file_path = 'log/all_hrefs.txt'

def main
  directories = Dir[File.join(BASE_DIR, '*')]
  errors = []

  directories.each do |dir|
    article_path=File.join(dir, 'new_article.yaml')
    begin
      article = get_yaml article_path
      next if article.nil?
      print "."
      STDOUT.flush
      if article.has_key? "hrefs"
        hrefs = article["hrefs"].map{|href|
          begin
            href = href.decode_html
            uri = URI.parse(href)
            unless uri.absolute?
              host = URI.parse(get_file dir, 'old_path').host
              href = File.join "http://", host, href
            end
            href
          rescue Exception => e
            errors << "href: #{href}\nin article: #{article["url"]}"
          end
        }

        @all_hrefs << hrefs
      end
    rescue Exception => e
      puts "Exception: #{e.message}\narticle: #{article_path}\n"
    end
    
  end 
  @all_hrefs = @all_hrefs.flatten.uniq.sort.map(&:strip)
  
  File.open(@log_file_path, "w") do |file|
    file.write @all_hrefs.join("\n") + "\n"
  end
  puts errors.join("\n")
  puts "\n\nWrote #{@all_hrefs.size} unique hrefs to #{@log_file_path}"
end

def get_yaml(file)
  YAML::load_file(File.open(file)) if File.exist? file
end

def get_file(*file)
  File.open(File.join(file)).read.strip
end

main
