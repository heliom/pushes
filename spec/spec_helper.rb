PushEvent = Struct.new(:id)

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:all) do
    return if ENV['CI']

    @original_home = ENV['HOME']
    fake_home = File.expand_path('./tmp/fake_home')
    ENV['HOME'] = fake_home

    require 'pushes'
  end

  config.after(:all) do
    return if ENV['CI']

    ENV['HOME'] = @original_home
  end
end
