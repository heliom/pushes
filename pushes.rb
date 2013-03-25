require 'json'
require 'octokit'
require 'awesome_print'
require 'terminal-notifier'
require 'highline/import'

# Constants
STORAGE_FILE = "#{ENV['HOME']}/.pushes_storage"
CONFIG_FILE  = "#{ENV['HOME']}/.pushesrc"

def create_config_file
  github_login = ask 'What is your GitHub username? '
  authorizations = `curl -u '#{github_login}' -d '{"scopes":["repo"],"note":"Pushes"}' https://api.github.com/authorizations`
  github_token = JSON.parse(authorizations)['token']

  raise StandardError, 'You most likely typed a bad password, please try again' unless github_token

  content = "LOGIN=#{github_login}\nTOKEN=#{github_token}\n"
  File.open(CONFIG_FILE, 'w') do |file|
    file.write(content)
  end

  content
end

config = File.read(CONFIG_FILE) rescue create_config_file
GITHUB_LOGIN = config.match(/login\s*=\s*(\w+)/i)[1]
GITHUB_TOKEN = config.match(/token\s*=\s*(\w+)/i)[1]

# GitHub API
class Octokit::Client
  def received_push_events(user)
    received_events(user).select { |e| e.type == 'PushEvent' }
  end
end

GitHub = Octokit::Client.new(login: GITHUB_LOGIN, oauth_token: GITHUB_TOKEN)

# Utilities
def initiated?
  File.exist? STORAGE_FILE
end

def first_run?
  !initiated?
end

def initiate!
  File.open(STORAGE_FILE, 'w') {}
end

def push_events
  @push_events ||= GitHub.received_push_events(GITHUB_LOGIN)
end

def store_push_events!
  @stored_push_events = push_events.map(&:id)

  File.open(STORAGE_FILE, 'w') do |file|
    file.write @stored_push_events.join("\n") + "\n"
  end
end

def stored_push_events
  @stored_push_events ||= File.read(STORAGE_FILE).split("\n")
end

def notify_push_events!
  push_events.each do |event|
    next if stored_push_events.include? event.id

    user = event.actor.login
    branch = event.payload.ref.match(/[^\/]+$/)

    repo = event.repo
    commits = event.payload.commits

    if commits.size == 1
      url = "https://github.com/#{repo.name}/commit/#{commits.first.sha}"
    else
      parent_commit_sha = GitHub.commit(repo.name, commits.first.sha).parents.first.sha
      url = "https://github.com/#{repo.name}/compare/#{parent_commit_sha[0..9]}...#{commits.last.sha[0..9]}"
    end

    title = repo.name
    commits_text = "commit#{'s' if commits.size > 1}"
    message = "#{user} pushed #{commits.size} #{commits_text} to #{branch}"

    TerminalNotifier.notify(message, title: title, open: url)
  end
end

# Flow
if first_run?
  initiate!
  store_push_events!
else
  notify_push_events!
  store_push_events!
end
