class MenuDate
  attr_accessor :date, :courses
  def initialize(date, courses)
    self.date = date
    self.courses = courses
  end

  def as_hash
    {
      :date => self.date,
      :courses => self.courses.map{|course| course.as_hash }
    }
  end
end