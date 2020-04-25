require "bigdecimal"

module FineAnts
  module Adapters
    class SimpleBancorp
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://www.simple.com"
        click_link "Log In"

        fill_in "username", with: @user
        fill_in "passphrase", with: @password
        click_button "Sign in"
        verify_login!
      end

      def download
        balance = find(".sts-available").find("b").text
        available_balance = find("#sts-flag").text.strip
        user_name = find(".masthead-username").text

        [
          {
            adapter: :simple_bancorp,
            user: @user,
            id: user_name.to_s,
            name: user_name.to_s,
            amount: parse_currency(balance),
            available_amount: parse_currency(available_balance)
          }
        ].tap { logout! }
      end

      private

      def logout!
        visit "https://bank.simple.com/signout"
      end

      def parse_currency(currency_string)
        BigDecimal(currency_string.match(/\$?(.*)$/)[1].delete(","))
      end

      def verify_login!
        find("h2", text: "Safe-to-Spend")
      rescue Capybara::ElementNotFound
        raise FineAnts::LoginFailedError.new
      end
    end
  end
end
