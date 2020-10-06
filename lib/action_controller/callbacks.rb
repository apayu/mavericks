module ActionController
  module Callbacks
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def before_action(method, options={})
        # TODO
      end
    end
  end
end
