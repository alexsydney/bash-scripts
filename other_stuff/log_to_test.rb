site='http://qa.pa.ucsf.edu'

lines = File.open('/Users/tyler/test/log', 'r').readlines.map(&:strip)
urls = []
for line in lines
  match = line.match(/"GET (\/\S*)/)
  unless match && match[1]
    puts line
    next
  end
  urls << match[1]
end

File.open('/Users/tyler/article_test/pylot_1.26/urls', 'w'){|file|
    file.write %{<?xml version="1.0"?>
<testcases>
}
    for url in urls.uniq.sort
      file.write "<case><url>#{site}#{url.gsub('&', '&amp;')}</url></case>\n" unless url.match(/.\w{2,3}$/)
    end  
    file.write %{</testcases>
    }
}
