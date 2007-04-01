require "ruport"
require "acts_as_reportable"

ActiveRecord::Base.send :include, Ruport::Reportable
