require 'rubygems'
require 'scrapi'
require 'yaml'
require 'net/http'
require File.join(File.dirname(__FILE__), 'lib/threadpool.rb')
require File.join(File.dirname(__FILE__), 'lib/string_ext.rb')

PROGRESS_FILE = 'log/article_scrape.progress'
LOG_FILE      = 'log/article_scrape.log.yaml'
ERROR_FILE    = 'log/article_scrape.error.yaml'

WWW           = 'www.ucsf.edu'
BASE_DIR      = '/Users/tyler/article_test/articles'

def main
  directories = Dir[File.join(BASE_DIR, '*')]
  @pool       = Threadpool.new(PROGRESS_FILE, directories, LOG_FILE, ERROR_FILE)

  @pool.run do |dir|
    old_uri     = URI.parse(file_contents(dir, 'old_path'))
    new_uri     = URI.parse(File.join 'http://', WWW, file_contents(dir, 'new_path'))
    old_html = file_contents(dir, 'old_article.html')
    new_html = file_contents(dir, 'new_article.html')
    old_article = scrape_article(old_html, old_uri)
    new_article = scrape_article(new_html, new_uri)
    write_yaml File.join(dir, 'old_article.yaml'), old_article
    write_yaml File.join(dir, 'new_article.yaml'), new_article
    {
      "old" => old_uri.to_s,
      "new" => new_uri.to_s
    }
  end
  
  until @pool.done do
    begin
      sleep 1
    rescue Interrupt => e
      @pool.quit
    end
  end
  @pool.quit
end

def write_yaml(file, obj)
  File.open(file, 'w'){|f| f.write obj.to_yaml}
end

def scrape_article(html, uri)
  article = nil

  article_scraper = Scraper.define do
    array :paragraphs
    array :links
    array :hrefs
    array :img_src
    process "h1", :title => :text
    process "p", :paragraphs => :text
    process "img", :img_src => "@src"
    process "a", :hrefs => "@href"
    process "a", :links => :text
    process "object[type=application/x-shockwave-flash]", :flash => "@data"
    result :title, :paragraphs, :img_src, :hrefs, :links, :flash
  end

  science_cafe = Scraper.define do
    process "div#main_contents", :article => article_scraper
    result :article
  end

  legacy = Scraper.define do
    process "div#contents", :article => article_scraper
    result :article
  end

  redesign = Scraper.define do
    process "div#content", :article => article_scraper
    result :article
  end    
  
  begin
    if uri.path.index('science-cafe')
      # puts "Science cafe: #{uri}"
      article = science_cafe.scrape(html)
    elsif uri.host == WWW
      # puts "www: #{uri}"
      article = redesign.scrape(html)
    else
      # puts "legacy: #{uri}"
      article = legacy.scrape(html)
    end
  rescue Exception => e
    @pool.log_error "Error getting article!", :url=>uri.to_s, :message=>e.message, :backtrace=>e.backtrace
  end
  unless article
    @pool.log_error "Nil article found.", :url=>uri.to_s
  end
  return article_to_hash(article, uri)
end

MONTHS_EXPR   = /(january|february|march|april|may|june|july|august|september|october|november|december)/i
def article_to_hash(article, url)
  if article
    val = {  #  :title, :paragraphs, :img_src, :hrefs, :links, :flash
      "url"        => url.to_s,
      "title"      => article.title.normalize,
      "flash"      => article.flash,
    }

    val["paragraphs"] = article.paragraphs.map(&:normalize).reject{|t| t.empty? || ((t.length < 100) && 
      t.match(MONTHS_EXPR))} if article.paragraphs
    val["hrefs"]      = article.hrefs.map(&:to_s).reject{|t| t.empty? || (t.length < 6)} if article.hrefs
    val["img_src"]    = article.img_src.map(&:to_s).reject{|t| t.empty? || (t.length < 6)} if article.img_src
    val["links"]      = article.links.map(&:normalize).reject{|t| t.empty?} if article.links
    val
  else
    {"url" => url.to_s}      
  end
end

def file_contents(path, *extra)
  File.open(File.join(path, *extra), 'r'){|f| f.read.strip}
end

#   The main entry point of the program.
main
