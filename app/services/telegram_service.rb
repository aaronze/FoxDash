# frozen_string_literal: true

require 'telegram/bot'

class TelegramService
  TOKEN = '8998860697:AAG-JjSjX90juOoRx4Ej0nttFuDk8MQO7F8'
  CHAT_ID = '-1004314616732'

  DIRECTIVE_SKIP_SELL = 'skip_sell'
  DIRECTIVE_SKIP_BUY = 'skip_buy'

  def self.send_message(message, silent: true)
    Telegram::Bot::Client.run(TOKEN) do |bot|
      bot.api.send_message(chat_id: CHAT_ID, text: message, disable_notification: silent)
    end
  rescue StandardError => e
    puts "Failed to send message: #{e.message}"
  end

  def self.handle_updates
    Telegram::Bot::Client.run(TOKEN) do |bot|
      bot.listen do |message|
        next unless message.is_a?(Telegram::Bot::Types::Message)

        puts "Received message: #{message.text}"
        case message.text
        when '/start'
          send_message("Hello!")
        when '/help'
          send_message("Available commands: /skip_sell, /skip_buy, /clear")
        when '/skip_sell'
          save_directive(DIRECTIVE_SKIP_SELL)
          send_message("Will change schedule to not sell today")
        when '/skip_buy'
          save_directive(DIRECTIVE_SKIP_BUY)
          send_message("Will change schedule to not buy today")
        when '/clear'
          clear_directives
          send_message("Cleared directives")
        else
          send_message("I don't understand that command. UwU")
        end
      end
    end
  rescue StandardError => e
    puts "Failed to handle updates: #{e.message}"
  end

  def self.save_directive(directive)
    date = Date.today.to_s

    if !File.exist?('directives.txt') || File.readlines('directives.txt').map(&:chomp).first != date
      File.open('directives.txt', 'w') do |file|
        file.puts(date)
      end
    end

    File.open('directives.txt', 'a') do |file|
      file.puts(directive)
    end
  end

  def self.clear_directives
    date = Date.today.to_s

    File.open('directives.txt', 'w') do |file|
      file.puts(date)
    end
  end

  def self.directives
    return [] unless File.exist?('directives.txt')

    directives = File.readlines('directives.txt').map(&:chomp)
    return [] if directives.first != Date.today.to_s

    directives[1..-1]
  end
end
