require 'sqlite3'
require 'mavericks/support'

DB = SQLite3::Database.new 'just_do.db'

module Mavericks
  module Model
    class SQLite
      def initialize(data = nil)
        @hash = data
      end

      def method_missing(attr, *args)
        attrs = self.class.schema
        attr = attr.to_s.gsub('=', '')
        if attrs.key?(attr)
          self.class.define_attr(attrs)
          val = args.empty? ?  self.send(attr) : self.send("#{attr}=", args[0])
          return val
        else
          super
        end
      end

      def self.define_attr(attrs)
        attrs.keys.each do |attr|
          add_method_to_get(attr)
          add_method_to_set(attr)
        end
      end

      def self.add_method_to_get(attr)
        define_method attr do
          self[attr.to_s]
        end
      end

      def self.add_method_to_set(attr)
        define_method "#{attr}=" do |arg|
          self[attr.to_s] = arg
        end
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

      def self.create(values)
        values.delete :id
        keys = schema.keys - ['id']
        vals = keys.map do |key|
          values[key.to_sym] ? to_sql(values[key.to_sym]) : "null"
        end

        DB.execute <<-SQL
          INSERT INTO #{table} (#{keys.join ","})
          VALUES (#{vals.join ","});
        SQL

        data = Hash[keys.zip values.values]
        sql = "SELECT last_insert_rowid();"
        data["id"] = DB.execute(sql)[0][0]
        self.new data

        # data = Hash[keys.zip vals]
        # self.new data
      end

      def self.count
        DB.execute(<<-SQL)[0][0]
          SELECT COUNT(*) FROM #{table}
        SQL
      end

      def self.table
        table_name = Mavericks.to_underscore name
        Mavericks.to_plural table_name
      end

      def self.schema
        return @schema if @schema
        @schema = {}

        DB.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end
        @schema
      end

      def self.find(id)
        row = DB.execute <<-SQL
          select #{schema.keys.join ","} from #{table}
          where id = #{id};
        SQL

        data = Hash[schema.keys.zip row[0]]
        self.new data
      end

      def self.all
        row = DB.execute <<-SQL
          select #{schema.keys.join ","} from #{table}
        SQL

        row.map do |attr|
          data = Hash[schema.keys.zip attr]
          self.new data
        end
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save!
        unless @hash["id"]
          self.class.create(@hash)
          return true
        end

        fields = @hash.map { |key, value| "#{key}=#{self.class.to_sql(value)}" }.join ","

        DB.execute <<-SQL
          UPDATE #{self.class.table}
          SET #{fields}
          WHERE id = #{@hash["id"]}
        SQL

        true
      end

      def save
        self.save! rescue false
      end
    end
  end
end
