require "json"
require_relative "db"
require_relative "menu/menu_date.rb"
require_relative "menu/date/course.rb"
class Menu
  attr_accessor :week, :dates, :db
  def initialize(week = Date.today.cweek, dates = [], db = nil)
    self.dates = dates
    self.week = week
    self.db = db || Db.new
  end

  def save
    #Send or update menu to json file
    db.data[self.week] = as_hash
    db.override_with_current_state
    self
  end

  def as_hash
    {
      :week => self.week,
      :dates => self.dates.map{|date| date.as_hash }
    }
  end

  def self.by_week(week = Date.today.cweek, db = nil)
    #Find menu in json file for week
    db = db || Db.new
    h = db.data[week.to_s]
    dates = h["dates"].map do |d|
      courses = d["courses"].map{|c| Course.new(c["text"]) }
      date = MenuDate.new(d["date"], courses)
    end
    Menu.new(h["week"], dates)
  end

  def self.by_date(date = Date.today)
    #Find menus in json file by date
  end

  def courses_for_date(date = Date.today)
    datename = Menu.date_to_da_name(date)
    self.dates.detect{|d| d.date == datename }.courses
  end

  def self.date_to_da_name(date)
    date_convert = {1 => "Mandag", 2 => "Tirsdag", 3 => "Onsdag", 4 => "Torsdag", 5 => "Fredag"}
    date_convert[date.wday]
  end
end