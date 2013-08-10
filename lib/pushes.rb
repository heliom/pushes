# encoding: utf-8
require 'octokit'

require 'pushes/version'
require 'pushes/config'
require 'pushes/notifier'
require 'pushes/launch_agent'

module Pushes
  DEFAULT_COMMAND = 'fetch'

  def self.run(argv)
    command = argv.first || DEFAULT_COMMAND
    args = argv - [command]

    if %w(--help -h).include?(command)
      display_help
      return 1
    end

    if %w(--version -v).include?(command)
      display_version
      return 1
    end

    begin
      send("command_#{command}", args)
    rescue ArgumentError
      send("command_#{command}")
    rescue NoMethodError
      say "error: Unknown command '#{command}'"
    end

    1
  end

  # Commands
  def self.command_fetch
    if first_run?
      config.initiate
      store_push_events
      notify_initiated
    else
      notify_push_events
      store_push_events
    end
  rescue
  end

  def self.command_start(args)
    interval = args.first.to_i
    start_interval = interval > 0 ? interval : 10

    launch_agent.start(start_interval)
    command_fetch
  end

  def self.command_stop
    launch_agent.stop
  end

  def self.command_reset
    config.clear_storage
  end

  # Utilities
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

      notifier.notify(message, title: title, open: url)
    end
  end

  def self.notify_initiated
    notifier.notify("You’re all set, just wait for new commits.\n~ Pushes", title: 'Ahoy Captain!')
  end

  def self.launch_agent
    @launch_agent ||= LaunchAgent.new
  end

  def self.notifier
    @notifier ||= Notifier.new
  end

  def self.config
    @config ||= Config.new
  end

  def self.github
    @github ||= Octokit::Client.new(login: config.login, oauth_token: config.token)
  end

  def self.display_help
    say(help_message + "\n")
  end

  def self.display_version
    say("Pushes #{Pushes::VERSION}" + "\n")
  end

  def self.help_message
    help = []
    help << 'Usage:'
    help << '  pushes COMMAND'
    help << ''
    help << 'Options:'
    help << '  -h, --help - Display help'
    help << ''
    help << 'Commands:'
    help << 'fetch            - Fetch new commits from GitHub'
    help << 'start [INTERVAL] - Start a LaunchAgent background process [INTERVAL in seconds. Default: 10]'
    help << 'stop             - Stop background process'

    help.join("\n")
  end
end
