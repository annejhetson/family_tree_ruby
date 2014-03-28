require 'bundler/setup'
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

def menu
  puts 'Welcome to the family tree!'
  puts 'What would you like to do?'
  choice = nil
    until choice == 'e'
    puts ''
    puts 'Press a to add a family member.'
    puts 'Press l to list out the family members.'
    puts 'Press m to add who someone is married to.'
    puts 'Press s to see who someone is married to.'
    puts 'Press p to add parents.'
    puts 'Press d to delete.'
    puts 'Press lp to list a persons parents'
    puts 'Press e to exit.'
    choice = gets.chomp

    case choice
    when 'a'
      add_person
    when 'l'
      list
    when 'm'
      add_marriage
    when 's'
      show_marriage
    when 'd'
      delete_person
    when 'lp'
      list_parent
    when 'error'
      5.times do
        error
        sleep(1)
      end
    when 'p'
      add_parents
    when 'e'
      exit
    end
  end
end

def add_person
  puts 'What is the name of the family member?'
  name = gets.chomp
  puts 'Enter 1 if you are male or 2 or female'
  gender = gets.chomp
  if gender == "1"
    gender = true
  elsif gender == "2"
    gender = false
  else
    clear
    error
    add_person
  end
  Person.create(:name => name, :sex_male => gender)
  puts name + " was added to the family tree.\n\n"
end

def add_marriage
  list
  puts 'What is the number of the first spouse?'
  spouse1 = Person.find(gets.chomp)
  puts 'What is the number of the second spouse?'
  spouse2 = Person.find(gets.chomp)
  spouse1.update(:spouse_id => spouse2.id)
  puts spouse1.name + " is now married to " + spouse2.name + "."
end

def list
  puts 'Here are all your relatives:'
  people = Person.order(:id)
  people.each do |person|
    puts person.id.to_s + " " + person.name
  end
  puts "\n"
end

def list_parent
  list
  puts "Please choose a person's id, to see their parents"
  person = Person.find(gets.chomp.to_i)

  if person.parent_1 == nil && person.parent_2 == nil
    puts "Please update parent information for #{person.name}."
  elsif person.parent_1 == 0 && person.parent_2 == 0
     puts "#{person.name} has no parents on record."
  elsif person.parent_1 > 0 && person.parent_2 == 0
    parent_1 = Person.find(person.parent_1.to_i)
    puts "#{person.name}'s parent is #{parent_1.name}."
  else
    parent_1 = Person.find(person.parent_1.to_i)
    parent_2 = Person.find(person.parent_2.to_i)
    puts "#{person.name} parents are #{parent_1.name} and #{parent_2.name}."

  end
end

def show_marriage
  list
  puts "Enter the number of the relative and I'll show you who they're married to."
  person = Person.find(gets.chomp)
  spouse = Person.find(person.spouse_id)
  puts person.name + " is married to " + spouse.name + "."
end

def delete_person
  list
  puts "Please enter the id for the person you would like to delete"
  delete = gets.chomp.to_i
  name = Person.find(delete).name
  Person.find(delete).destroy
  puts "#{name} has been kicked out of the family\n"

end

def add_parents
  puts "\n "
  list
  puts "\n Who would you like to add parent(s) to"
  person = Person.find(gets.chomp.to_i)
  puts "Please enter the id of parent 1 or np for no parent"
  parent_1 = gets.chomp.to_i
  if parent_1 == "np"
    parent_1 = 0
  end
  puts "Please enter the id of parent 2 or np for no parent"
  parent_2 = gets.chomp.to_i
  if parent_2 == "np"
    parent_2 = 0
  end
  person.update(parent_1: parent_1, parent_2: parent_2)
  if parent_1 == 0 && parent_2 == 0
    puts "#{person.name}'s parent status has been updated"
  elsif parent_2 == 0
  puts "#{person.name}'s parent, #{Person.find(parent_1).name} has been added as a single parent...depressing"
  elsif parent_2 > 0 && parent_1 > 0
  puts "#{person.name}'s parents, #{Person.find(parent_1).name} and #{Person.find(parent_2).name} are added"
  else
    error
  end

end

##---- OTHERS ---##
def error
  puts "\e[5;31m(ノಠ益ಠ)ノ彡 ERROR!!\e[0;0m"
end

def clear
  system "clear"
end

def exit
  clear
  puts "----- BYE BYE! -----"
  sleep(1)
  puts "I'm going dancing!!"
  sleep(1)
  clear
  puts "\e[5;33m┏(-_-)┛"
  sleep(1)
  clear
  puts "       ┗(-_-﻿ )┓"
  sleep(1)
  clear
  puts "               ┗(-_-)┛"
  sleep(1)
  clear
  puts "                      ┏(-_-)┓\e[0;0m"
  clear
end

menu
