class ActiveRecord_Relation
  extend RDL::Annotate
  include ActiveRecord::QueryMethods
  include ActiveRecord::FinderMethods
  include ActiveRecord::Calculations
  include ActiveRecord::Delegation

  type_params [:t], :dummy

  type :group, '(Symbol) -> Table<t>', wrap: false
  type :where, '(%any, *%any) -> Table<t>', wrap: false
  type :where, '() -> Table<t>', wrap: false
  type :empty?, '() -> %bool', wrap: false
  type :create, '(Hash<Symbol, x>) -> self', wrap: false
  type :create!, '(Hash<Symbol, x>) -> self', wrap: false
  type :find_by, '(Hash<Symbol, x>) -> Table<t>', wrap: false
  type :build, '(Hash<Symbol, String>) -> Table<t>', wrap: false
  type :map, '() { (t) -> u } -> Array<u>', wrap: false
  type :references, '(Symbol, *Symbol) -> ActiveRecord_Relation<t>', wrap: false
  type :update_all, '(Hash<Symbol, x>) -> nil', wrap: false
end

# class ActiveRecord_Relation
#   extend RDL::Annotate
#   include ActiveRecord::QueryMethods
#   include ActiveRecord::FinderMethods
#   include ActiveRecord::Calculations
#   include ActiveRecord::Delegation

#   type_params [:t], :dummy

#   type :group, '(Symbol) -> Table<t>', wrap: false
#   type :where, '(%any, *%any) -> Table<t>', wrap: false
#   type :empty?, '() -> %bool', wrap: false
#   type :create, '(Hash<Symbol, x>) -> self', wrap: false
#   type :create!, '(Hash<Symbol, x>) -> self', wrap: false
#   type :find_by, '(Hash<Symbol, x>) -> Table<t>', wrap: false
#   type :build, '(Hash<Symbol, String>) -> Table<t>', wrap: false
#   type :map, '() { (t) -> u } -> Array<u>'
#   type :references, '(Symbol, *Symbol) -> ActiveRecord_Relation<t>', wrap: false
# end

class ActiveRecord::Base
  extend RDL::Annotate

  type :initialize, '(Hash<Symbol, String or true>) -> self', wrap: false
  type :initialize, '() -> self', wrap: false
  type :save!, '(?({ validate: %bool })) -> %bool', wrap: false
  type :update!, '(Hash<Symbol, x>) -> %bool', wrap: false
  type 'self.create', '(Hash<Symbol, x>) -> self', wrap: false
  type 'self.with_deleted', '() -> ActiveRecord_Relation<self>', wrap: false
#   type :includes, "(Symbol) -> ActiveRecord_Relation<self>", wrap: false
  type 'self.includes', "(Symbol, *%any) -> ActiveRecord_Relation<self>", wrap: false
  type 'self.transaction', '() {() -> t } -> t', wrap: false
#   type :includes, "(Symbol, *Symbol or Hash<Symbol, Symbol> ) -> ActiveRecord_Relation<self>", wrap: false
end

class Table
  extend RDL::Annotate

  type_params [:t], :dummy

  type :select, '(Symbol or String or Array<String>, *Symbol or String or Array<String>) -> Table<t>', wrap: false
  type :joins, '(Symbol, *%any) -> Table<t>', wrap: false
  type :order, '(String) -> Table<t>', wrap: false
  type :includes, "(Symbol) -> Table<t>", wrap: false
  type :includes, "(Symbol, *%any ) -> Table<t>", wrap: false
  type :where, '(%any, *%any) -> Table<t>', wrap: false
  type :limit, '(Integer) -> Array<t>', wrap: false
  type :active, '() -> Table<t>', wrap: false
  type :first, '() -> t', wrap: false
  type :where, '(%any, *%any) -> Table<t>', wrap: false
  type :where, '() -> Table<t>', wrap: false
  type :not, '(%any, *%any) -> Table<t>', wrap: false
  type :count, '() -> Integer', wrap: false
  type :references, '(Symbol, *Symbol) -> Table<t>', wrap: false
  type :each, '() -> Enumerator<t>', wrap: false
  type :each, '() { (t) -> %any } -> Array<t>', wrap: false
end
