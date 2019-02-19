require_relative '../db-types/active-record/db_types.rb'
require 'types/core'
# require 'types/rails/object'
puts '--------------------------------------------------------'

module RDL::Globals
  # Map from table names (symbols) to their schema types, which should be a Table type
  @ar_db_schema = {}
end

class << RDL::Globals
  attr_accessor :ar_db_schema
end



puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n Made it here.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

def add_assoc(hash, aname, aklass)
  kl_type = RDL::Type::SingletonType.new(aklass)
  if hash[aname]
    hash[aname] = RDL::Type::UnionType.new(hash[aname], kl_type)
  else
    hash[aname] = kl_type unless hash[aname]
  end
  hash
end

Rails.application.eager_load!
MODELS = ActiveRecord::Base.descendants.each { |m|
  begin
    m.send(:load_schema) unless m.abstract_class?
  rescue
    puts "#{m} didn't work"
  end }

MODELS.each { |model|
  next if model.to_s == "ApplicationRecord"
  RDL.nowrap model
  s1 = {}
  model.columns_hash.each { |k, v| t_name = v.type.to_s.camelize
    if t_name == "Boolean"
      t_name = "%bool"
      s1[k] = RDL::Globals.types[:bool]
    elsif t_name == "Datetime"
      t_name = "DateTime or Time"
      s1[k] = RDL::Type::UnionType.new(RDL::Type::NominalType.new(DateTime), RDL::Type::NominalType.new(Time))
    elsif t_name == "Text"
      ## difference between `text` and `string` is in the SQL types they're mapped to, not in Ruby types
      t_name = "String"
      s1[k] = RDL::Globals.types[:string]
    else
      s1[k] = RDL::Type::NominalType.new(t_name)
    end
    RDL.type model, (k+"=").to_sym, "(#{t_name}) -> #{t_name}", wrap: false ## create method type for column setter
    RDL.type model, (k).to_sym, "() -> #{t_name}", wrap: false ## create method type for column getter
  }
  #s1 = model.columns_hash.transform_values { |v| t_name = v.type.to_s.camelize; RDL.type ""; RDL::Type::NominalType.new(t_name) }
  s2 = s1.transform_keys { |k| k.to_sym }
  assoc = {}
  model.reflect_on_all_associations.each { |a|
    add_assoc(assoc, a.macro, a.name)
    if a.name.to_s.pluralize == a.name.to_s ## plural association
      RDL.type model, a.name, "() -> ActiveRecord_Relation<#{a.name.to_s.camelize.singularize}>", wrap: false ## TODO: This actually returns an Associations CollectionProxy, which is a descendant of ActiveRecord_Relation (see below actual type). Not yet sure if this makes a difference in practice.
      #ActiveRecord_Associations_CollectionProxy<#{a.name.to_s.camelize.singularize}>'
    else
      ## association is singular, we just return an instance of associated class
      RDL.type model, a.name, "() -> #{a.name.to_s.camelize.singularize}", wrap: false
    end
  }
  s2[:__associations] = RDL::Type::FiniteHashType.new(assoc, nil)
  base_name = model.to_s
  base_type = RDL::Type::NominalType.new(model.to_s)
  hash_type = RDL::Type::FiniteHashType.new(s2, nil)
  schema = RDL::Type::GenericType.new(base_type, hash_type)
  RDL::Globals.ar_db_schema[base_name.to_sym] = schema
}

## uncomment the below to print out schema
# RDL::Globals.ar_db_schema.each { |k, v|
#   puts "#{k} has the following schema:"
#   v.params[0].elts.each { |k1, v1|
#     puts "     #{k1} => #{v1}"
#   }
# }

# class Datetime; end ## not sure why, but this class isn't initialized during typechecking so we need this

## types

# stdlib
RDL.type Object, :presence, '() -> self', wrap: false
RDL.type JSON, 'self.parse', '(String, {symbolize_names: %bool}) -> %bot', typecheck: :never, wrap: false # not checked
RDL.type DateTime, :>, '(Time or DateTime) -> %bool'
RDL.type Time, :>, '(Time or DateTime) -> %bool'
# we could definitely write better type rules for the next one. Hash<Symbol, %any> doesn't work
RDL.type HTTParty, 'self.post', '(URI::HTTP, Hash<Symbol, Hash<Symbol, String>>) -> HTTParty::Response', typecheck: :never, wrap: false # not checked
RDL.type HTTParty, 'self.post', '(URI::HTTP, Hash<Symbol, %any>) { () -> %any } -> HTTParty::Response', typecheck: :never, wrap: false # not checked
RDL.type HTTParty::Response, :body, '() -> String', typecheck: :never, wrap: false # not checked

# doesn't work
# RDL.type User, :available_services, '() -> Service', typecheck: :never, wrap: false # no scope support
# RDL.type User, 'self.find_first_by_auth_conditions', '({}) -> User', typecheck: :never, wrap: false # not used anywhere, so unknown hash definition
# RDL.type User, :active_for_authentication?, '() -> %bool', typecheck: :never, wrap: false # these 2 don't work because super calls methods loaded by Devise
# RDL.type User, :inactive_message, '() -> %bool', typecheck: :never, wrap: false


# works
RDL.type User, :active?, '() -> %bool', typecheck: :later, wrap: false
RDL.type User, :activate!, '() -> %bool', typecheck: :later, wrap: false
RDL.type User, :deactivate!, '() -> %bool', typecheck: :later, wrap: false

RDL.type Service, :disable_agents, '(?({where_not: { user_id: Integer } } or {})) -> Array<Agent>', typecheck: :later, wrap: false # this isn't typechecked because of error
RDL.type Service, :toggle_availability!, '() -> %bool', typecheck: :later, wrap: false
RDL.type Service, :endpoint, '() -> URI::HTTP', typecheck: :never, wrap: false # not checked
RDL.type Service, :oauth_key, '() -> String', typecheck: :never, wrap: false # not checked
RDL.type Service, :oauth_secret, '() -> String', typecheck: :never, wrap: false # not checked
RDL.type Service, :refresh_token!, '() -> %bool', typecheck: :later, wrap: false
# RDL.type Service, :prepare_request, '() -> %bool or nil', typecheck: :later, wrap: false

# RDL.type Scenario, :destroy_with_mode, '(all_agents or unique_agents) -> nil', typecheck: :later, wrap: false

## typecheck
# RubyProf.start
start = Time.now
RDL.do_typecheck :later
finish = Time.now
# result = RubyProf.stop
puts(finish - start)

# printer = RubyProf::CallStackPrinter.new(result)
# outfile = File.open("profile.html", "w")
# printer.print(outfile, :profile => "profile", :min_percent => 1)
