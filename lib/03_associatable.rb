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
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
    @foreign_key = options[:foreign_key] || (name.to_s + "_id").to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
    @foreign_key = options[:foreign_key] || (self_class_name + "Id").underscore.to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    bt_assoc = BelongsToOptions.new(name, options)

    define_method(name) do
      bt_assoc
        .model_class
        .where(bt_assoc.primary_key => send(bt_assoc.foreign_key))
        .first
    end
  end

  def has_many(name, options = {})
    # hm_assoc = HasManyOptions.new(name, options)
    #
    # define_method(name) do
    #   hm_assoc
    #     .model_class
    #     .where(hm_assoc.foreign_key => send(hm_assoc.foreign_key))
    # end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
