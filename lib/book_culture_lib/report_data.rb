# The object used to pass data to the ERB templates for reports

#TODO: Change all occurences of 'day' to read 'period' or 'time_period',
#       in order to be more semantically general
#       (NOTE: will probably require re-working the template or report generator!)

module BookCultureLib

  class ReportData
    def initialize( date_generated, products, report_opts = {} )
      @date_generated = date_generated
      @products = products
      @dates = []
      @date_format = report_opts[:date_format] || "%Y-%m-%d"
      @date_name = report_opts[:date_name] || "Date"
    end

    def add_date( date )
      #TODO: Rename this from 'add_day' and '@day' to something else, like 'period'
      @dates << date
    end

    alias_method :<<, :add_date

    def get_binding
      binding
    end

    # Render another template inside of a template
    #
    # ==== Attributes
    # * +path+ - path to the template you wish to include, relative to show_report.rb
    #
    # ==== Examples
    # Inside a template, call it like so:
    #
    #     <%= render "path/to/another.erb.html" %>
    #
    # <%= render "../../../views/partials/style.css" %>
    def render(path)
      content = File.read(File.expand_path(File.join('../../../views', path), __FILE__))
      t = ERB.new(content)
      t.result(binding)
    end


    def shrink(str, len)
      if str.length > len
        str[0..len] + "..."
      else
        str
      end
    end


  end

end

