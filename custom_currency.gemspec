Gem::Specification.new do |s|
  s.name        = 'custom_currency'
  s.version     = '0.0.1'
  s.date        = '2017-10-27'
  s.summary     = 'Custom Currency!'
  s.description = 'Extends Money::Bank::VariableExchange and gives you access to the current exchange rates of various providers'
  s.email       = 'giordanofalves@gmail.com'
  s.authors     = ['Giordano Alves']
  s.homepage    = 'https://github.com/giordanofalves/custom_currency'
  s.license     = 'MIT'
  s.files       = Dir.glob('lib/**/*')

  s.add_dependency             'money',     '~> 6.7'
  s.add_development_dependency 'rspec',     '~> 3.6'
  s.add_development_dependency 'pry',       '~> 0.10.1'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
end
