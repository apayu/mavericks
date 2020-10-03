module ActiveRecord
  class Relation
    def initialize(klass)
      @klass = klass
      @where_values = []
    end

    def to_sql
      sql = "SELECT * FROM #{@klass.table_name}"
      if @where_values.any?
        sql += " WHERE " + @where_values.join(' AND ')
      end
      sql
    end

    def records
      @records ||= @klass.find_by_sql(to_sql)
    end

    def where(sql_syntax)
      if sql_syntax.class == Hash
        @where_values += sql_syntax.map { |key, val| "#{key.to_s} = #{@klass.to_sql(val)}" }
      else
        @where_values += [sql_syntax]
      end
      self
    end

    def first
      records.first
    end

    def each(&block)
      records.each(&block)
    end
  end
end
