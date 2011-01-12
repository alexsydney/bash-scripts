require 'yaml'

PROGRESS_FILE = 'check_article_data.rb.progress'
LOG_FILE = 'check_article_data.log.yaml'
ARTICLE_DATA = 'article_data.yaml'

@progress = File.exist?(PROGRESS_FILE) ? File.open(PROGRESS_FILE, 'r').read.strip.to_i : 0
puts "Starting at article #{@progress}"
unless File.exist?(LOG_FILE)
  File.open(LOG_FILE, 'w'){|file| file.write "---\n"}
end

def log(obj)
  File.open(LOG_FILE, 'a'){|file| file.write obj.to_yaml.gsub("---\n", "")}
  @progress += 1
  File.open(PROGRESS_FILE, 'w'){|file| file.write @progress}
end

# 1. Report on all urls pointing outside of ucsf.edu, with the article that it shows up in.
# 2. Check all hrefs and img src tags with a HEAD tag, and report on any 40x errors.
# 3. Match old title versus new title.
# 4. Match all paragraphs in the articles.

articles = YAML::load( File.open( ARTICLE_DATA ) )

articles[progress..articles.size-1].each do |article|
  text_errors = []
  external_links = []
  href_errors = {}
  img_src_errors = {}
  text_errors << "Title mismatch" unless article[:old].title == article[:new].title
  article[:old]["paragraphs"].each do |paragraph|
    text_errors << "Missing paragraph: \"#{paragraph[0..60]}...\"" unless article[:new]["paragraphs"].include? paragraph
  end
  if article[:new].has_key? "hrefs"
    responses = []
    
  end
  
end