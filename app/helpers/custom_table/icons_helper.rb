module CustomTable

  module IconsHelper

    def custom_table_download_icon
      return custom_table_icon("fa fa-download") if CustomTable.configuration.icons_framework == :fa
      return custom_table_icon("bi bi-download") if CustomTable.configuration.icons_framework == :bi
    end

    def custom_table_settings_icon
      return custom_table_icon("fa fa-cog") if CustomTable.configuration.icons_framework == :fa
      return custom_table_icon("bi bi-gear") if CustomTable.configuration.icons_framework == :bi

    end

    def custom_table_move_icon_class
      return "fa fa-sort" if CustomTable.configuration.icons_framework == :fa
      return "bi bi-arrow-down-up" if CustomTable.configuration.icons_framework == :bi
    end

    def custom_table_cancel_icon
      return custom_table_icon("fa fa-ban") if CustomTable.configuration.icons_framework == :fa
      return custom_table_icon("bi bi-slash-circle") if CustomTable.configuration.icons_framework == :bi
    end

    def custom_table_icon c
      return content_tag(:i, "", class: c)
    end

  end

end