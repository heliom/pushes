require 'spec_helper'

describe Pushes do
  before :all do
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new

    FileUtils.rm_rf(Pushes::Config::PUSHES_FOLDER)
  end

  after :all do
    $stderr = @old_stderr
    $stdout = @old_stdout

    FileUtils.rm_rf(Pushes::Config::PUSHES_FOLDER)
  end

  before :each do
    @login = 'foozledoo'
    @token = '12345'
    @events = [PushEvent.new('1234'), PushEvent.new('2345'), PushEvent.new('3456'), PushEvent.new('4567'), PushEvent.new('5678')]
  end

  context 'on first run' do
    it 'prompts for GitHub credentials' do
      HighLine.any_instance.should_receive(:ask).with('What is your GitHub username? ').and_return(@login)
      Pushes::Config.any_instance.should_receive(:get_github_token).with(@login).and_return(@token)
      Pushes.should_receive(:push_events).and_return(@events)
      Pushes.should_receive(:notify_initiated)
      Pushes.run %w()

      expect(File.read(Pushes::Config::STORAGE_FILE)).to eq("1234\n2345\n3456\n4567\n5678\n")
      expect(File.read(Pushes::Config::CONFIG_FILE)).to eq("LOGIN=foozledoo\nTOKEN=12345\n")
    end
  end
end
