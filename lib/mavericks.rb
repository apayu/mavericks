require "mavericks/version"
require "mavericks/routing"
require "mavericks/support"
require "mavericks/dependencies"
require "mavericks/controller"
require "mavericks/file_Model"
require 'byebug'

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
