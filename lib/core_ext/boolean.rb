class TrueClass
  define_method :"&&" do |other|
    self && other
  end

  define_method :"||" do |other|
    self || other
  end
end

class FalseClass
  define_method :"&&" do |other|
    self && other
  end

  define_method :"||" do |other|
    self || other
  end
end
