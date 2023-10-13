module CustomTableConcern
  extend ActiveSupport::Concern

  included do
    helper CustomTable::ApplicationHelper
    helper CustomTable::FieldsetHelper
    helper CustomTable::IconsHelper

  end

  class_methods do 
  end

  def format_web
    !(request.format.xlsx? || request.format.csv?)
  end

  def custom_table collection, variant = nil, default_sorts: "created_at desc", default_search: {}

    @q = collection.ransack(params[:q])
    @q = collection.ransack((params[:q] || {}).merge(default_search)) if @q.conditions.empty?

    customization = helpers.custom_table_user_customization_for(collection.model, variant)
    @q.sorts = customization&.dig(:sorts).presence || default_sorts if @q.sorts.empty?

    collection = @q.result(distict: true)
    # collection = collection.page(params[:page]).per(per_page) if format_web && paginate

    if !current_user.nil?
      current_user.save_custom_table_settings(collection.model, variant, per_page: params[:per]) if !params[:per].nil? && params[:do_not_save_settings].nil?
      current_user.save_custom_table_settings(collection.model, variant, sorts: "#{@q.sorts[0].name} #{@q.sorts[0].dir}") if !params[:q].nil? && !params[:q][:s].nil? && !@q.nil? && !@q.sorts[0].nil? && !@q.sorts[0].name.nil? && params[:do_not_save_settings].nil?
    end

    return collection
  end

  def custom_table_export(format, collection, filename: nil)

    filename ||= collection.model.model_name.plural

    format.xlsx do
      if collection.count > 1000
        redirect_to params.permit!.merge({:format => :html}), alert: t("custom_table.huge_xlsx_alert", csv: helpers.link_to(t("custom_table.download_as_csv"), params.permit!.merge({:format => :csv})))
      else
        response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}.xlsx\""
      end
    end

    format.csv do
      # Delete this header so that Rack knows to stream the content.
      headers.delete("Content-Length")
      # Do not cache results from this action.
      headers["Cache-Control"] = "no-cache"
      # Let the browser know that this file is a CSV.
      headers['Content-Type'] = 'text/csv'
      # Do not buffer the result when using proxy servers.
      headers['X-Accel-Buffering'] = 'no'
      # Set the filename
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}.csv\"" 

      global_model_name = collection.model.model_name.singular

      fields = helpers.custom_table_fields_definition_for(collection.model)

      # Allow pre-defined fields for export
      if !@fields.nil?
        fields = fields.select { |k, _v| local_assigns[:fields].include?(k) }
      end 

      @csv_enumerator ||= Enumerator.new do |yielder|

        head = []

        fields.each do |field, defs|
          head.push (defs[:label].nil? ? collection.model.human_attribute_name(field) : defs[:label])
        end

        yielder << CSV.generate_line(head)

        collection.find_each do |item|

          row = []
          model_name = item.model_name.singular # Allows to show different class models in one table!
    
          fields.each do |field, defs|
            next if defs[:table] == false
        
            value = helpers.raw_field_value_for(item, field)
        
            if [Date, ActiveSupport::TimeWithZone].include?(value.class)
              value = value.to_date
            end
        
            row.push value
          end
        
          # Extra cols definition
          if defined?(@extra_cols)
            row += @extra_cols.call(item)
          end    

          yielder << CSV.generate_line(row)
        end
      end

      self.response_body = @csv_enumerator
    end

  end



  private
  

end