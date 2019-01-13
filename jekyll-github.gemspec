$LOAD_PATH.unshift File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
    s.name = "jekyll-github"
    s.summary = "Jekyll plugin for Github"
    s.version = "1.0.0"
    s.authors = ["vrongmeal"]

    s.homepage = "https://github.com/vrongmeal/jekyll-github"
    s.license = "MIT"
    s.files = ["lib/jekyll-github.rb"]

    s.required_ruby_version = ">= 2.3.0"

    s.add_dependency "jekyll", "~> 3.0"
end
