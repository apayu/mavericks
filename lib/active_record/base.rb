require 'yaml'

module ActiveRecord
  class Base
    include Persistence

    def initialize(attributes = {})
      self.class.set_column_to_attribute
      @attributes = attributes
      @new_record = true
    end

    def new_record?
      @new_record
    end

    def self.establish_connection
      raw = File.read('config/database.yml')
      database_config = YAML.safe_load(raw)
      case database_config['default']['adapter']
      when 'postgresql'
        @@connection = ConnectionAdapter::PostgreSQLAdapter.new(database_config['development']['database'])
      when 'sqlite'
        @@connection = ConnectionAdapter::SQLiteAdapter.new(database_config['development']['database'])
      end
    end

    def self.connection
      @@connection
    end

    def self.set_column_to_attribute
      self.connection.schema(self.table_name).each{ |column| self.define_method_attribute(column) }
    end

    def self.define_method_attribute(name)
      class_eval <<-STR
        def #{name}
          @attributes[:#{name}] || @attributes["#{name}"]
        end

        def #{name}=(value)
          @attributes[:#{name}] = value
        end
      STR
    end

    def self.table_name
      singular_table_name = Mavericks.to_underscore name
      Mavericks.to_plural singular_table_name
    end

    def self.count
      self.connection.execute(<<-SQL)[0]['count']
        SELECT COUNT(*) as count FROM #{self.table_name}
      SQL
    end

    def self.to_sql(val)
      case val
      when Numeric
        val.to_s
      when String
        "'#{val}'"
      else
        raise "Can't support #{val.class} to SQL!"
      end
    end

    def self.all
      Relation.new(self).records
    end

    def self.last
      all.last
    end

    def self.find(id)
      find_by_sql("SELECT * FROM #{self.table_name} WHERE id = #{id.to_i}").first
    end

    def self.find_by_sql(sql)
      connection.execute(sql).map do |attributes|
        new(attributes)
      end
    end

    def self.where(query)
      sql_syntax = query.map do |key, val|
        "#{key.to_s} = #{self.to_sql(val)}"
      end
      Relation.new(self).where(sql_syntax)
    end
  end
end
