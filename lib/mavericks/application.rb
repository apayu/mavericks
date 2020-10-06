module Mavericks
  class Error < StandardError; end

  class Application
    def call(env)
      return favicon if env["PATH_INFO"] == '/favicon.ico'
      return index(env) if env["PATH_INFO"] == '/'

      begin
        klass, act =  get_controller_and_action(env)
        controller = klass.new(env)

        controller.send(act)
        default_render(controller, act) unless controller.content
        controller.render_layout

        if controller.get_response
          controller.get_response.to_a
        else
          [500, {'Content-Type' => 'text/html'},
           ['server error!!']]
        end

      rescue
        [404, {'Content-Type' => 'text/html'},
         ['This is a 404 page!!']]
      end
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
    end

    def root
      @root
    end

    private

    def default_render(controller, act)
      controller.render(act)
    end

    def index(env)
      begin
        home_klass = Object.const_get('HomeController')
        controller = home_klass.new(env)
        text = controller.send(:index)
        [200, {'Content-Type' => 'text/html'}, [text]]
      rescue NameError
        [200, {'Content-Type' => 'text/html'}, ['This is a index page']]
      end
    end

    def favicon
      return [404, {'Content-Type' => 'text/html'}, []]
    end
  end
end
