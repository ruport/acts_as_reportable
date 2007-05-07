module Acts
  
  module Reportable
    
    class View
      def initialize(action_view)
        @action_view = action_view
      end
      
      def render(template, local_assigns)
        @action_view.controller.headers['Content-Type'] ||= 'application/pdf'
        
        assigns = @action_view.assigns.dup
        assigns.merge!(local_assigns)
        
        result = TemplateRenderer.render_pdf(:assigns => assigns,
          :template => template)
        
        @action_view.controller.send(:send_data, result,
          :type => 'application/pdf',
          :disposition => 'inline')
      end
    end
    
  end
  
end
