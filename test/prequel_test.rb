require File.expand_path("../test_helper", __FILE__)
require "prequel/adapters/yaml"

class Person
  extend Prequel::Model
  attr_accessor :name, :email
  attr_id :email

  def self.stooges
    with_index("stooges") do
      find {|p| p[:email] =~ /3stooges.com/}
    end
  end

  def self.non_howards
    with_index("non_howards") do
      find {|p| p[:name] !~ /Howard/}
    end
  end
end

class PrequelTest < Test::Unit::TestCase

  def setup
    Prequel.adapters = {}
    @path            = File.expand_path("../fixtures.yml", __FILE__)
    @adapter         = Prequel::Adapters::YAML.new(:name => :main, :file => @path)
    @mapper          = Prequel::Mapper.new(Person, :main)
    Person.mapper    = @mapper
  end

  test "should store a model instance in the database" do
    assert Person.create(:name => "Curly Joe DeRita", :email => "curlyjoe@3stooges.com")
  end

  test "should get a model instance by key" do
    assert Person.create(:name => "Curly Joe DeRita", :email => "curlyjoe@3stooges.com")
    assert_equal "Curly Joe DeRita", Person.get("curlyjoe@3stooges.com").name
  end

  test "find should return an instance of key set" do
    assert_equal "Prequel::KeySet", Person.find.class.to_s
  end

  test "should find a model instance by hash key" do
    assert_equal "moe@3stooges.com", Person.find {|p| p[:name] == "Moe Howard"}.keys.first
  end

  test "should find a model instance by method" do
    assert_equal "moe@3stooges.com", Person.find {|p| p.name == "Moe Howard"}.keys.first
  end

  test "should raise error when accessing non existant method by proxy" do
    assert_raise NoMethodError do
      Person.find {|p| p.foobar == "Moe Howard"}
    end
  end

  test "should sort entries" do
    assert_equal "Curly Howard", Person.all.sort {|a, b| a[:name] <=> b[:name]}.first.name
    assert_equal "Shemp Howard", Person.all.sort {|a, b| b[:name] <=> a[:name]}.first.name
  end

  test "should count model instances" do
    assert_equal 4, Person.count
  end

  test "should use indexes" do
    Person.create(:name => "Ted Healy", :email => "ted@healy.com")

    assert Person.stooges.keys.include?("moe@3stooges.com")
    assert Person.stooges.keys.include?("larry@3stooges.com")

    assert !Person.non_howards.keys.include?("moe@3stooges.com")
    assert Person.non_howards.keys.include?("ted@healy.com")
    assert Person.non_howards.keys.include?("larry@3stooges.com")

    assert !Person.stooges.non_howards.keys.include?("moe@3stooges.com")
    assert !Person.stooges.non_howards.keys.include?("ted@healy.com")
    assert Person.stooges.non_howards.keys.include?("larry@3stooges.com")
  end
end
