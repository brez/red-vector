Gem::Specification.new do |s| 
  s.name = "red-vector"
  s.version = "0.0.1"
  s.author = "ENDAX"
  s.email = "opensource@endax.com"
  s.homepage = "http://endax.com/opensource/"
  s.platform = Gem::Platform::RUBY
  s.summary = "TBD"
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  s.autorequire = "name"
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  #s.add_dependency("dependency", ">= 0.x.x")
end
