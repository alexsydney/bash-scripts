require 'yaml'
require File.join(File.dirname(__FILE__), 'lib/threadpool.rb')
require File.join(File.dirname(__FILE__), 'lib/string_ext.rb')

PROGRESS_FILE        = 'log/article_comparison.progress'
LOG_FILE             = 'log/article_comparison.log.yaml'
ERROR_FILE           = 'log/article_comparison.error.yaml'
TEXT_MATCH_TOLERANCE = 0.333
BASE_DIR             = '/Users/tyler/article_test/articles'
CHUNK_SIZE           = 6

def main
  directories = Dir[File.join(BASE_DIR, '*')]
  @pool       = Threadpool.new(PROGRESS_FILE, directories, LOG_FILE, ERROR_FILE)

  @pool.run do |dir|
    old_article = get_yaml File.join(dir, 'old_article.yaml')
    new_article = get_yaml File.join(dir, 'new_article.yaml')
    error = nil
    result = {"old_url" => old_article["url"], "new_url" => new_article["url"]}

    old_article["title"] = old_article["title"].normalize
    new_article["title"] = new_article["title"].normalize

    unless old_article["title"] == new_article["title"]
      result["title_mismatch"] = {"old" => old_article["title"], "new" => new_article["title"]}
      error = "Title Mismatch"
    end
    
    [new_article["paragraphs"], old_article["paragraphs"]].each do |p|
      p.map!(&:normalize)
      p.reject!{|t| t.size < 200 or t.include?("CDATA") or t.include?("javascript")}
    end
    
    old_words      = old_article["paragraphs"].join(" ").split(" ")
    new_text       = new_article["paragraphs"].join(" ")
    chunk_count    = (old_words.size / CHUNK_SIZE)
    chunks         = []
    missing_chunks = []

    (0..chunk_count).each do |i|
      chunks << old_words[i*CHUNK_SIZE..(i+1)*CHUNK_SIZE].join(" ")
    end
    
    chunks.each do |chunk|
      missing_chunks << chunk unless new_text.include?(chunk)
    end
    
    unless missing_chunks.empty?
      portion_not_found = (missing_chunks.size.to_f / chunks.size.to_f)
      if portion_not_found > TEXT_MATCH_TOLERANCE
        error = "#{error}#{error ? ', ' : ''}Missing Text"
      end
      if missing_chunks.size > 10
        result["missing_text"] = "Pretty much everything!!!"
      else
        result["missing_text"] = missing_chunks
      end
    end
    
    if old_article["title"] == "Page Not Found"
      error = nil# "Legacy Page Not Found"
      result = {"not_found" => true,  "old_url" => old_article["url"], "new_url" => new_article["url"]}
    end
    
    if error
      @pool.log_error error, result
      result["result"] = error
    else
      result["result"] = "Success"
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