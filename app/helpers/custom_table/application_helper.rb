module CustomTable
  module ApplicationHelper

    def custom_table_form_for(record, options = {}, &block)
      options[:url] = request.path if options[:url].nil?
      options[:method] = :get
  
      options[:html] ||= {} 
      options[:html][:class] = "row row-cols-lg-auto g-3 align-items-center search-fields-filter"
      options[:wrapper] = options[:wrapper] || :inline_form
  
      options[:wrapper_mappings] = {
        boolean: :inline_boolean,
        check_boxes: :vertical_collection,
        radio_buttons: :vertical_collection,
        date: :inline_element,
        select: :inline_select
      }

      simple_form_for(record, options, &block)
    end
  
    def fields_table_for(collection, options = {}, &block); end
  
    # Tries to fetch attribute value by all possible ways (by priority):
    # Helper {singular_model_name}_{field}_field
    # Helper {singular_model_name}_{field}
    # Helper {singular_model_name}_{field}_raw
    # Attribute of model
    def field_value_for item, field, defs
  
      model_name = item.model_name.singular
      global_model_name = item.class.model_name.singular
  
      if !defs[:helper].nil?
        return self.send(defs[:helper], item, field)
      elsif self.class.method_defined?("#{model_name}_#{field}_field")
        return self.send("#{model_name}_#{field}_field", item)
      elsif self.class.method_defined?("#{model_name}_#{field}")
        return self.send("#{model_name}_#{field}", item)
      elsif self.class.method_defined?("#{model_name}_#{field}_raw")
        return self.send("#{model_name}_#{field}_raw", item)
      elsif self.class.method_defined?("#{global_model_name}_#{field}")
        return self.send("#{global_model_name}_#{field}", item)
      elsif defs[:amount]
        if !item.class.columns_hash[field.to_s].nil? && item.class.columns_hash[field.to_s].type == :integer
          return tfc(item.send(field), 0) rescue ""
        else
          return fc(item.send(field)) rescue ""
        end
      else
        if item.class.columns_hash[field.to_s] && item.class.columns_hash[field.to_s].type == :boolean
          return boolean_icon(item.send(field)) rescue ""
        elsif item.class.columns_hash[field.to_s] && [:date, :datetime].include?(item.class.columns_hash[field.to_s].type)
          return l(item.send(field)) rescue ""
        else
          return item.send(field) rescue ""
        end
      end
      
    end
  
    # Returns list of fields to show in table according user settings
    def custom_table_fields_for(model, representation: nil, current_search: {}, predefined_fields: nil)
  
      fields = []
      current_search = {} if current_search.nil?
  
      model_fields = custom_table_fields_definition_for(model)
  
      if (!predefined_fields.nil?)
        return model_fields.select {|k,v| predefined_fields.include?(k) }
      end
  
      fields_key = model.model_name.to_s
      fields_key += "-#{representation}" unless representation.nil?
  
      s = custom_table_user_customized_fields_for(model, representation)
  
      if !s.nil?
        # Use saved user settings for the model
        always_selected_fields = model_fields.select { |x, y| [:always].include?(y[:appear]) || current_search.keys.include?(x.to_s) }.keys
        always_selected_fields.each {|f| s = {"#{f.to_s}": true}.merge(s) if s[f].nil? }
        selected_fields = s.select{|f,v| v }.keys
      else
        # Use default model settings
        selected_fields = model_fields.select { |x, y| [:always, :default].include?(y[:appear]) || current_search.keys.include?(x.to_s) }.keys
      end
  
      # Filter selection again with model settings for sure
      return selected_fields.collect{|f| [f, model_fields[f]]}.to_h
  
    end
  
    # Returns list of fields for customization form
    def custom_table_fields_settings_for(model, representation: nil)
  
      model_fields = custom_table_fields_definition_for(model)
  
      fields_key = model.model_name.to_s
      fields_key += "-#{representation}" unless representation.nil?
  
      user_customization = custom_table_user_customized_fields_for(model, representation)
  
      if !user_customization.nil?
        # Add new fields at the top to user customization if not present
        model_fields.each {|f, v| user_customization = {"#{f.to_s}": true}.merge(user_customization) if user_customization[f].nil? }
        return user_customization.collect{|f,v| [f, {selected: v}.merge(model_fields[f])]}.to_h
      else
        # Use default model settings
        # abort model_fields.transform_values!{|f| f[:selected] = true}.inspect
        return model_fields.each{|k,f| f[:selected] = [:always, :default].include?(f[:appear])}
      end
  
    
    end
  
    # Prepares object of user fields customization
    def custom_table_user_customized_fields_for(model, representation = nil)
      fields_key = custom_table_fields_key(model, representation)
      defs = custom_table_fields_definition_for(model)
      return nil if current_user.nil? || current_user.custom_table.nil? || current_user.custom_table.dig(fields_key, :fields).nil?
      return current_user.custom_table.dig(fields_key, :fields).symbolize_keys.reject{|k,v| defs[k.to_sym].nil?}
  
    end
  
    # Prepares object of user search customization
    def custom_table_user_customization_for(model, representation = nil)
      fields_key = custom_table_fields_key(model, representation)
      return nil if current_user.nil? || current_user.custom_table.nil?
      return current_user.custom_table[fields_key]&.symbolize_keys
    end
  
    def custom_table_fields_key(model, representation = nil)
      fields_key = model.model_name.to_s
      fields_key += "-#{representation}" unless representation.nil?
      return fields_key
    end
  
    def custom_table_customizable_fields_for(model)
      model_fields = custom_table_fields_definition_for(model)
      model_fields.reject {|k,v| [:always, :export].include?(v[:appear]) }
    end
  
    # Base definition for model
    def custom_table_fields_definition_for(model)
      helper_name = "#{model.model_name.singular}_custom_table_fields"
      if (! self.class.method_defined?(helper_name))
        raise "#{helper_name} helper is not defined so we do not know how to render custom_table for #{model}"
      end
      return self.send("#{helper_name}").each{|x,y| y[:label] = model.human_attribute_name(x) if y[:label].nil? }
    end
  
    # Returns true if model can be customized by current user at least by one field
    def current_user_has_customizable_fields_for?(model)
      return false if current_user.nil?
      custom_table_customizable_fields_for(model).count.positive?
    end
  
    def custom_table_data **params

      params[:namespace] = (controller.class.module_parent == Object) ? nil : controller.class.module_parent.to_s.underscore.to_sym
      
      render "custom_table/table", params do
        yield
      end
    end
  
    def custom_table_row_data **params
  
      params[:namespace] = (controller.class.module_parent == Object) ? nil : controller.class.module_parent.to_s.underscore.to_sym
      
      render "custom_table/table_row_data", params do
        yield
      end
    end
  
    def custom_table_filter **params, &block
      render "custom_table/filter", params do |f|
        yield if !block.nil?
      end
    end
  
  
    # Rounded
    def rfc(c)
      content_tag(:span, tfc(c, 0), "data-raw": (c.blank? ? nil : c.round))
    end
  
    # Base
    def fc(c)
      content_tag(:span, tfc(c), "data-raw": (c.blank? ? nil : c.round(2)))
    end
  
    # Abstract
    def tfc(c, p = 2)
      number_to_currency(c, precision: p, locale: :en, unit: "")
    end
  
    # Colored
    def cfc(c)
      content_tag(:span, fc(c), class: ["amount", (c.to_f >= 0 ? "positive" : "negative")])
    end
  
    # Colored rounded
    def crfc(c)
      content_tag(:span, rfc(c), class: ["amount", (c.to_f >= 0 ? "positive" : "negative")])
    end
  
    def custom_table_download_button collection, **params
      params[:collection] = collection
      render "custom_table/download", params
    end
  
    def custom_table_settings search_model, representation=nil, **params
      params[:search_model] = search_model
      params[:representation] = representation
  
      render "custom_table/settings", params
  
    end
  
    def custom_table_settings_button search_model, representation=nil, size: "sm"
      link_to custom_table.edit_setting_path(search_model.model_name, representation: representation), :class => "btn btn-outline-primary btn-#{size}", data: {"turbo-frame": "remote-modal"} do
        content_tag(:i, "", class: "bi bi-gear")
      end
    end



  end
end
