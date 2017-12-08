require 'money'
require 'open-uri'

class Money
  module Bank
    class CustomCurrency < Money::Bank::VariableExchange
      GOOGLE_RATES_URL  = 'finance.google.com'.freeze
      GOOGLE_RATES_PATH = '/finance/converter'.freeze

      attr_accessor :from, :to

      def get_rate(from_iso_code, to_iso_code)
        self.from = from_iso_code
        self.to   = to_iso_code

        google_rate
      end

      private

      def google_rate
        query = "a=1&from=#{from}&to=#{to}"
        uri   = build_uri(GOOGLE_RATES_URL, GOOGLE_RATES_PATH, query)
        rate  = extract_rate(uri.read)
        rate  = (1 / extract_rate(uri.read)) if rate < 0.1

        rate
      end

      def build_uri(url, path, query)
        URI::HTTP.build(host: url, path: path, query: query)
      end

      def extract_rate(data)
        case data
        when %r{<span class=bld>(\d+\.?\d*) [A-Z]{3}<\/span}
          BigDecimal(Regexp.last_match(1))
        when /Could not convert\./
          raise UnknownRate
        end
      end
    end
  end
end
