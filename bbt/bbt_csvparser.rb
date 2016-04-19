require "csv"
require "ostruct"
require "pp"

class BBT_CsvParser
  def initialize(input_file)
    @xacts = [] 
    keys = []
    first_line_read = false
    CSV.foreach(input_file) do |row|
      if row.empty?
        next
      elsif !first_line_read
        keys = row
        first_line_read = true
      else
        xact = OpenStruct.new
        i = 0
        throw "Invalid size of row" unless row.size == keys.size
        keys.each do |k|
          k = k.downcase.gsub(/ +/, '_').to_sym
          row[i] = "" if row[i].nil?
          if m = row[i].match(/^\$([\d.]+)/)
            value = m[1].to_f
          elsif m = row[i].match(/^\(\$([\d.]+)\)/)
            value = -1 * m[1].to_f
          else
            value = row[i]
          end
          xact.send("#{k}=", value)
          i += 1
        end
        xact.category = categorize(xact.description)
        @xacts << xact
      end
    end
    @xacts.sort! {|x, y| x.category <=> y.category}
  end
  
  def categorize(msg)
    return "Rent" if msg =~ /INCOMING WIRE TRANSFER/
    return "CheqDeposit" if msg =~ /CHECK DEPOSIT/
    return "Mortgage" if msg =~ / ACH BB&T LOAN PAYMENT/
    return "BankCharge" if msg =~ /SERVICE CHARGES/
    return "HOACharges" if msg =~ /ONLINE PMT/
    return "CreditCard" if msg =~ /CHECK CARD/
    return "SecurityDeposit" if msg =~ /CHECK\s+#96/
    return "Maintenance" if msg =~ /CHECK\s+#95/
    return msg
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
