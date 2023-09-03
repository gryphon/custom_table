module CustomTable
  module ApplicationHelper

    # MOVE TO GENERATED HELPER
    # def boolean_icon(value, true_value = nil, false_value = nil)
    #   capture do
    #     concat content_tag(:i, "", class: (value ? "bi bi-check-lg text-success" : "bi bi-x-lg text-danger"), data: {raw: value})
    #     concat content_tag(:span, value ? true_value : false_value, class: "ms-1") unless true_value.nil?
    #   end
    # end

    def custom_table_form_for(record, options = {}, &block)
      options[:url] = request.path if options[:url].nil?
      options[:method] = :get
  
      options[:html] ||= {} 
      options[:html][:class] = "row row-cols-md-auto g-3 align-items-center search-fields-filter"
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
    def field_value_for item, field, definitions: nil, representation: nil
 
      defs = definitions

      model_name = item.model_name.singular
      global_model_name = item.class.model_name.singular # non-model

      helpers = []
      helpers += [defs[:helper]] if !defs.nil?

      helpers += [
        "#{model_name}_#{representation}_#{field}_field",
        "#{model_name}_#{representation}_#{field}",
      ] if !representation.nil?

      helpers += [
        "#{model_name}_#{field}_field",
        "#{model_name}_#{field}",
        "#{model_name}_#{field}_raw",
        "#{global_model_name}_#{field}"
      ]

      if item.class.superclass.to_s != "ApplicationRecord"
        super_model_name = item.class.superclass.model_name.singular
        helpers += [
          "#{super_model_name}_#{field}_field",
          "#{super_model_name}_#{field}",
          "#{super_model_name}_#{field}_raw",
        ] 
      end

      helpers = helpers.flatten.compact

      helpers.each do |helper|
        if self.class.method_defined?(helper)
          if self.method(helper).arity == 1
            return self.send(helper, item) || not_set 
          end
          if self.method(helper).arity == 2
            return self.send(helper, item, field) || not_set 
          end
        end
      end
  
      if !defs.nil? && defs[:amount]
        if !item.class.columns_hash[field.to_s].nil? && item.class.columns_hash[field.to_s].type == :integer
          return amount_value(item.send(field), 0) rescue ""
        else
          return amount(item.send(field)) rescue ""
        end
      else
        if item.class.reflect_on_association(field)
          return not_set if (item.send(field) rescue nil).nil?
          return render(item.send(field)) rescue item.send(field).to_s rescue ""
        elsif item.class.columns_hash[field.to_s] && item.class.columns_hash[field.to_s].type == :boolean
          return boolean_icon(item.send(field)) rescue ""
        elsif item.class.defined_enums.has_key?(field.to_s)
          return (item.send(field).presence || not_set).to_s rescue ""
        elsif item.class.columns_hash[field.to_s] && [:date, :datetime].include?(item.class.columns_hash[field.to_s].type)
          return (item.send(field).blank? ? not_set : l(item.send(field), format: :short)) rescue ""
        elsif item.class.columns_hash[field.to_s] && [:integer, :float, :decimal].include?(item.class.columns_hash[field.to_s].type)
          return not_set if (item.send(field) rescue nil).nil?
          return amount(item.send(field)) rescue ""
        else
          return (item.send(field).presence || not_set).to_s rescue ""
        end
      end
      
    end
  
    # Same as above but for Export only
    def raw_field_value_for item, field, definitions: nil, representation: nil
 
      defs = definitions

      model_name = item.model_name.singular
      global_model_name = item.class.model_name.singular
  
      helpers = []

      helpers += [
        "#{model_name}_#{representation}_#{field}_field_raw",
        "#{model_name}_#{representation}_#{field}_raw",
      ] if !representation.nil?

      helpers += [
        "#{model_name}_#{field}_field_raw",
        "#{model_name}_#{field}_raw",
        "#{global_model_name}_#{field}_raw"
      ]

      if item.class.superclass.to_s != "ApplicationRecord"
        super_model_name = item.class.superclass.model_name.singular
        helpers += [
          "#{super_model_name}_#{field}_field_raw",
          "#{super_model_name}_#{field}_raw",
        ] 
      end

      helpers = helpers.flatten.compact

      helpers.each do |helper|
        return self.send(helper, item) if self.class.method_defined?(helper)
      end

      if !defs.nil? && defs[:amount]
        return item.send(field) rescue nil
      else
        if item.class.reflect_on_association(field)
          return item.send(field).to_s rescue nil
        elsif item.class.columns_hash[field.to_s] && item.class.columns_hash[field.to_s].type == :boolean
          return item.send(field) rescue nil
        elsif item.class.defined_enums.has_key?(field.to_s)
          return (item.send(field).presence) rescue nil
        elsif item.class.columns_hash[field.to_s] && [:date, :datetime].include?(item.class.columns_hash[field.to_s].type)
          return (item.send(field).blank? ? nil : field) rescue nil
        elsif item.class.columns_hash[field.to_s] && [:integer, :float, :decimal].include?(item.class.columns_hash[field.to_s].type)
          return nil if (item.send(field) rescue nil).nil?
          return item.send(field) rescue nil
        else
          return (item.send(field).presence).to_s rescue nil
        end
      end
      
    end
  

    # Returns list of fields to show in table according user settings
    def custom_table_fields_for(model, representation: nil, current_search: {}, predefined_fields: nil, use_all_fields: false)
  
      fields = []
      current_search = {} if current_search.nil?
  
      model_fields = custom_table_fields_definition_for(model, representation)
  
      if (!predefined_fields.nil?)
        return model_fields.select {|k,v| predefined_fields.include?(k) }
      end
  
      fields_key = model.model_name.to_s
      fields_key += "-#{representation}" unless representation.nil?
  
      s = custom_table_user_customized_fields_for(model, representation)
  
      if use_all_fields
        selected_fields = model_fields.keys
      else
        if !s.nil?
          # Use saved user settings for the model
          always_selected_fields = model_fields.select { |x, y| [:always].include?(y[:appear]) || current_search.keys.include?(x.to_s) }.keys
          always_selected_fields.each {|f| s = {"#{f.to_s}": true}.merge(s) if s[f].nil? }
          selected_fields = s.select{|f,v| v }.keys
        else
          # Use default model settings
          selected_fields = model_fields.select { |x, y| [:always, :default].include?(y[:appear]) || current_search.keys.include?(x.to_s) }.keys
        end
      end
  
      # Filter selection again with model settings for sure
      return selected_fields.collect{|f| [f, model_fields[f]]}.to_h
  
    end
  
    # Returns list of fields for customization form
    def custom_table_fields_settings_for(model, representation: nil)
  
      model_fields = custom_table_fields_definition_for(model, representation)
      model_fields = model_fields.reject {|k,v| [:export, :never].include?(v[:appear]) }

      fields_key = model.model_name.to_s
      fields_key += "-#{representation}" unless representation.nil?
  
      user_customization = custom_table_user_customized_fields_for(model, representation)

      if !user_customization.nil?
        # Add new fields at the top to user customization if not present
        model_fields.each do |f, v| 
          next if !user_customization[f].nil? 
          selected = [:always, :default].include?(v[:appear])
          new_field = {"#{f.to_s}": selected}
          if selected
            user_customization = new_field.merge(user_customization)
          else
            user_customization = user_customization.merge(new_field)
          end
        end
        return user_customization.reject{|f,v| model_fields[f].nil?}.collect{|f,v| [f, {selected: v}.merge(model_fields[f])]}.to_h
      else
        # Use default model settings
        # abort model_fields.transform_values!{|f| f[:selected] = true}.inspect
        return model_fields.each{|k,f| f[:selected] = [:always, :default].include?(f[:appear])}
      end
  
    
    end
  
    # Prepares object of user fields customization
    def custom_table_user_customized_fields_for(model, representation = nil)
      fields_key = custom_table_fields_key(model, representation)
      defs = custom_table_fields_definition_for(model, representation)
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
  
    def custom_table_customizable_fields_for(model, representation = nil)
      model_fields = custom_table_fields_definition_for(model, representation)
      model_fields.reject {|k,v| [:always, :export, :never].include?(v[:appear]) }
    end
  
    # Base definition for model
    def custom_table_fields_definition_for(model, representation = nil)
      helper_name = "#{model.model_name.singular}_custom_table_fields"
      if (! self.class.method_defined?(helper_name))
        raise "#{helper_name} helper is not defined so we do not know how to render custom_table for #{model}"
      end

      if representation.nil? || method(helper_name).parameters.empty?
        defs = self.send("#{helper_name}")
      else
        defs = self.send("#{helper_name}", representation)
      end

      return defs.each{|x,y| y[:label] = model.human_attribute_name(x) if y[:label].nil? }
    end
  
    # Base definition for model
    def custom_table_fields_definition_for_field(model, field, representation = nil)
      helper_name = "#{model.model_name.singular}_custom_table_fields"
      if (! self.class.method_defined?(helper_name))
        raise "#{helper_name} helper is not defined so we do not know how to render custom_table for #{model}"
      end
      if representation.nil? || method(helper_name).parameters.empty?
        defs = self.send("#{helper_name}")
      else
        defs = self.send("#{helper_name}", representation)
      end
      return nil if defs[field].nil?
      defs[:label] = model.human_attribute_name(field) if defs[:label].nil?
      return defs
    end
  

    # Returns true if model can be customized by current user at least by one field
    def current_user_has_customizable_fields_for?(model, representation=nil)
      return false if current_user.nil?
      custom_table_customizable_fields_for(model, representation).count.positive?
    end
  
    def custom_table_data collection, representation=nil, **params

      params[:collection] = collection
      params[:representation] = representation
      params[:paginate] = true if params[:paginate]!=false
      params[:last_page] = true if params[:last_page]!=false
      params[:namespace] = (controller.class.module_parent == Object) ? nil : controller.class.module_parent.to_s.underscore.to_sym
      params[:force_edit_button] = false if params[:force_edit_button].nil?
      params[:modal_edit] = true if params[:modal_edit].nil?
      
      render "custom_table/table", params do
        yield
      end
    end
  
    # Data for updating values via turbo according object id and field name
    def custom_table_row_data item, representation = nil, **params
  
      params[:item] = item
      params[:representation] = representation
      params[:namespace] = (controller.class.module_parent == Object) ? nil : controller.class.module_parent.to_s.underscore.to_sym
      
      render "custom_table/table_row_data", params do
        yield
      end
    end
  
    def custom_table_filter search_model, representation=nil, **params, &block

      params[:search_model] = search_model
      params[:representation] = representation
      render "custom_table/filter", params do |f|
        yield if !block.nil?
      end
    end

    # Rounded
    def amount_round(c)
      content_tag(:span, amount_value(c, 0), "data-raw": (c.blank? ? nil : c.round))
    end
  
    # Base
    def amount(c)
      content_tag(:span, amount_value(c), "data-raw": (c.blank? ? nil : c.round(2)))
    end
  
    # Abstract
    def amount_value(c, p = 2)
      number_to_currency(c, precision: p, locale: :en, unit: "")
    end
  
    # Colored
    def amount_color(c)
      content_tag(:span, amount(c), class: ["amount", (c.to_f >= 0 ? "positive" : "negative")])
    end
  
    # Colored rounded
    def amount_round_color(c)
      content_tag(:span, amount_round(c), class: ["amount", (c.to_f >= 0 ? "positive" : "negative")])
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
        custom_table_settings_icon
      end
    end

    def custom_table_representations_for model
      helper_name = "#{model.model_name.singular}_custom_table_representations"
      return self.send(helper_name) if self.class.method_defined?(helper_name)
      return []
    end

  end
end
