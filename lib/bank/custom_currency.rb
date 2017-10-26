require 'money'
require 'money/rates_store/data_support'
require 'open-uri'

class Money
  module Bank
    class CustomCurrency < Money::Bank::VariableExchange
      ECB_RATES_URL     = 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'.freeze
      GOOGLE_RATES_URL  = 'finance.google.com'.freeze
      GOOGLE_RATES_PATH = '/finance/converter'.freeze
      YAHOO_RATES_URL   = 'download.finance.yahoo.com'.freeze
      YAHOO_RATES_PATH  = '/d/quotes.csv'.freeze

      def initialize(*)
        super
        @store.extend Money::RatesStore::DataSupport
        @currency_string = nil
      end

      def get_rate(from, to)
        from_iso_code = from.is_a?(Money::Currency) ? from.iso_code : from.to_s
        to_iso_code   = to.is_a?(Money::Currency)   ? to.iso_code   : to.to_s

        g_rate   = google_rate(from_iso_code, to_iso_code)
        y_rate   = yahoo_rate(from_iso_code, to_iso_code)
        # We don't use euc_rate, I just leave this here
        # because someday we can change to
        # euc_rate = eu_central_rate(from, to)
        g_rate ? g_rate : y_rate
      end

      def save_rates(cache, url = ECB_RATES_URL)
        raise InvalidCache unless cache
        File.open(cache, 'w') do |file|
          io = open(url)
          io.each_line { |line| file.puts line }
        end
      end

      def update_rates(cache, url = ECB_RATES_URL)
        rates_source = cache.nil? ? url : cache
        rates = Nokogiri::XML(open(rates_source)).
                  xpath('gesmes:Envelope/xmlns:Cube/xmlns:Cube//xmlns:Cube')

        store.transaction true do
          rates.each do |exchange_rate|
            rate = BigDecimal(exchange_rate.attribute('rate').value)
            currency = exchange_rate.attribute('currency').value
            set_rate('EUR', currency, rate)
          end
          set_rate('EUR', 'EUR', 1)
        end
      end

      private

      def google_rate(from, to)
        query = "a=1&from=#{from}&to=#{to}"
        uri   = build_uri(GOOGLE_RATES_URL, GOOGLE_RATES_PATH, query)
        rate  = extract_rate(uri.read)
        rate  = (1 / extract_rate(uri.read)) if rate < 0.1

        rate
      rescue => ex
        Logger.new(STDOUT).error("[CurrencyExchange][GOOGLE] #{ex.message}")
        return nil
      end

      def yahoo_rate(from, to)
        query = "s=#{from}#{to}=X&f=l1"
        uri   = build_uri(YAHOO_RATES_URL, YAHOO_RATES_PATH, query)

        uri.read.to_d
      rescue => ex
        Logger.new(STDOUT).error("[CurrencyExchange][YAHOO] #{ex.message}")
        return nil
      end

      def eu_central_rate(from, to)
        from_base_rate = store.get_rate('EUR', from)
        to_base_rate   = store.get_rate('EUR', to)

        to_base_rate / from_base_rate
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
