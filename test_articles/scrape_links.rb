require 'rubygems'
require 'scrapi'
require 'yaml'
require 'net/http'
require File.join(File.dirname(__FILE__), 'lib/threadpool.rb')
require File.join(File.dirname(__FILE__), 'lib/string_ext.rb')

WWW           = 'www.ucsf.edu'
BASE_DIR      = '/Users/tyler/article_test/articles'
ROOT_SEARCH   = 'http://www.ucsf.edu/challenge'
def main
  @pages_to_go = [ROOT_SEARCH]
  @pages_done = []
  @images = []

  while page = @pages_to_go.shift
    next if @pages_done.include? page
    scrape_article page
    @pages_done << page
  end
  
  File.open('pages.txt', 'w') {|file| file.write @pages_done.flatten.uniq.join("\n")}
  File.open('images.txt', 'w') {|file| file.write @images.flatten.uniq.join("\n")}
end

def all_work
  @pages_to_go + @pages_done
end

def write_yaml(file, obj)
  File.open(file, 'w'){|f| f.write obj.to_yaml}
end

def is_in_root(uri)
  uri.to_s.index(ROOT_SEARCH)
end

def scrape_article(uri)
  page_scraper = Scraper.define do
    array :hrefs
    array :img_src
    process "img", :img_src => "@src"
    process "a", :hrefs => "@href"
    result :img_src, :hrefs
  end
  puts "Scraping #{uri}"
  data = page_scraper.scrape(URI.parse(uri.to_s))
  @pages_to_go += filter_urls(data["hrefs"]).reject{|t| all_work.include? t.to_s}
  @images += data["img_src"].map(&:strip)
end

def filter_urls(urlz)
  urlz.map(&:strip).map{ |href| 
    href.gsub! /\/ucsf.edu/, '/www.ucsf.edu'
    if href.match(/^\//)
      "http://www.ucsf.edu#{href}"
    else
      href
    end
  }.reject{|href|
    href.match /\.[\w]{3,4}$/
  }.select{|href|
     begin
       URI.parse(href)
     rescue Exception => e
       false
     end
  }.select{|uri|
    is_in_root(uri)  
  }
end

#   The main entry point of the program.
main
