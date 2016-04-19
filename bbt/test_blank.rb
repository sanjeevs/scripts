require 'test/unit'
require_relative 'bbt_csvparser'
class BlankTest < Test::Unit::TestCase
  def setup 
    @bbt_parser = BBT_CsvParser.new('data/blank.csv')
  end
  def test_credit_total
    assert_equal 0, @bbt_parser.total_credits
  end
  
end

