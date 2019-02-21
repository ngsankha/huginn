require_relative '../db-types/active-record/db_types.rb'
require 'types/core'

## file required below builds the schema model used during type checking
require_relative './build_schema.rb'

puts "Type checking methods from Huginn..."

### Annotations for type checked methods.
RDL.type User, :active?, '() -> %bool', typecheck: :later, wrap: false
RDL.type User, :activate!, '() -> %bool', typecheck: :later, wrap: false
RDL.type User, :deactivate!, '() -> %bool', typecheck: :later, wrap: false
RDL.type Service, :disable_agents, '(?({where_not: { user_id: Integer } } or {})) -> Array<Agent>', typecheck: :later, wrap: false
RDL.type Service, :toggle_availability!, '() -> %bool', typecheck: :later, wrap: false
RDL.type Service, :refresh_token!, '() -> %bool', typecheck: :later, wrap: false
RDL.type Service, :prepare_request, '() -> %bool or nil', typecheck: :later, wrap: false

### Annotations for variables and non-checked methods. These methods either come from the Huginn app or from external libraries.
RDL.type Object, :presence, '() -> self'
RDL.type JSON, 'self.parse', '(String, ?{symbolize_names: %bool}) -> Hash<k, v>'
RDL.type DateTime, :>, '(Time or DateTime) -> %bool'
RDL.type Time, :>, '(Time or DateTime) -> %bool'
RDL.type HTTParty, 'self.post', '(URI::HTTP, Hash<Symbol, Hash<Symbol, String>>) -> HTTParty::Response'
RDL.type HTTParty, 'self.post', '(URI::HTTP, Hash<Symbol, %any>) { () -> %any } -> HTTParty::Response'
RDL.type HTTParty::Response, :body, '() -> String', wrap: false
RDL.type Service, :endpoint, '() -> URI::HTTP'
RDL.type Service, :oauth_key, '() -> String'
RDL.type Service, :oauth_secret, '() -> String'

## Call to `do_typecheck` will type check all the methods above with the :later label.
## The second argument is optional and is used for printing configurations.
RDL.do_typecheck :later, (ENV["NODYNCHECK"] || ENV["TYPECHECK"])
