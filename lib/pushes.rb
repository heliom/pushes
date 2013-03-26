require 'octokit'

require 'pushes/config'
require 'pushes/version'

module Pushes
  def self.run(argv)
    if first_run?
      config.initiate
      store_push_events
    else
      notify_push_events
      store_push_events
    end
  end

  def self.first_run?
    !config.initiated?
  end

  def self.push_events
    @push_events ||= received_push_events
  end

  def self.store_push_events
    @stored_push_events = push_events.map(&:id)
    config.store(@stored_push_events)
  end

  def self.stored_push_events
    @stored_push_events ||= config.storage
  end

  def self.received_push_events
    github.received_events(config.login).select { |e| e.type == 'PushEvent' }
  end

  def self.notify_push_events
    push_events.each do |event|
      next if stored_push_events.include? event.id

      user = event.actor.login
      branch = event.payload.ref.match(/[^\/]+$/)

      repo = event.repo
      commits = event.payload.commits

      if commits.size == 1
        url = "https://github.com/#{repo.name}/commit/#{commits.first.sha}"
      else
        parent_commit_sha = github.commit(repo.name, commits.first.sha).parents.first.sha
        url = "https://github.com/#{repo.name}/compare/#{parent_commit_sha[0..9]}...#{commits.last.sha[0..9]}"
      end

      title = repo.name
      commits_text = "commit#{'s' if commits.size > 1}"
      message = "#{user} pushed #{commits.size} #{commits_text} to #{branch}"

      TerminalNotifier.notify(message, title: title, open: url)
    end
  end

  def self.config
    @config ||= Config.new
  end

  def self.github
    @github ||= Octokit::Client.new(login: config.login, oauth_token: config.token)
  end
end
