require 'machinist/mongo_mapper'
require 'faker'

Sham.define do
  name {Faker::Name.name}
  name_unique {|index| "#{Faker::Name.name}#{index}"}
  description {Faker::Lorem.sentence}
  user_name { Faker::Internet.user_name }
  email {Faker::Internet.email}
  first_name {Faker::Name.first_name}
  last_name {Faker::Name.last_name} 
  postcode {Faker::Address.uk_postcode}
  address1 {Faker::Address.street_address}
  address2 {Faker::Address.street_suffix}
  street {Faker::Address::street_name}
  city {Faker::Address.city}
  county {Faker::Address.country}
  country{Faker::Address.country}
  unique_country {|index| "#{Faker::Address.country}#{index}"}
  address_number {|index| index}
  phone_number {Faker::PhoneNumber.phone_number}
  company_name {Faker::Company.name}
  ip_address {|index| "127.0.#{index}.0"}
  url {"http://#{Faker::Internet.domain_name}"}
end

ApiUser.blueprint do
  first_name {Sham.first_name}
  last_name {Sham.last_name}
  email {Sham.email}
end

ObjectTemplate.blueprint do
  name {Sham.name}
  characteristics {
    [
      {"attribute" => "label", "value_type"=> "String"}, 
      {"attribute" => "width", "value_type"=> "Float", :units => "meters"}, 
      {"attribute" => "dimensions", "value_type"=> "String", :units => "lxwxh"}, 
      {"attribute" => "weight", "value_type"=> "Float", :units => "kg"}
    ]
  }
  relatable_characteristics {
    [
      {"attribute" => "manufacturer", "value_type"=> "String"},
      {"attribute" => "size", "value_type"=> "String", :units => "inches"},
      {"attribute" => "hdmi", "value_type"=> "Boolean"},
      {"attribute" => "epeat", "value_type"=> "Float", :units => "meters"}
    ]
  }
end


MainSource.blueprint do
  name {Sham.name}
  description {Sham.description}
end

GenericObject.blueprint do
  object_template_id { ObjectTemplate.make.id}
  characteristics {[]}
  relatable_characteristics {[]}
end

Calculator.blueprint do
  name {Sham.name}
end

Computation.blueprint do
  name {Sham.name}
  calculator {Calculator.make}
end

GlobalComputation.blueprint do
  name {"distance"}
  parameters{[:lat1, :lat2]}
  equation {"value(:lat)*value(:lng)"}
end

GlobalConstant.blueprint do
  value {12.0}
  units {"eggs"}
end

Calculator.blueprint do
  name {Sham.name}
  description {Sham.description}
  tags {["Beans", "Eggs"]}
end

AnswerChoices::Variable.blueprint do
  answer_set {AnswerSet.make}
  name {Sham.name}
  units {"persons"}
end

AnswerChoices::Option.blueprint do
  answer_set {AnswerSet.make}
  name {Sham.name}
  options {{"many" => 4, "options" => 5, "togther" => 8, "make" => 9, "sense" => 10}}
end

AnswerChoices::ObjectReference.blueprint do
  answer_set {AnswerSet.make}
  name {Sham.name}
  object_name {"tv"}
end

AnswerSet.blueprint do
  computation {Computation.make}
  model_state{"pending"}
  source {Source.new(:id => "4ca46555dfde7b4219000005", :name => "beans", :description => "egg")}
end

Validations::Presence.blueprint do
  message {"needs to be entered"}
  validatable {AnswerChoices::Variable.make}
end

Validations::MustHaveCharacteristic.blueprint do
  validatable {AnswerChoices::ObjectReference.make}
  options{{"name" => "beans", "characteristic_attribute" => "beans"}}
end

Validations::MustNotHaveCharacteristic.blueprint do
  validatable {AnswerChoices::ObjectReference.make}
  options{{"name" => "beans", "characteristic_attribute" => "beans"}}
end

Validations::MustHaveFormulaInputName.blueprint do
  validatable {AnswerSet.make}
  options{{"name" => "beans", "object_reference_name" => "eggs"}}
end

Validations::Numericality.blueprint do
  message {"needs to be entered"}
  validatable {AnswerChoices::Variable.make}
end

Validations::Length.blueprint do
  options {{"within" => "1..10"}}
  message {"needs to be entered"}
  validatable {AnswerChoices::Variable.make}
end
