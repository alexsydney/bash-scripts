module TablePrint
  def columns
    @columns ||= Array.new(column_count, 80)
  end
  def column_width(i, w)
    columns[i] = w
  end
  
  attr_accessor :column_count
  
  def lines
    @lines ||= Array.new(size, "")
  end
  
  def to_rows
    columns.each_with_index do |colwidth, colnum|
      newwidth = colwidth
      each do |row|
        curr_data = (row[colnum] || "").strip
        if curr_data.size < colwidth && curr_data.size > newwidth
          newwidth = curr_data.size
        end
      end
      colwidth = newwidth if newwidth < colwidth
      
      each_with_index do |row, row_num|
        current_data = (row[colnum] || "").strip
        next unless current_data.size > 0
        # Print to the correct line the string found plus the appropriate number of spaces.
        #  Determine the width of this column is based on longest item in this column
        if current_data[0] == '#'
          lines[row_num] += current_data
          next
        end

        current_width = [colwidth, current_data.size].greatest
        current_data += " " * (current_width - current_data.size + 1)
        lines[row_num] += current_data
      end
    end
    lines
  end
end


class Array
  def greatest
    grt = first
    each do |a|
      next unless a
      grt = a if a > grt
    end
    grt
  end
  def least
    grt = first
    each do |a|
      next unless a
      grt = a if a < grt
    end
    grt
  end
end

