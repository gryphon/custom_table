module CustomTable

  module IconsHelper

    def custom_table_download_icon
      return custom_table_icon("fa fa-download") if CustomTable.configuration.icons_framework == :fa
      return custom_table_icon("bi bi-download") if CustomTable.configuration.icons_framework == :bi
      return custom_table_icon("ti ti-download") if CustomTable.configuration.icons_framework == :ti
    end

    def custom_table_settings_icon
      return custom_table_icon("fa fa-cog") if CustomTable.configuration.icons_framework == :fa
      return custom_table_icon("bi bi-gear") if CustomTable.configuration.icons_framework == :bi
      return custom_table_icon("ti ti-settings") if CustomTable.configuration.icons_framework == :ti

    end

    def custom_table_move_icon_class
      return "fa fa-sort" if CustomTable.configuration.icons_framework == :fa
      return "bi bi-arrow-down-up" if CustomTable.configuration.icons_framework == :bi
      return "ti ti-arrows-up-down" if CustomTable.configuration.icons_framework == :ti
    end

    def custom_table_search_icon_class
      return "fa fa-search" if CustomTable.configuration.icons_framework == :fa
      return "bi bi-search" if CustomTable.configuration.icons_framework == :bi
      return "ti ti-search" if CustomTable.configuration.icons_framework == :ti
    end

    def custom_table_tree_child_icon_class
      return "fa fa-arrow-right" if CustomTable.configuration.icons_framework == :fa
      return "bi bi-arrow-return-right" if CustomTable.configuration.icons_framework == :bi
      return "ti ti-arrow-right" if CustomTable.configuration.icons_framework == :ti
    end

    def custom_table_cancel_icon
      return custom_table_icon("fa fa-ban") if CustomTable.configuration.icons_framework == :fa
      return custom_table_icon("bi bi-slash-circle") if CustomTable.configuration.icons_framework == :bi
      return custom_table_icon("ti ti-ban") if CustomTable.configuration.icons_framework == :ti
    end

    def custom_table_search_icon
      return custom_table_icon("fa fa-search") if CustomTable.configuration.icons_framework == :fa
      return custom_table_icon("bi bi-search") if CustomTable.configuration.icons_framework == :bi
      return custom_table_icon("ti ti-search") if CustomTable.configuration.icons_framework == :ti
    end

    def custom_table_icon c
      return content_tag(:i, "", class: c)
    end

    # Can be overriden
    def boolean_icon c
      if c
        return custom_table_icon("fa fa-check text-success") if CustomTable.configuration.icons_framework == :fa
        return custom_table_icon("bi bi-check-lg text-success") if CustomTable.configuration.icons_framework == :bi
        return custom_table_icon("ti ti-check text-success") if CustomTable.configuration.icons_framework == :ti
      else
        return custom_table_icon("fa fa-times text-danger") if CustomTable.configuration.icons_framework == :fa
        return custom_table_icon("bi bi-x-lg text-danger") if CustomTable.configuration.icons_framework == :bi
        return custom_table_icon("ti ti-x text-danger") if CustomTable.configuration.icons_framework == :ti
      end
    end

  end

end