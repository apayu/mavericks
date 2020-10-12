module ActionController
  class Metal
    attr_accessor :content, :request, :response

    def initialize
      # @env = env
      @content = nil
    end

    def process(action)
      send action
    end

    def params
      request.params
    end

    def default_render(action)
      render(action)
    end

    def render_layout
      layout = File.read "app/views/layouts/application.html.erb"
      text = eval(Erubi::Engine.new(layout).src)
      response.write text
    end

    def content
      @content
    end

    def render(view_name)
      filename = File.join "app", "views", controller_name, "#{view_name}.html.erb"
      template = File.read filename

      @content =  eval(Erubi::Engine.new(template).src)
    end

    def controller_name
      klass = self.class
      klass = klass.to_s.gsub /Controller$/, ""
      klass.to_underscore
    end

    def link_to(name = nil, url = nil)
      "<a href=\"#{url}\">#{name}</a>"
    end
  end
end
