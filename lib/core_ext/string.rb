class String
  def is_whitespace?
    return self == '' ||
      self == " "  ||
      self == "\t" ||
      self == "\r" || 
      self == "\n" ||
      self == "\v"
  end

  def blank?
    self == ''
  end

  def is_numeric?
    self =~ /\A\d+\Z/
  end
end
