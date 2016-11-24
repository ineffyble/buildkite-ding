require 'ptools' # Used to find appropriate play command
# require 'win32-file' # Required for File.which on Windows
require 'buildkit'
require 'json'
require 'date'

CONFIG_PATH = "#{ENV['HOME']}/.bkdingrc".freeze
DATA_PATH = File.join(File.dirname(File.expand_path(__FILE__)), '../data')

BUILD_EVENTS = {
  'running' => {
    'action' => 'ding once!',
    'sound' => 'w_1'
  },
  'passed' => {
    'action' => 'ding twice!!',
    'sound' => 'w_2'
  },
  'failed' => {
    'action' => 'lots of dings!!!!!',
    'sound' => 'w_many'
  }
}.freeze

# Goes 'ding' when your builds fail. or pass. or start.
#
# To run without daemon/binary:
# BuildkiteDing.run
#
class BuildkiteDing
  def self.run # Alternative to starting with the bin
    BuildkiteDing.load_config
    BuildkiteDing.run_client
  end

  def self.load_config
    if File.exist?(CONFIG_PATH)
      @config = JSON.parse(File.read(CONFIG_PATH), symbolize_names: true)
      puts "Loaded configuration from #{CONFIG_PATH}"
    else
      BuildkiteDing.generate_config
    end
  end

  def self.generate_config
    @config = {}
    puts "No .bkdingrc file detected in #{CONFIG_PATH}
          Please provide a Buildkite API access token with read_builds scope:
          ( Generate at https://buildkite.com/user/api-access-tokens/new )"
    @config[:buildkite_api_token] = STDIN.gets.chomp
    File.open(CONFIG_PATH, 'w') do |f|
      f.write(JSON.pretty_generate(@config))
    end
  end

  def self.run_client
    @client = Buildkit.new(token: @config[:buildkite_api_token])
    @tracked_builds = {} # Simple hash tracking build id and state
    @last_check = Time.now.utc
    loop do
      puts 'Checking builds...'
      BuildkiteDing.check_builds
      @last_check = Time.now.utc
      sleep(5)
    end
  end

  def self.check_builds
    new_builds = @client.builds(created_from: @last_check.iso8601) +
                 @client.builds(finished_from: @last_check.iso8601)
    new_builds.each do |b|
      if @tracked_builds.key?(b['id']) && @tracked_builds[b['id']] == b['state']
        next
      end
      BuildkiteDing.interogate_build(b)
    end
  end

  def self.interogate_build(build)
    puts "Build is new or updated: #{build['message']}"
    @tracked_builds[build['id']] = build['state']
    return unless BUILD_EVENTS.key? build['state']
    print "Build #{build['state']} - "
    BuildkiteDing.take_action(BUILD_EVENTS[build['state']])
  end

  def self.take_action(action)
    puts action['action']
    BuildkiteDing.play_sound(action['sound'])
  end

  def self.play_sound(sound) # Sound name standard is class_numberofdings
    puts 'Finding play command...'
    if File.which('afplay') # Included in MacOS
      puts 'Found afplay (this is probably MacOS)'
      puts "Playing #{DATA_PATH}/#{sound}.mp3"
      system "afplay #{DATA_PATH}/#{sound}.mp3"
    elsif File.which('play') # Sox package?
      puts 'Found play (this is presumably Linux)'
      system "play #{DATA_PATH}/#{sound}.mp3"
    end
  end
end
