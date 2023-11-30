class TelegramWebhookController < ApplicationController
    protect_from_forgery with: :null_session

    def webhook
      response = "Погода сейчас: #{get_weather}"
      bot.api.send_message(chat_id: params['message']['chat']['id'], text: response)
    end

    private

    def bot
      Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
    end

    def get_weather
      # Ваш код для получения данных о погоде
    end
  end
