module Mavericks
  module Dependencies
    extend self

    attr_accessor :autoload_paths
    self.autoload_paths = []

    def search_for_file(name)
      autoload_paths.each do |path|
        file = File.join(path, "#{name}.rb")
        if File.file? file
          return file
        end
      end
      nil
    end
  end
end

class Object
  def self.const_missing(name)
    if file = Mavericks::Dependencies.search_for_file(Mavericks.to_underscore(name.to_s))
      require file.sub(/\.rb$/, '')

      const_get name
    else
      raise NameError, "Uninitialized constant #{name}"
    end
  end
end
