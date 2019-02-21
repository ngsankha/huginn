require './db_types.rb'
require 'types/core'

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
RDL.type JSON, 'self.parse', '(String, {symbolize_names: %bool}) -> %bot'
RDL.type DateTime, :>, '(Time or DateTime) -> %bool'
RDL.type Time, :>, '(Time or DateTime) -> %bool'
RDL.type HTTParty, 'self.post', '(URI::HTTP, Hash<Symbol, Hash<Symbol, String>>) -> HTTParty::Response'
RDL.type HTTParty, 'self.post', '(URI::HTTP, Hash<Symbol, %any>) { () -> %any } -> HTTParty::Response'
RDL.type HTTParty::Response, :body, '() -> String'
RDL.type Service, :endpoint, '() -> URI::HTTP'
RDL.type Service, :oauth_key, '() -> String'
RDL.type Service, :oauth_secret, '() -> String'
RDL.type User, :deactivated_at, '() -> DateTime'
RDL.type User, :agents, '() -> ActiveRecord_Relation<Agent>'
RDL.type Service, :agents, '() -> ActiveRecord_Relation<Agent>'
RDL.type Agent, :service_id=, '(Integer) -> nil'
RDL.type Agent, :disabled=, '(%bool) -> nil'
RDL.type Service, :global, '() -> %bool'
RDL.type Service, :global=, '(%bool) -> nil'
RDL.type Service, :user_id, '() -> Integer'
RDL.type Service, :refresh_token, '() -> String'
RDL.type Service, :expires_at, '() -> DateTime'

## Call to `do_typecheck` will type check all the methods above with the :later label.
## The second argument is optional and is used for printing configurations.
RDL::Config.instance.use_dep_types = false
RDL.do_typecheck :later, (ENV["NODYNCHECK"] || ENV["TYPECHECK"])
