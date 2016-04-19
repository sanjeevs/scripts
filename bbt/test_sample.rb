require 'test/unit'
require_relative 'bbt_csvparser'

class GenReportTest < Test::Unit::TestCase
  def setup
    @bbt_parser = BBT_CsvParser.new('data/sample.csv')
  end
  
  def test_credit_total
    assert_equal 1995 * 3.0, @bbt_parser.total_credits
  end
  
  def test_num_credits
    assert_equal 3, @bbt_parser.credit_xacts.size
  end  

  def test_num_debits
    assert_equal 6, @bbt_parser.debit_xacts.size
  end

  def test_total_debits
    assert_equal (1161.20 + 18.0 + 1161.20 + 18 + 75 + 1161.20),
                 @bbt_parser.total_debits
  end
end
