class Boolean < Object
end

class TrueClass
  define_method "&&" do |other|
    self && other
  end

  define_method "||" do |other|
    self || other
  end

  define_method "!" do
    false
  end

  def is_a? klass
    return true if klass == Boolean
    super
  end
end

class FalseClass
  define_method "&&" do |other|
    self && other
  end

  define_method "||" do |other|
    self || other
  end

  define_method "!" do
    true
  end

  def is_a? klass
    return true if klass == Boolean
    super
  end
end
