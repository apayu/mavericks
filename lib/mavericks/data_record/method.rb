require 'yaml'

module Mavericks
  module DataRecord
    module Method
      def establish_connection
        raw = File.read('config/database.yml')
        database_config = YAML.safe_load(raw)
        case database_config['default']['adapter']
        when 'postgresql'
          @@connection = ConnectionAdapter::PostgreSQLAdapter.new(database_config['development']['database'])
        when 'sqlite'
          # sqlite connection
        end
      end

      def connection
        @@connection
      end

      def schema
        self.connection.execute("SELECT column_name FROM information_schema.columns
        WHERE table_name= '#{self.table_name}'").map{|m|  m["column_name"]}
      end

      def table_name
        singular_table_name = Mavericks.to_underscore name
        Mavericks.to_plural singular_table_name
      end

      def set_column_to_attribute
        columns = self.connection.execute("SELECT column_name FROM information_schema.columns
          WHERE table_name= '#{self.table_name}'").map{|m|  m["column_name"]}
        columns.each{ |column| define_method_attribute(column) }
      end

      def define_method_attribute(name)
        class_eval <<-STR
          def #{name}
            @attributes[:#{name}] || @attributes["#{name}"]
          end

          def #{name}=(value)
            @attributes[:#{name}] = value
          end
        STR
      end

      def to_sql(val)
        case val
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't support #{val.class} to SQL!"
        end
      end

      def count
        self.connection.execute(<<-SQL)[0]['count']
          SELECT COUNT(*) FROM #{self.table_name}
        SQL
      end

      def all
        Relation.new(self).records
      end

      def last
        all.last
      end

      def find(id)
        find_by_sql("SELECT * FROM #{self.table_name} WHERE id = #{id.to_i}").first
      end

      def find_by_sql(sql)
        connection.execute(sql).map do |attributes|
          new(attributes)
        end
      end

      def where(query)
        sql_syntax = query.map do |key, val|
          "#{key.to_s} = #{self.to_sql(val)}"
        end
        Relation.new(self).where(sql_syntax)
      end
    end
  end
end
