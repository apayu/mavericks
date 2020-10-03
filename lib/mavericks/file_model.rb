require "multi_json"
require 'byebug'

module Mavericks
  module Model
    class FileModel
      def initialize(file)
        @file = file
        basename = File.split(file)[-1]
        @id = File.basename(basename, ".json").to_i

        obj = File.read(file)
        @hash = MultiJson.load(obj)
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def self.find(id)
        begin
         FileModel.new("db/tasks/#{id}.json")
        rescue
         return nil
        end
      end

      def self.all
        files = Dir['db/tasks/*.json']
        files.map { |f| FileModel.new f}
      end

      def self.create(attrs)
        hash = {}
        hash[:title] = attrs[:title] || ""
        hash[:content] = attrs[:content] || ""

        files = Dir["db/tasks/*.json"]
        id = files.map { |f| f.split('/')[-1].gsub('.json','').to_i }.max + 1

         File.open("db/tasks/#{id}.json", "w") do |f|
           f.write <<-TEMPLATE
              {
               "title": "#{hash[:title]}",
               "content": "#{hash[:content]}"
              }
           TEMPLATE
         end

         FileModel.new "db/tasks/#{id}.json"
      end
    end
  end
end
