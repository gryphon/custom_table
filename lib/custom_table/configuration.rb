module CustomTable
  class Configuration
    attr_accessor :icons_framework
    attr_accessor :filter_outer_wrapper_class, :filter_inner_wrapper_class
    attr_accessor :show_search_icon
    attr_accessor :move_totals_top
    attr_accessor :date_format
    attr_accessor :datetime_format

    def initialize
      @icons_framework = :bi
      @filter_outer_wrapper_class = "card"
      @filter_inner_wrapper_class = "card-body bg-light"
      @show_search_icon = false
      @move_totals_top = false
      @date_format = :default
      @datetime_format = :short

    end

  end
end