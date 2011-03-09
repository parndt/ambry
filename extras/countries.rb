# A demo of Prequel's filters

require "bundler/setup"
require "prequel"

Prequel::Adapter.new

class Country
  extend Prequel::Model
  attr_accessor :tld, :name, :population, :region

  def self.african
    find {|p| p.region == :africa}
  end

  def self.european
    find {|p| p.region == :europe}
  end

  def self.population(op, num)
    find {|p| p.population.send(op, num)}.sort {|a, b| b.population <=> a.population}
  end
end

# Population data from: http://en.wikipedia.org/wiki/List_of_countries_by_population
[
  {:tld => "dz", :name => "Algeria",    :population => 33_333_216,    :region => :africa},
  {:tld => "bw", :name => "Botswana",   :population => 1_839_833,     :region => :africa},
  {:tld => "eg", :name => "Egypt",      :population => 80_335_036,    :region => :africa},
  {:tld => "et", :name => "Ethiopia",   :population => 85_237_338,    :region => :africa},
  {:tld => "ng", :name => "Nigeria",    :population => 154_729_000,   :region => :africa},
  {:tld => "sc", :name => "Seychelles", :population => 80_654,        :region => :africa},
  {:tld => "mz", :name => "Mozambique", :population => 20_366_795,    :region => :africa},
  {:tld => "ma", :name => "Morocco",    :population => 33_757_175,    :region => :africa},
  {:tld => "cn", :name => "China",      :population => 1_342_740_000, :region => :asia},
  {:tld => "br", :name => "Brazil",     :population => 190_732_694,   :region => :america},
  {:tld => "fr", :name => "France",     :population => 65_821_885,    :region => :europe},
  {:tld => "mc", :name => "Monaco",     :population => 33_000,        :region => :europe}

].each {|c| Country.create(c)}

@african_countries              = Country.african
@bigger_countries               = Country.population(:>=, 50_000_000)
@smaller_countries              = Country.population(:<=, 5_000_000)
@european_countries             = Country.european
@bigger_african_countries       = Country.african.population(:>=, 50_000_000)
@bigger_non_african_countries   = @bigger_countries - @african_countries
@bigger_or_european_countries   = @bigger_countries + @european_countries
@smaller_or_european_countries  = @smaller_countries + @european_countries
@smaller_european_countries     = @smaller_countries & @european_countries

instance_variables.each do |name|
  puts "%s: %s" % [
    name.to_s.gsub("_", " ").gsub("@", ""),
    instance_variable_get(name).all.map(&:name).join(", ")
  ]
end

# Output:
#
# african countries: Algeria, Botswana, Egypt, Ethiopia, Nigeria, Seychelles, Mozambique, Morocco
# bigger countries: China, Brazil, Nigeria, Ethiopia, Egypt, France
# smaller countries: Botswana, Seychelles, Monaco
# european countries: France, Monaco
# bigger african countries: Egypt, Ethiopia, Nigeria
# bigger non african countries: China, Brazil, France
# bigger or european countries: China, Brazil, Nigeria, Ethiopia, Egypt, France, Monaco
# smaller and european countries: Botswana, Seychelles, Monaco, France
# smaller european countries: Monaco