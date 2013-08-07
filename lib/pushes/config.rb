require 'json'
require 'fileutils'
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
    github_config[:login] = ask('What is your GitHub username? ')
    github_config[:token] = get_github_token(github_config[:login])

    raise StandardError, 'You most likely typed an incorrect username or password, please try again.' unless github_config[:token]
    mkdir_pushes

    content = github_config.each_pair.map { |k, v| "#{k.upcase}=#{v}" }.join("\n") + "\n"
    File.open(CONFIG_FILE, 'w') do |file|
      file.write(content)
    end

    content
  end

  def mkdir_pushes
    return if File.directory?(PUSHES_FOLDER)
    FileUtils.mkdir(PUSHES_FOLDER)
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

  private

  def get_github_token(github_login)
    authorizations = `curl -u '#{github_login}' -d '{"scopes":["repo"],"note":"Pushes"}' https://api.github.com/authorizations`
    JSON.parse(authorizations)['token']
  end
end
