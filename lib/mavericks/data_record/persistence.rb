module Mavericks
  module DataRecord
    module Persistence
      def initialize(attributes = {})
        self.class.set_column_to_attribute
        @attributes = attributes
        @new_record = true
      end

      def new_record?
        @new_record
      end

      def save!
        return true unless new_record?

        vals = @attributes.values.map { |value| self.class.to_sql(value) }
        self.class.connection.execute <<-SQL
          INSERT INTO #{self.class.table_name} (#{@attributes.keys.join(',')})
          VALUES (#{vals.join ","});
        SQL
        @new_record = false
      end

      def save
        self.save! rescue false
      end
    end
  end
end
