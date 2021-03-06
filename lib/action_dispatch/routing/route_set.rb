module ActionDispatch
  module Routing
    class Route
      attr_accessor :method, :path, :controller, :action, :name

      def initialize(method, path, controller, action, name)
        @method = method
        @path = path
        @controller = controller
        @action = action
        @name = name
      end

      def match?(request)
        request.request_method == method && request.path_info == path
      end

      def controller_class
        "#{controller.classify}Controller".constantize
      end

      def dispatch(request)
        controller = controller_class.new
        controller.request = request
        controller.response = Rack::Response.new
        controller.process(action)
        controller.response.finish
      end
    end

    class RouteSet
      def initialize
        @routes = []
      end

      def add_route(*args)
        route = Route.new(*args)
        @routes << route
        route
      end

      def find_route(request)
        @routes.detect { |route| route.match?(request) }
      end

      def draw(&block)
        mapper = Mapper.new(self)
        mapper.instance_eval(&block)
      end

      def call(env)
        request = Rack::Request.new(env)
        if route = find_route(request)
          route.dispatch(request)
        else
          [404, {'Content-Type' => 'text/plain'}, ['Not found page']]
        end
      end
    end
  end
end
