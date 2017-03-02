class Db
  attr_accessor :file_path, :data
  def initialize
    self.file_path = "#{File.dirname(__FILE__)}/menu.json"
    set_data
  end

  def db_content
    File.read(self.file_path)
  end

  def open_db_file
    File.open(self.file_path, 'w') do |f|
      yield(f)
    end
  end

  def override_with_current_state
    open_db_file do |f|
      f.write(JSON.pretty_generate(self.data))
    end
    set_data
  end

  def set_data
    self.data = JSON.parse(db_content || "{}")
  end
end