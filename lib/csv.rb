
class CSV

  # A custom converter, since the Amazon headers don't really like the default
  # :symbols converter.
  HeaderConverters[:amazon_symbol] = lambda { |h|
    h.encode(CSV::ConverterEncoding).downcase.gsub(/-/, "_").
                                     gsub(/\s+/, "").
                                     gsub(/\W+/, "").to_sym
  }

end
