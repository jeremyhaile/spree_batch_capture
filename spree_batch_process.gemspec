Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_batch_process'
  s.version     = '0.0.1'
  s.summary     = 'Adds batch processing to Spree'
  s.description = 'Adds batch processing to Spree. Includes batch capture and batch export of orders.'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Mike Farmer'
  s.email             = ''
  s.homepage          = 'http://vitrue.com'
  s.rubyforge_project = ''

  s.files        = Dir['CHANGELOG', 'README', 'MIT-LICENSE', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*', 'public/**/*']
  s.require_path = 'lib'
   
  s.requirements << 'none'

  s.add_dependency('spree_core', '>= 0.60.4')
  s.add_dependency('resque', '~> 1.19.0')
end
