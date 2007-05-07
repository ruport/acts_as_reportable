require "ruport"
require "acts_as_reportable_view"
require "template_runner"

ActionView::Base::register_template_handler :report, Acts::Reportable::View

ActionController::Base.exempt_from_layout :report

Mime::Type.register "application/pdf", :pdf
