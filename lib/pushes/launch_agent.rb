class Pushes::LaunchAgent
  PLIST_NAME = 'ca.heliom.pushes.plist'
  DESTINATION = File.join(ENV['HOME'], 'Library', 'LaunchAgents')
  PLIST_PATH = File.join(DESTINATION, PLIST_NAME)
  TEMPLATE_PATH = File.join('../../..', 'files', "#{PLIST_NAME}.erb")

  def start(start_interval)
    template_file = File.expand_path(TEMPLATE_PATH, __FILE__)
    template_content = File.read(template_file)
    plist_content = ERB.new(template_content).result(binding)

    File.open(PLIST_PATH, 'w+') do |f|
      f.write(plist_content)
    end

    `launchctl load #{PLIST_PATH}`
  end

  def stop
    return unless File.exist?(PLIST_PATH)
    `launchctl unload #{PLIST_PATH}`
    FileUtils.rm(PLIST_PATH)
  end
end
