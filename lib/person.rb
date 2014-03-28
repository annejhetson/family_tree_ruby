class Person < ActiveRecord::Base
  validates :name, :presence => true
  # validates :sex_male, :presence => true
  # validates :parent_1, :presence => true
  # validates :parent_2, :presence => true

  has_many :kids, class_name: "Person",
                  foreign_key: "parent_1_id"


  belongs_to :parent_1, class_name: "Person"

  has_many :kids, class_name: "Person",
                  foreign_key: "parent_2_id"

  belongs_to :parent_2, class_name: "Person"


#write association for person.parent

  after_save :make_marriage_reciprocal

  def spouse
    if spouse_id.nil?
      nil
    else
      Person.find(spouse_id)
    end
  end
  def sibling
    array = []

    person = Person.find(self.id)
    parent_id = person.parent_1_id
    siblings = Person.where({parent_1_id: parent_id})
    siblings.each do |sibling|
      if sibling.name != person.name
        array << sibling
        puts "sibling: " + sibling.name
      end
    end
    array
  end

  def parent
    array = []
    person = Person.where({id: self.id}).first
    array << person.parent_1
    array << person.parent_2
    # array.each {|person| puts person.name}
  end

private

  def make_marriage_reciprocal
    if spouse_id_changed? && spouse_id != 0
      spouse.update(:spouse_id => id)
    end
  end
end

