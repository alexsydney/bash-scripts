require 'htmlentities'

class String
  def normalize
    HTMLEntities::Decoder.new('expanded').decode(self).gsub(/[^a-zA-Z\s]/,'').gsub(/\s+/, ' ').strip
  end
  def decode_html
    HTMLEntities::Decoder.new('expanded').decode(self)
  end
end

class NilClass
  def normalize
    nil
  end
  def empty?
    true
  end
end
