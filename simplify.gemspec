# -*- encoding: utf-8 -*-
# stub: simplify 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "simplify"
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Simplify Commerce"]
  s.date = "2014-11-17"
  s.description = "Ruby access to the Simplify Commerce API"
  s.email = "support@simplify.com"
  s.homepage = "https://www.simplify.com/commerce"
  s.licenses = ["BSD"]
  s.rubygems_version = "2.4.5"
  s.summary = "Simplify Commerce Ruby SDK"

  s.installed_by_version = "2.4.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-hmac>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<ruby-hmac>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<ruby-hmac>, [">= 0"])
  end
end
