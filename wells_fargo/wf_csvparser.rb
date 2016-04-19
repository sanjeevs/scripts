require "csv"
require "ostruct"
require "pp"

class WF_CsvParser
  def initialize(input_file)
    @xacts = [] 
    keys = []
    first_line_read = false
    CSV.foreach(input_file) do |row|
      if row.empty?
        next
      else
        xact = OpenStruct.new
        xact.date = row[0]
        xact.amount = row[1].to_f
        xact.description = row[4]
        xact.category = categorize(xact.description)
        @xacts << xact
      end
    end
    @xacts.sort! {|x, y| x.category <=> y.category}
  end
  
  def categorize(msg)
    return "Interest" if msg =~ /INTEREST PAYMENT$/
    return "Mortgage" if msg =~ /INTEREST PAYMENT CUSTOMER/
    return "Rent" if msg =~ /ATM CHECK DEPOSIT/
    return "Rent" if msg =~ /eDeposit/
    return "Landscape" if msg =~ /AWESOME CUTT/
    return "Service" if msg =~ /SERVICE FEE/
    return "Parking" if msg =~ /PAVINGINC/
    return "Mortgage" if msg =~ /PRINCIPAL PAYMENT/
    msg
  end

  def credit_xacts
    @xacts.select {|x| x.amount > 0}
  end

  def debit_xacts
    @xacts.select {|x| x.amount < 0}
  end

  def total_credits
    sum = 0.0
    @xacts.inject(0) do |sum, x| 
      sum += x.amount if x.amount > 0
      sum
    end
  end
  
  def total_debits
    sum = 0.0
    @xacts.inject(0) do |sum, x| 
      sum += x.amount if x.amount < 0 
      sum
    end * -1
  end

  def net_profit
    sum = 0.0
    @xacts.inject(0) do |sum, x| 
      sum += x.amount
    end
  end

  def balance_sheet(filename)
    File.open(filename, "w") do |fh|
      fh.puts "Date,Amount,Description"
      credit_xacts.each do |x|
        fh.puts "#{x.date},#{x.amount},#{x.category}"
      end
      debit_xacts.each do |x|
        fh.puts "#{x.date},#{x.amount},#{x.category}"
      end
    end
  end

end
