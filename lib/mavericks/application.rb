module Mavericks
  class Error < StandardError; end

  class Application
    def default_middleware_stack
      Rack::Builder.new
    end

    def app
      @app ||= begin
        stack = default_middleware_stack
        stack.run routes
        stack.to_app
      end
    end

    def routes
      @routes ||= ActionDispatch::Routing::RouteSet.new
    end

    def call(env)
      app.call(env)
    end

    def self.inherited(klass)
      super
      @instance = klass.new
    end

    def self.instance
      @instance
    end

    def initialize!
      config_environment_path = caller.first
      @root = Pathname.new(File.expand_path("../..", config_environment_path))

      raw = @root.join('config/database.yml').read
      database_config = YAML.safe_load(raw)
      database_adapter = database_config['default']['adapter']
      database_name = database_config[Mavericks.env]['database']
      ActiveRecord::Base.establish_connection(database_adapter: database_adapter, database_name: database_name)
      ActiveSupport::Dependencies.autoload_paths = Dir["#{@root}/app/*"]

      load @root.join('config/routes.rb')
    end

    def root
      @root
    end
  end
end
