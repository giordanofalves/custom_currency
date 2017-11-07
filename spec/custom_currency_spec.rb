require 'spec_helper'

describe Money::Bank::CustomCurrency do
  let(:bank) { described_class.new }

  describe '#get_rate' do
    it 'should return correct rate' do
      expect(bank.get_rate('USD', 'USD')).to eq(1.0)
    end
  end
end
