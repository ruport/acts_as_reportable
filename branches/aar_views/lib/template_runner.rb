module Acts

  module Reportable

    class TemplateRenderer < Ruport::Renderer
      required_option :assigns, :template
      prepare :template
      stage :template
      finalize :template
    end
    
    module TemplateRunner
      def prepare_template
        assigns.each {|k,v| instance_variable_set("@#{k}", v) }
      end
      
      def build_template
        instance_eval(template)
      end
      
      def self.included(base)
        base.opt_reader :assigns
        base.opt_reader :template
      end
    end
    
    class TemplatePDF < Ruport::Formatter::PDF
      renders :pdf, :for => TemplateRenderer
      
      include TemplateRunner
      
      def finalize_template
        output << pdf_writer.render
      end
    end
    
  end

end
