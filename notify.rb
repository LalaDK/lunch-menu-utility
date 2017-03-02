#!/usr/bin/ruby

# Cronjob
#30 11 * * 1,2,3,4,5 menu

require 'json'
require 'date'
require_relative "notify-osd-ruby.rb"
weekday = Date.today.strftime("%u") # mandag er 1

if ARGV.length > 0
  if ARGV[0] == "edit"
    system("gnome-open #{Dir.pwd}/menu.json")
    exit
  else
    days = {"mandag" => 1, "tirsdag" => 2, "onsdag" => 3, "torsdag" => 4, "fredag" => 5}
    result = days[ARGV[0]]
    if !result.nil?
      weekday = result.to_s
    end
  end
end

def post_notification menu
  notification = Notification.new
  notification.title = "Frokostmenu"
  notification.body = menu.join("\n\n")
  notification.urgency = "critical"
  notification.expire_time = 30 * 1000
  notification.post
end

def get_menu
  file_name = 'menu.json'
  raise StandardError, "Kan ikke finde menu.json" if !File.exists?("#{File.dirname(__FILE__)}/#{file_name}")
  file = File.read("#{File.dirname(__FILE__)}/#{file_name}")
  return JSON.parse(file)
end

menu = get_menu
todays_menu = menu[weekday]

if todays_menu.nil? || todays_menu.empty?
  puts "Kunne ikke finde en menu."
else
  post_notification todays_menu
  puts "\e[1mFrokostmenu\e[0m"
  puts todays_menu.join("\n")
end
