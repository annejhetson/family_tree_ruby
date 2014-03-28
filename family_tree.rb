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
    # puts 'Press p to update parents.'
    puts 'Press u to update.'
    puts 'Press lp to list a persons parents'
    puts 'Press lap to list all parents'
    puts 'Press lag to list all grandparents'
    puts 'Press ww to list a persons relatives'
    puts 'Press e to exit.'
    puts 'Press d to delete....use with extream caution!!!'
    choice = gets.chomp

    case choice
    when 'a'
      add_person
    when 'l'
      list
    when 'm'
      update_marriage
    when 's'
      show_marriage
    when 'd'
      delete_person
    when 'lp'
      list_parent
    when 'lap'
      list_all_parents
    when 'lag'
      list_all_grandparents
    when 'ww'
      list_relatives
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
  # binding.pry
  new_person = Person.create(:name => name, :sex_male => gender)
  person = Person.where(name: name).first

  add_parents(person)
  puts "Thanks for adding your parent information!\n"

  add_marriage(person)

  puts name + " was added to the family tree.\n\n"
end

def add_marriage(person)
  list
  puts "What is the number of your spouse or 'ns'"
  spouse1 = gets.chomp
  if spouse1 == 'ns'

    person.update(spouse_id: 0)
  else
  person.update(spouse_id: spouse1.to_i)
  spouse2 = Person.find(spouse1.to_i)
  spouse2.update(spouse_id: person.id)
  end
end

def update_marriage
  list
  puts 'What is the number of the first spouse?'
  spouse1 = Person.find(gets.chomp)
  puts 'What is the number of the second spouse or "ns"'
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

def list_grandparents
  list
  choice = gets.chomp.to_i
  person = Person.find(choice)
  person.parent.each {|parent| parent.parent.each {|x| puts x.name}}
  puts "GRANDPA!!!!!!"
end

def list_all_grandparents
  people = Person.order(:id)
  people.each do |person|
    if person.parent_1 != nil && person.parent_2 != nil
      person.parent.each do|parent|
        if parent.parent_1 != nil && parent.parent_2 != nil
          parent.parent.each do |grandparent|
            if  parent.parent_1 != nil && parent.parent_2 != nil
              puts "#{person.name}, I love my grandparent: #{grandparent.name}!!!"
            else
              puts "NO GRANDPARENT"
            end
          end

        else
          puts "NO PARENT GRANDPARENTS"
        end
      end
    else
      puts 'DONT HAVE PARENTS'
    end
  end
end

def list_all_parents
  people = Person.order(:id)
  people.each do |person|
    if person.parent_1 != nil && person.parent_2 != nil
      person.parent.each do|parent|

        if parent.name != nil
          puts "#{person.name}........... has parent: #{parent.name}"
        else
          puts "No parent"
        end
      end
    else
      puts "#{person.name}......... parent doesn't exist or might have one..."
    end
  end
end

def list_parent
  list
  puts "Please choose a person's id, to see their parents"
  person = Person.find(gets.chomp.to_i)

  if person.parent_1_id == nil && person.parent_2_id == nil
    puts "Please update parent information for #{person.name}."
  elsif person.parent_1_id == 0 && person.parent_2_id == 0
     puts "#{person.name} has no parents on record."
  elsif person.parent_1_id > 0 && person.parent_2_id == 0
    parent_1_id = Person.find(person.parent_1_id.to_i)
    puts "#{person.name}'s parent is #{parent_1_id.name}."
  else
    parent_1_id = Person.find(person.parent_1_id.to_i)
    parent_2_id = Person.find(person.parent_2_id.to_i)
    puts "#{person.name} parents are #{parent_1_id.name} and #{parent_2_id.name}."

  end
end

def list_relatives
  list
  puts "Please choose a person's id, to see their relatives"
  person = Person.find(gets.chomp.to_i)


  puts "#{person.name} is married to #{person.spouse.name}"
  puts "My parents are #{person.parent_1.name} and #{person.parent_2.name}"
  puts "My grandparents are #{person.parent_1.parent_1.name} and #{person.parent_1.parent_2.name}"
  puts "My grandparents are also #{person.parent_2.parent_1.name} and #{person.parent_2.parent_2.name}"
  person.sibling
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

def add_parents(person)
  puts "\n "
  list
  puts "Please enter the id of parent 1 or np for no parent"
  parent_1_id = gets.chomp.to_i
  # binding.pry
  if parent_1_id == "np"
    parent_1_id = 0
  end
  puts "Please enter the id of parent 2 or np for no parent"
  parent_2_id = gets.chomp.to_i
  if parent_2_id == "np"
    parent_2_id = 0
  end
  person.update(parent_1_id: parent_1_id, parent_2_id: parent_2_id)
  if parent_1_id == 0 && parent_2_id == 0
    puts "#{person.name}'s parent status has been updated"
  elsif parent_2_id == 0
  puts "#{person.name}'s parent, #{Person.find(parent_1_id).name} has been added as a single parent...depressing"
  elsif parent_2_id > 0 && parent_1_id > 0
  puts "#{person.name}'s parents, #{Person.find(parent_1_id).name} and #{Person.find(parent_2_id).name} are added"
  else
    error
  end

end
def edit_parents
  puts "\n "
  list
  puts "\n Who would you like to add parent(s) to"
  person = Person.find(gets.chomp.to_i)
  puts "Please enter the id of parent 1 or np for no parent"
  parent_1_id = gets.chomp.to_i
  if parent_1_id == "np"
    parent_1_id = 0
  end
  puts "Please enter the id of parent 2 or np for no parent"
  parent_2_id = gets.chomp.to_i
  if parent_2_id == "np"
    parent_2_id = 0
  end
  person.update(parent_1_id: parent_1_id, parent_2_id: parent_2_id)
  if parent_1_id == 0 && parent_2_id == 0
    puts "#{person.name}'s parent status has been updated"
  elsif parent_2_id == 0
  puts "#{person.name}'s parent, #{Person.find(parent_1_id).name} has been added as a single parent...depressing"
  elsif parent_2_id > 0 && parent_1_id > 0
  puts "#{person.name}'s parents, #{Person.find(parent_1_id).name} and #{Person.find(parent_2_id).name} are added"
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
