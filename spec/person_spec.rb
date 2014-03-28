require 'spec_helper'

describe Person do
  it { should validate_presence_of :name }

  context '#spouse' do
    it 'returns the person with their spouse_id' do
      earl = Person.create(:name => 'Earl', :sex_male => true)
      steve = Person.create(:name => 'Steve', :sex_male => true)
      steve.update(:spouse_id => earl.id)
      steve.spouse.should eq earl
    end

    it "is nil if they aren't married" do
      earl = Person.create(:name => 'Earl', :sex_male => true)
      earl.spouse.should be_nil
    end
  end

  it "updates the spouse's id when it's spouse_id is changed" do
    earl = Person.create(:name => 'Earl', sex_male: true)
    steve = Person.create(:name => 'Steve', sex_male: true)
    steve.update(:spouse_id => earl.id)
    earl.reload
    earl.spouse_id.should eq steve.id
  end
  # it "list all parents of a person" do
  #   steve = Person.create(:name => 'Steve', sex_male: true)
  #   penny_dad = Person.create(:name => 'Steve SR.', sex_male: true)
  #   penny_mom = Person.create(:name => 'Penny SR.', sex_male: true)
  #   penny = Person.create(:name => 'Penny', sex_male: true, parent_1_id: penny_mom.id, parent_2_id: penny_dad.id)
  #   earl = Person.create(:name => 'Earl', sex_male: true, parent_1_id: steve.id, parent_2_id: penny.id)
  #   earl.parent.should eq 'Steve + Penny'
  #   earl.parent_2.parent.should eq 'Penny SR. + Steve SR.'
  # end
end
