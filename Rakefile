require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'
require 'spec/rake/spectask'

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts << "-c"
end

desc 'Generate documentation for the Red Vector gem.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Red Vector - Vector Space Model Toolset'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Generate gem'
spec = Gem::Specification.new do |s|
  s.name = 'redvector'
  s.version = '0.2.2'
  s.summary = <<-EOF
   A ruby library for VSM based operations -- searching, tagging, etc.
  EOF
  s.description = <<-EOF
   A ruby library for VSM based operations -- searching, tagging, etc.
  EOF
  s.require_path = 'lib'
  s.autorequire = 'redvector'
  s.has_rdoc = true
  s.files = PKG_FILES
  s.add_dependency('stemmer', '>= 0.2.0')
  s.add_dependency('stopwords', '>= 0.0.1')
  s.add_dependency('machinst', '>= 1.0.6')
  s.author = "ENDAX, LLC"
  s.email = "john@endax.com"
  s.homepage = "http://endax.github.com/"
end