require 'rubygems'
require 'scrapi'
require 'yaml'
require 'net/http'
require '/Users/tyler/scripts/test_articles/test_progress.rb'
require 'htmlentities'
require 'thread'

PROGRESS_FILE = '~article_test.progress'
LOG_FILE      = '~article_test.log.yaml'
ERROR_FILE    = '~article_test.error.yaml'
RETRY_TIMES   = 30
WWW           = 'webprod.pa.ucsf.edu'
COMMUNITY     = 'test.community.ucsf.edu'
TODAY         = 'test.today.ucsf.edu'
NEWS          = 'test.news.ucsf.edu'
THREAD_COUNT  = 15

MONTHS_EXPR   = /(january|february|march|april|may|june|july|august|september|october|november|december)/i

@threads      = []
@ee_lock      = Mutex.new
@prod_lock    = Mutex.new

def main_method
  work_list = YAML::load_file( File.open('urls.yaml') )
  @progress     = TestProgress.new(PROGRESS_FILE, work_list, LOG_FILE, ERROR_FILE)
  
  begin
    (1..THREAD_COUNT).each {|i|
      t = Thread.new { thread_method(i) }
      @threads << t  
    }
    until @progress.done
      sleep 1
    end
  rescue Interrupt => e
    @progress.quit
  end

  @threads.each do |thread|
    thread.join
  end
end

def thread_method(i)
  sleep 1
  while next_article = @progress.get_work
    begin
      process_article next_article[:old]
    rescue Interrupt => it  
      @progress.quit
    end
  end
  p "Thread #{i} all done."
end

def process_article(old_url)
  old_uri = URI.parse(old_url.to_s)
  new_uri = get_redirect_url(old_uri)
  val = nil
  if new_uri
    old_article = scrape_article(old_uri)
    new_article = scrape_article(new_uri)
    val = {
      "old" => article_to_hash(old_article, old_uri),
      "new" => article_to_hash(new_article, new_uri)
    }
  end
  @progress.complete(val)
end

def article_to_hash(article, url)
  if article
    val = {  #  :title, :paragraphs, :img_src, :hrefs, :links, :flash
      "url"        => url.to_s,
      "title"      => article.title,
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

def scrape_article(uri)
  article = nil
  i=0

  while article.nil? && i<RETRY_TIMES
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
        @ee_lock.synchronize {
          article = science_cafe.scrape(uri)
          sleep(1)
        }
      elsif uri.host == WWW
        # puts "www: #{uri}"
        @prod_lock.synchronize {
          article = redesign.scrape(uri)
          sleep(1)
        }
      else
        # puts "legacy: #{uri}"
        @ee_lock.synchronize {
          article = legacy.scrape(uri)
          sleep(1)
        }
      end
    rescue Exception => e
      errormsg "Error getting article!", uri.to_s, e.inspect
    end
    unless article
      i += 1
      puts "Nil(#{i}): #{uri}"
      sleep 10
    end
  end
  puts "Finally!!!" if article && i > 0
  errormsg( "Nil article found.", uri.to_s) unless article

  return article
end

def get_redirect_url(old_url)
    response = nil
    src_host = case old_url.host
    when "www.ucsf.edu"
      WWW
    when "community.ucsf.edu"
      COMMUNITY
    when "today.ucsf.edu"
      TODAY
    when "news.ucsf.edu"
      NEWS
    end
    
    Net::HTTP.start(src_host, 80) {|http|
      response = http.head(old_url.path)
    }

    case response.code
    when "200"
      new_path = old_url.path
    when "301"
      new_path = URI.parse(response.header["location"]).path
    when "302"
      new_path = URI.parse(response.header["location"]).path
    else
       errormsg "#{src_host} gave HTTP #{response.code} for #{old_url.path}, expected 200 or 301.", old_url
       new_path = nil
    end
    new_url = URI.parse("http://#{WWW}#{new_path}") unless new_path.nil?
    new_url
end

def errormsg(message, url=nil, other=nil)
  @progress.errormsg message, url, other
end

main_method