require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    result = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    result.first.map do |col_name|
      col_name.to_sym
    end
  end

  def self.finalize!
    col_syms = self.columns

    col_syms.each do |col_sym|
      define_method(col_sym) do
        # instance_variable_get("@#{col_sym}")

        attributes[col_sym]
      end

      define_method("#{col_sym}=") do |value|
        # instance_variable_set("@#{col_sym}", value)

        attributes[col_sym] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all

    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    parse_all(rows)
  end


  def self.parse_all(results)
    result = []

    results.each do |hash|
      # initialize takes hash of params
      result << self.new(hash)
    end

    result
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    result.empty? ? nil : self.new(result.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)

      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col_name| self.send(col_name) }
  end

  def insert
    col_names = self.class.columns.join(', ')
    question_marks = (["?"] * self.class.columns.count).join(', ')

    table_name = self.class.table_name

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns

    set_line = col_names[1..-1].map do |col_name|
      col_name.to_s + " = ?"
    end.join(', ')

    table_name = self.class.table_name

    DBConnection.execute(<<-SQL, *attribute_values[1..-1], id)
      UPDATE
        #{table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL

  end

  def save
    id.nil? ? insert : update
  end
end
