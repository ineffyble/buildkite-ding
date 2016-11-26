Gem::Specification.new do |gem|
  gem.name        = 'buildkite-ding'
  gem.version     = '0.1.2'
  gem.executables << 'buildkite-ding'
  gem.license     = 'MIT'
  gem.summary     = 'Simple audible alerts for Buildkite build events'
  gem.description = "Ultra simple audible alerts for Buildkite build events,
                     inspired by the ambiance of Melbourne"
  gem.author      = 'Effy Elden'
  gem.email       = 'dev@effy.is'
  gem.files       = Dir.glob('data/**/*') + Dir.glob('lib/**/*')
  gem.homepage    = 'https://github.com/ineffyble/buildkite-ding'

  gem.add_runtime_dependency 'daemons'
  gem.add_runtime_dependency 'ptools'
  gem.add_runtime_dependency 'buildkit'
end
