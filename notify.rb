#!/usr/bin/ruby

# Cronjob
#30 11 * * 1,2,3,4,5 menu

require 'json'
require 'date'
require_relative "notify-osd-ruby.rb"
require_relative 'db.rb'
require_relative 'menu.rb'
require_relative 'menu/menu_date.rb'
require_relative 'menu/date/course.rb'
require "google/cloud/vision"
weekday = Date.today.strftime("%u") # mandag er 1


def post_notification menu
  notification = Notification.new
  notification.title = "Frokostmenu"
  notification.body = menu.courses_for_date.map(&:text).join("\n\n")
  notification.urgency = "critical"
  notification.expire_time = 30 * 1000
  notification.post
end

def create_menu
  work_days = ["Mandag", "Tirsdag", "Onsdag", "Torsdag", "Fredag"]
  vision = Google::Cloud::Vision.new project: "804699923425"
  menu_image = vision.image "img/menu.jpg"
  anno = vision.annotate menu_image, text: true
  menu = Menu.new
  current_day = ""
  menu_json = {}
  anno.text.to_s.split("\n").each do |line|
    if line.match /Menu uge/
      menu.week = line.split(" ")[2] || Date.today.cweek
    elsif work_days.include?(line)
      current_day = line
    elsif current_day != "" && line != "Sodexo"
      menu_json[current_day] ||= []
      menu_json[current_day] << line.strip.gsub("o ", "")
    end
  end

  dates = menu_json.keys.map do |date|
    courses = menu_json[date].map do |c_sentence|
      Course.new(c_sentence)
    end
    date = MenuDate.new(date, courses)
  end
  menu.dates = dates
  menu.save
end


db = Db.new
menu = Menu.by_week(Date.today.cweek, db)
if menu.nil?
  create_menu
else
  post_notification menu
end