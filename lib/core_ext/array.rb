class Array
  def validate! against
    items_and_their_valid_type = self.zip against
    items_and_their_valid_type.each do |(item, valid_type)|
      next unless valid_type.is_a? Class
      unless item.is_a? valid_type
        raise Scratch::InvalidType.new valid_type, item.class
      end
    end
  end
end
