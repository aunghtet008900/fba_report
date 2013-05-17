module BookCultureLib

  class Report

    def initialize( interval, start_date, end_date, skus )
      @skus = skus
      case interval
      when :daily
        @the_report = generate_daily_report(start_date, end_date)
      when :weekly
        @the_report = generate_weekly_report(start_date, end_date)
      when :monthly
        @the_report = generate_monthly_report(start_date, end_date)
      when :yearly
        @the_report = generate_yearly_report(start_date, end_date)
      #else
      #  puts "This option for options[:interval] shouldn't happen. Ever."
      #  exit
      end
    end


    def to_s
      @the_report
    end


    #TODO: Pass it the activerecord thingy it needs, instead of hardcoding it.
    def generate_daily_report(start_date, end_date)

      # Will be used for generating a table:
      fba_skus = @skus || BookCultureLib::AmazonOrder.uniq.pluck(:sku)
      #TODO: Might be better to do a .where with the start and end of range, then do a pluck
      #       from that, so we're only listing fba skus that exist in the desired range.
      #(Make this some sort of configurable option!)

      report_data = BookCultureLib::ReportData.new( Time.now.to_s, fba_skus )

      # PSEUDOCODE:
      #
      #   days.each
      #     orders.each
      #       put the item into a blank items hash
      #       put the hash into an array
      #     end
      #   end
      #Generate the data structure from queries
      (start_date..end_date).each do |day|
        start_of_day = day
        end_of_day = day + 1
        temp_hash = { date: day, quantities: Hash.new(0) }

        #TODO: Is there any way to make this not horribly ugly??
        BookCultureLib::AmazonOrder.where("purchase_date >= :start_date AND purchase_date < :end_date",
                                          {:start_date => start_of_day, :end_date => end_of_day}).each do |order|
          temp_hash[:quantities][order.sku] += order.quantity
        end

        report_data << temp_hash
      end

      #TODO: Move the template path stuff to the config?
      template = IO.read(File.expand_path('../../../views/report_template.html.erb',
                                          __FILE__))
      rhtml = ERB.new(template, 0, '>')
      # The 0 does nothing special, the '>' eliminates pointless newlines

      return rhtml.result(report_data.get_binding)
    end


    def generate_weekly_report(start_date, end_date)
      raise "Weekly reporting not supported yet"
    end


    #TODO: Abstract this more... the _monthly, _weekly, etc stuff should just
    #      generate the array of days to feed to the rest of this, which will
    #      be in a separate universal method
    def generate_monthly_report(start_date, end_date)
      fba_skus = @skus || BookCultureLib::AmazonOrder.uniq.pluck(:sku)

      report_data = BookCultureLib::ReportData.new( Time.now.to_s, fba_skus )

      dstart = start_date.beginning_of_month
      dend = end_date.beginning_of_month

      array_of_months = (dstart..dend).select {|d| d.day == 1}

      array_of_months.each do |day|
        start_of_month = day
        start_of_next_month = day >> 1
        temp_hash = { date: day, quantities: Hash.new(0) }

        BookCultureLib::AmazonOrder.where("purchase_date >= :start_date AND purchase_date < :end_date",
                                          {:start_date => start_of_month, :end_date => start_of_next_month}).each do |order|
          temp_hash[:quantities][order.sku] += order.quantity
        end

        report_data << temp_hash
      end

      template = IO.read(File.expand_path('../../../views/report_template.html.erb',
                                          __FILE__))
      rhtml = ERB.new(template, 0, '>')
      # The 0 does nothing special, the '>' eliminates pointless newlines

      return rhtml.result(report_data.get_binding)
    end


    def generate_yearly_report(start_date, end_date)
      raise "Yearly reporting not supported yet"
    end

  end

end
