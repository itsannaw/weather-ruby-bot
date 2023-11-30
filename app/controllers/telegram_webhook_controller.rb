class TelegramWebhookController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, only: :webhook


  def webhook
    message = params['message']

    if message
      begin
        response_text = process_message(message)
        bot.api.send_message(chat_id: message['chat']['id'], text: response_text)
      rescue Telegram::Bot::Exceptions::ResponseError => e
        Rails.logger.error("Telegram API Response Error: #{e.message}")
      end
    end

    head :no_content
  end

  private

  def bot
    Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
  end

  def get_weather(city)
    api_key = ENV['OPENWEATHERMAP_API_KEY']
    units = 'metric'

    response = HTTParty.get("http://api.openweathermap.org/data/2.5/weather?q=#{city}&units=#{units}&appid=#{api_key}")

    if response.code == 200
      weather_data = JSON.parse(response.body)
      temperature = weather_data['main']['temp']
      description = weather_data['weather'][0]['description']
      return "The temperature in #{city}: #{temperature}°C, #{description}"
    else
      return 'Failed to retrieve weather data'
    end
  end

  def process_message(message)
    if message['text']
      case message['text'].downcase
      when '/start'
        return 'Hi. Enter the name of the city to get the weather!'
      else
        city = message['text']
        return get_weather(city)
      end
    end
  end


end
