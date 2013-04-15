# The object used to pass data to the ERB templates for reports

module BookCultureLib

  class ReportData
    def initialize( date_generated, all_skus )
      @date_generated = date_generated
      @all_skus = all_skus
      @days = []
    end

    def add_day( day )
      @days << day
    end

    alias_method :<<, :add_day

    def get_binding
      binding
    end
  end

end

