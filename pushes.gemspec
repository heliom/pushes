# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','pushes','version.rb'])

spec = Gem::Specification.new do |s|
  s.name = 'pushes'
  s.authors = ['Rafael Blais-Masson', 'Etienne Lemay']
  s.email = 'fellowship@heliom.ca'
  s.homepage = 'https://github.com/heliom/pushes'
  s.summary = 'GitHub post-commit notifs in your OS X Notification Center'

  s.version = Pushes::VERSION
  s.platform = Gem::Platform::RUBY

  s.files = %w(LICENSE.md README.md Rakefile pushes.gemspec)
  s.files += Dir.glob("lib/**/*.rb")
  s.files += Dir.glob("bin/**/*")
  s.files += Dir.glob("files/**/*")

  s.bindir = 'bin'
  s.executables << 'pushes'

  s.require_paths << 'lib'
  s.add_dependency('octokit', '~> 1.24.0')
  s.add_dependency('terminal-notifier', '~> 1.4.2')
  s.add_dependency('highline', '~> 1.6.16')
end
