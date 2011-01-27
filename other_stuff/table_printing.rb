require '/Users/tyler/scripts/other_stuff/table_print.rb'

@rewrite_rule = /(RewriteRule)\s*(\S*)\s*(\S*)\s*(\S*)\s*/

def main
  cool = read_file('/Users/tyler/scripts/web_root/etc/httpd/conf/local/rewrite_rules.www.ucsf.edu.static.conf')
  cool.extend TablePrint
  cool.column_count = 4
  cool.column_width 0, 10
  cool.column_width 1, 50
  cool.column_width 2, 50
  puts cool.to_rows
end


def read_file(f)
  rows = []
  File.open(f, 'r') do |file|
    lines = file.readlines.map(&:strip)
    for line in lines
      if line.empty?
        rows << []
        next
      end
      code, comment = line.split('#', 2)
      comment = "#" + comment if comment
      if comment && code.strip.size == 0 
        rows << [comment]
      else
      
        groups = code.match @rewrite_rule
        unless groups
          rows << [line]
        else
          groups = groups.to_a
          groups.shift
          rows << groups
        end
      end
    end
  end
  rows
end

main