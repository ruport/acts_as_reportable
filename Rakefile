require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"

AAR_VERSION = "1.1.1"

begin
  require "rubygems"
rescue LoadError
  nil
end

task :default => [:test]

Rake::TestTask.new do |test|
  test.libs << "test"
  test.test_files = Dir[ "test/*_test.rb" ]
  test.verbose = true
end

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

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "lib/" )
  rdoc.main     = "README"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "acts_as_reportable Documentation"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = Dir[ "test/*_test.rb" ]
  end
rescue LoadError
  nil
end
