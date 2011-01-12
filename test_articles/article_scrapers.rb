

# 
# 
# science_cafe:
#   old: "div#main_contents"
#     Title: "h1"
#     Text of each <p>
#   new: "div#content"
#     Title: "h1"
#     Text of each <p>
# 
# news.ucsf.edu/media-coverage, /news-briefs, /releases, today.ucsf.edu/stories/ucsf-blogs
#   old: "#contents"
#     Title: "h1"
#     Text of each <p>
#     p > a text
#   
#   new: "#content"
#     Title: "h1"
#     Text of each <p>
#     p > a text
# 
# 
# 
# 
# scaper = Scraper.define do
#   process "my > css selector", :article_body => :inner_html
# end