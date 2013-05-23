module BookCultureLib

  class Report

    def initialize( interval, start_date, end_date, skus )
      @skus = skus
      #TODO: Move this case stuff somewhere else? Handle it better? Smells weird...
      case interval
      when :daily
        @the_report = generate_daily_report(start_date, end_date)
      when :weekly
        @the_report = generate_weekly_report(start_date, end_date)
      when :monthly
        @the_report = generate_monthly_report(start_date, end_date)
      when :yearly
        @the_report = generate_yearly_report(start_date, end_date)
      else
        raise "invalid interval"
      end
    end


    # Return the report
    #
    def to_s
      @the_report
    end



    # Generate a daily report between (and including) the provided dates, by
    # calculating the periods, calling generate_report(), and returning the result.
    #
    # ==== Attributes
    #
    # * +start_date+ - a Date instance representing the start of the report
    # * +end_date+ - a Date instance representing the start of the report
    #
    def generate_daily_report(start_date, end_date)

      array_of_days = []

      (start_date..end_date).each do |day|
        start_of_day = day
        end_of_day = day + 1
        array_of_days << {:start => start_of_day, :end => end_of_day}
      end

      return generate_report(array_of_days, 'daily_report_template.html.erb')
    end


    # Generate a weekly report between (and including) the provided dates, by
    # calculating the periods, calling generate_report(), and returning the result.
    #
    # ==== Attributes
    #
    # * +start_date+ - a Date instance representing the start of the report
    # * +end_date+ - a Date instance representing the start of the report
    #
    def generate_weekly_report(start_date, end_date)
      #raise "Weekly reporting not supported yet"

      ##dstart = start_date.beginning_of_month
      ##dend = end_date.beginning_of_month

      #array_of_sundays = (start_date..end_date).to_a.select {|k| k.wday == 0}

      dstart = start_date.beginning_of_week
      dend = end_date.end_of_week

      array_of_weeks = (dstart..dend).select {|d| d.wday == 0}

      array_of_weeks.map! do |day|
        start_of_week = day
        start_of_next_week = day.next_week
        {:start => start_of_week, :end => start_of_next_week}
      end

      return generate_report(array_of_weeks, 'daily_report_template.html.erb')
    end


    # Generate a monthly report between (and including) the provided dates, by
    # calculating the periods, calling generate_report(), and returning the result.
    #
    # ==== Attributes
    #
    # * +start_date+ - a Date instance representing the start of the report
    # * +end_date+ - a Date instance representing the start of the report
    #
    def generate_monthly_report(start_date, end_date)
      dstart = start_date.beginning_of_month
      dend = end_date.beginning_of_month

      array_of_months = (dstart..dend).select {|d| d.day == 1}

      array_of_months.map! do |day|
        start_of_month = day
        start_of_next_month = day >> 1  # >> is a special method in Date that changes month
        {:start => start_of_month, :end => start_of_next_month}
      end

      return generate_report(array_of_months, 'monthly_report_template.html.erb')
    end


    # Generate a yearly report between (and including) the provided dates, by
    # calculating the periods, calling generate_report(), and returning the result.
    #
    # ==== Attributes
    #
    # * +start_date+ - a Date instance representing the start of the report
    # * +end_date+ - a Date instance representing the start of the report
    #
    def generate_yearly_report(start_date, end_date)
      #TODO: Make this work!
      #raise "Yearly reporting not supported yet"

      dstart = start_date.beginning_of_year
      dend = end_date.beginning_of_year

      array_of_years = (dstart..dend).select {|d| d.yday == 1}

      array_of_years.map! do |day|
        start_of_year = day
        start_of_next_year = day.next_year
        {:start => start_of_year, :end => start_of_next_year}
      end

      return generate_report(array_of_years, 'yearly_report_template.html.erb')
    end


    # A generic report generator implementation, intended to be called by
    # generate_daily_report, generate_weekly_report, and so on.
    #
    # ==== Attributes
    #
    # * +array_of_periods+ - an array of hashes, where each hash has a :start
    # and an :end key-value pair, the values of which are instances of the Date
    # class, like so:
    #
    #      example_array_of_periods = [
    #        { :start => Date.new(2001,2,3), :end => Date.new(2001,2,4) },
    #        { :start => Date.new(2001,2,4), :end => Date.new(2001,2,5) },
    #        { :start => Date.new(2001,2,5), :end => Date.new(2001,2,6) },
    #      ]
    #
    # * +template_path+ - the path to the report template, relative to this file
    #
    def generate_report(array_of_periods, template_path)
      #TODO: Pass it the activerecord thingy it needs, instead of hardcoding it.

      fba_skus = @skus || BookCultureLib::AmazonOrder.uniq.pluck(:sku)
      #TODO: Might be better to do a .where with the start and end of range, then do a pluck
      #       from that, so we're only listing fba skus that exist in the desired range.
      #(Make this some sort of configurable option!)

      report_data = BookCultureLib::ReportData.new( Time.now.to_s, fba_skus )

      array_of_periods.each do |period|
        temp_hash = { date: period[:start], quantities: Hash.new(0) }

        #TODO: Is there any way to make this not horribly ugly??
        BookCultureLib::AmazonOrder.where("purchase_date >= :start_date AND purchase_date < :end_date",
                                          {:start_date => period[:start], :end_date => period[:end]}).each do |order|
          temp_hash[:quantities][order.sku] += order.quantity
        end

        report_data << temp_hash
      end

      #TODO: Move the template path stuff to the config?
      #template = IO.read(File.expand_path(template_path, __FILE__))
      template = IO.read(File.expand_path(File.join('../../../views', template_path), __FILE__))

      rhtml = ERB.new(template, 0, '>')
      # The 0 does nothing special, the '>' eliminates pointless newlines

      return rhtml.result(report_data.get_binding)
    end



  end

end
