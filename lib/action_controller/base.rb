module ActionController
  class Base < Metal
    include Callbacks
    include ActionView::Rendering
    include ImplicitRender
  end
end
