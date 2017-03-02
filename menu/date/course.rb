class Course
  attr_accessor :text

  def initialize(text)
    self.text = text
  end

  def as_hash
    {
      :text => self.text
    }
  end

end