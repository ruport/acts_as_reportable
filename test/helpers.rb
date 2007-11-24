require "test/unit"
begin; require "rubygems"; rescue LoadError; nil; end
require "ruport"
require "spec-unit"

class Test::Unit::TestCase
  include SpecUnit
end
