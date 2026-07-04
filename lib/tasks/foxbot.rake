namespace :foxbot do
  desc "Run the Foxbot"
  task :run do
    require_relative '../../app/services/foxess_service'
    require_relative '../../app/services/foxbot_service'

    client = FoxessService.new
    foxbot = FoxbotService.new(foxess_service: client)
    foxbot.run
  end

  desc "Offboard"
  task :offboard do
    require_relative '../../app/services/foxess_service'
    require_relative '../../app/services/foxbot_service'

    client = FoxessService.new
    client.offboard
  end

  desc "Run the Foxbot daemon"
  task :run_daemon do
    require_relative '../../app/services/foxess_service'
    require_relative '../../app/services/foxbot_service'

    client = FoxessService.new
    foxbot = FoxbotService.new(foxess_service: client)

    Thread.new do
      loop do
        begin
          puts "Listening..."
          TelegramService.handle_updates
        rescue => e
          puts "Error: #{e.message}"
        end
      end
    end

    loop do
      begin
        puts "Running Foxbot at #{Time.now}..."
        foxbot.run
      rescue => e
        puts "Error: #{e.message}"
      end

      sleep 5 * 60
    end
  end

  desc 'Test telegram'
  task :test_telegram do
    require_relative '../../app/services/telegram_service'

    loop do
      puts "Listening..."

      # TelegramService.handle_updates

      exit
    end

  end

  desc "Reset the schedule to defaults"
  task :reset_schedule do
    require_relative '../../app/services/foxess_service'

    client = FoxessService.new
    client.set_schedule
  end
end
