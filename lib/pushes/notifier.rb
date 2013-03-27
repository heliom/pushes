require 'terminal-notifier'

class Pushes::Notifier
  def notify(message, opts={})
    TerminalNotifier.notify(message, opts)
  end
end
