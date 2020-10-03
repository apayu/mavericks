require 'erubi'
require "mavericks/file_model"
require 'byebug'

module Mavericks
  class Controller
    include Mavericks::Model

    attr_reader :env, :content

    def initialize(env)
      @env = env
      @content = nil
    end

    def response(text, status = 200, headers = {})
      raise "Already responded!" if @response
      @response = Rack::Response.new(text, status, headers)
    end

    def get_response
      @response
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params
    end

    def render_layout
      layout = File.read "app/views/layouts/application.html.erb"
      text = eval(Erubi::Engine.new(layout).src)
      response(text)
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
      Mavericks.to_underscore klass
    end

    def link_to(name = nil, url = nil)
      "<a href=\"#{url}\">#{name}</a>"
    end
  end
end
