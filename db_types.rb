RDL.nowrap ActiveRecord::Associations::ClassMethods
RDL::Globals.info.info['ActiveRecord::Associations::ClassMethods'] = nil

MODELS = ActiveRecord::Base.descendants

class ActiveRecord_Relation
  extend RDL::Annotate
  type_params [:t], :dummy
  type :collect, "() { (t) -> u } -> Array<u>", wrap: false
  type :map, '() { (t) -> u } -> Array<u>'
  type :find_each, "() { (t) -> x } -> nil", wrap: false
  type :valid, "() -> self", wrap: false
  type :no_answer_for, "(Question) -> self", wrap: false
  type :count, "() -> Integer", wrap: false
  type :all, '() -> self', wrap: false ### kind of a silly method, always just returns self
  type :each, '() -> Enumerator<t>', wrap: false
  type :each, '() { (t) -> %any } -> Array<t>', wrap: false
  type :order, '(%any) -> self', wrap: false
  type :limit, "(Integer) -> self", wrap: false
  type :includes, "(Symbol) -> ActiveRecord_Relation", wrap: false
  type :includes, "(Symbol, Hash<Symbol, Symbol> ) -> ActiveRecord_Relation", wrap: false
  type :references, "(Symbol, *Symbol) -> self", wrap: false
  type :to_a, "() -> Array<t>", wrap: false
  type :first, "() -> t", wrap: false
  type :select, "() { (t) -> %bool } -> self", wrap: false
  type :[] , "(Integer) -> t", wrap: false
  type :group, "(Symbol or String) -> self", wrap: false
  type :where, "(String, Hash<Symbol, String>) -> self", wrap: false
  type :where, "(Hash<Symbol, x>) -> self", wrap: false
  type :where, "() -> self", wrap: false
  type :not, '(%any) -> self', wrap: false
  type :find, "(Integer) -> t", wrap: false
  type :find_by, "(Hash<Symbol, x>) -> t", wrap: false
  type :size, "() -> Integer", wrap: false
  type :build, "(?Hash<Symbol, x>) -> t", wrap: false
  type :update_all, '(Hash<Symbol, x>) -> nil', wrap: false
end

class ActiveRecord::Base
  extend RDL::Annotate
  #type 'self.where', "(Hash<Symbol, x>) -> ActiveRecord_Relation", wrap: false
  #type 'self.find', "(Integer) -> self", wrap: false
  #type 'self.find', "(Array<Integer>) -> Array<self>", wrap: false
  type :attribute_names, "() -> Array<String>", wrap: false
  type :to_json, "(?{ only: Array<String> }) -> String", wrap: false
  type :initialize, "(Hash<Symbol, x>) -> self", wrap: false
  type :initialize, "() -> self", wrap: false
  type :save, '() -> %bool', wrap: false
  type :save!, '(?({ validate: %bool })) -> %bool', wrap: false
  type :destroy, '() -> self', wrap: false
  type :reload, "() -> %any", wrap: false
  type 'self.includes', "(*Symbol) -> ActiveRecord_Relation", wrap: false
  type 'self.includes', "(Symbol, Hash<Symbol, Symbol> ) -> ActiveRecord_Relation", wrap: false
  type :[], '(Symbol) -> Object', wrap: false
  type 'self.transaction', '() {() -> t } -> t', wrap: false
  type :update_attribute, '(Symbol, %any) -> %bool', wrap: false
  type :update, '(Hash<Symbol, x>) -> %bool', wrap: false
end

MODELS.each { |model|
  RDL.nowrap model
  RDL.type model, 'self.find', "(Integer) -> #{model}", wrap: false
  RDL.type model, 'self.find', "(Array<Integer>) -> Array<#{model}>", wrap: false
  RDL.type model, 'self.where', "(Hash<Symbol, x>) -> ActiveRecord_Relation<#{model}>", wrap: false
  RDL.type model, 'self.find_by', "(Hash<Symbol, x>) -> #{model}", wrap: false
  RDL.type model, 'self.create', "(Hash<Symbol, x>) -> #{model}", wrap: false
  RDL.type model, 'self.order', "(%any) -> ActiveRecord_Relation<#{model}>", wrap: false
  s1 = {}
  model.columns_hash.each { |k, v| t_name = v.type.to_s.camelize
    if t_name == "Boolean"
      t_name = "%bool"
      s1[k] = RDL::Globals.types[:bool]
    elsif t_name == "Datetime"
      t_name = "DateTime or Time"
      s1[k] = RDL::Type::UnionType.new(RDL::Type::NominalType.new(Time), RDL::Type::NominalType.new(DateTime))
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
  s2 = s1.transform_keys { |k| k.to_sym }
  assoc = {}

  model.reflect_on_all_associations.each { |a|
    #add_assoc(assoc, a.macro, a.name)
    if a.name.to_s.pluralize == a.name.to_s ## plural association
      RDL.type model, a.name, "() -> ActiveRecord_Relation<#{a.class_name}>", wrap: false ## TODO: This actually returns an Associations CollectionProxy, which is a descendant of ActiveRecord_Relation (see below actual type). Not yet sure if this makes a difference in practice.
    #ActiveRecord_Associations_CollectionProxy<#{a.name.to_s.camelize.singularize}>'
      RDL.type model, "#{a.name}=", "(ActiveRecord_Relation<#{a.class_name}>) -> ActiveRecord_Relation<#{a.class_name}>", wrap: false
      RDL.type model, "#{a.name}=", "(Array<#{a.class_name}>) -> Array<#{a.class_name}>", wrap: false
    else
      ## association is singular, we just return an instance of associated class
      RDL.type model, a.name, "() -> #{a.class_name}", wrap: false
      RDL.type model, "#{a.name}=", "(#{a.class_name}) -> #{a.class_name}", wrap: false
    end
  }
}
