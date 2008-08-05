AAR_VERSION = "1.1.1"

spec = Gem::Specification.new do |spec|
  spec.name = "acts_as_reportable"
  spec.version = AAR_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "ActiveRecord support for Ruby Reports"
  spec.files =  Dir.glob("{lib,test}/**/**/*") +
                      ["Rakefile"]
  spec.require_path = "lib"
  
  spec.test_files = Dir[ "test/*_test.rb" ]
  spec.has_rdoc = true
  #spec.extra_rdoc_files = %w{README LICENSE AUTHORS}
  spec.rdoc_options << '--title' << 'Ruport Documentation'
  spec.add_dependency('ruport', '>= 1.6.0')
  spec.author = "Michael Milner"
  spec.email = "mikem836@gmail.com"
  spec.rubyforge_project = "ruport"
  spec.homepage = "http://rubyreports.org"
  spec.description = <<END_DESC
  acts_as_reportable provides ActiveRecord support for Ruby Reports
END_DESC
end