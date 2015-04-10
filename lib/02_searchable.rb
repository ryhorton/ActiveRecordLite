require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    values = params.values

    where_line = params.keys.map do |key|
      "#{key} = ?"
    end.join(' AND ')

    table_name

    rows = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    result = []
    rows.each do |row|
      result << self.new(row)
    end

    result
  end
end

class SQLObject
  # Mixin Searchable here...

  # extend means it is a CLASS METHOD
  extend Searchable
end
