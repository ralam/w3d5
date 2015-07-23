require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions

  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end

end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.to_s.downcase}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
  end
end

module Associatable
  # Phase IIIb

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      id = self.send(options.foreign_key)
      mclass = options.model_class
      target = mclass.where(id: id).first

    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      id = self.send(options.primary_key)
      mclass = options.model_class
      target = mclass.where({options.foreign_key => id})
    end
  end

  def assoc_options
    @assoc_options = {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
