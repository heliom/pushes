require 'json'
require 'highline/import'

class Pushes::Config
  PUSHES_FOLDER = File.join(ENV['HOME'], '.pushes')
  STORAGE_FILE = File.join(PUSHES_FOLDER, 'storage')
  CONFIG_FILE = File.join(PUSHES_FOLDER, 'login')

  def initialize
    configs = File.read(CONFIG_FILE) rescue create_config_file
    configs.split("\n").each do |config|
      key, value = config.split('=')
      define_singleton_method key.downcase do
        value
      end
    end
  end

  def create_config_file
    github_config = {}
    github_config[:login] = ask 'What is your GitHub username? '
    authorizations = `curl -u '#{github_config[:login]}' -d '{"scopes":["repo"],"note":"Pushes"}' https://api.github.com/authorizations`
    github_config[:token] = JSON.parse(authorizations)['token']

    raise StandardError, 'You most likely typed an incorrect username or password, please try again.' unless github_config[:token]

    content = github_config.each_pair.map { |k, v| "#{k.upcase}=#{v}" }.join("\n")
    File.open(CONFIG_FILE, 'w') do |file|
      file.write(content)
    end

    content
  end

  def initiated?
    File.exist? STORAGE_FILE
  end

  def initiate
    File.open(STORAGE_FILE, 'w') {}
  end

  def store(push_events)
    File.open(STORAGE_FILE, 'w') do |file|
      file.write push_events.join("\n") + "\n"
    end
  end

  def storage
    File.read(STORAGE_FILE).split("\n")
  end
end
