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
end
