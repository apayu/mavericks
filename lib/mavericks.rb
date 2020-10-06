module Mavericks
  autoload :Application, 'mavericks/application'

  def self.application
    Application.instance
  end

  def self.root
    application.root
  end

  def self.env
    ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  end
end
