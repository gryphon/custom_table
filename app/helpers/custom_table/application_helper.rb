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
      options[:html][:class] = "row row-cols-sm-auto g-3 align-items-center custom-table-filter"
      options[:wrapper] = options[:wrapper] || :ct_inline_form
  
      options[:wrapper_mappings] = {
        boolean: :ct_inline_boolean,
        check_boxes: :ct_vertical_collection,
        radio_buttons: :ct_vertical_collection,
        date: :ct_inline_element,
        select: :ct_inline_select
      }

      simple_form_for(record, options, &block)
    end
  
    def fields_table_for(collection, options = {}, &block); end
  
    # Tries to fetch attribute value by all possible ways (by priority):
    # Helper {singular_model_name}_{field}_field
    # Helper {singular_model_name}_{field}
    # Helper {singular_model_name}_{field}_raw
    # Attribute of model
    def field_value_for item, field, definitions: nil, variant: nil

      defs = definitions

      model_name = item.model_name.singular
      global_model_name = item.class.model_name.singular # non-model

      if !defs.nil?
        if self.class.method_defined?("#{model_name}_data_visible?") && !self.send("#{model_name}_data_visible?", item)
          return "?" if !(defs[:visible_when_data_hidden] || defs[:link_to_show])
        end
      end

      helpers = []
      helpers += [defs[:helper]] if !defs.nil?

      helpers += [
        "#{model_name}_#{variant}_#{field}_field",
        "#{model_name}_#{variant}_#{field}",
      ] if !variant.nil?

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
          if self.method(helper).arity == 1 || self.method(helper).arity == -2
            return self.send(helper, item) || not_set 
          end
          if self.method(helper).arity == 2
            return self.send(helper, item, field) || not_set 
          end
        end
      end
  
      if !defs.nil? && defs[:amount]
        val = item.send(field) rescue nil
        return not_set if val.nil?
        if !item.class.columns_hash[field.to_s].nil? && item.class.columns_hash[field.to_s].type == :integer
          # Integer only
          return amount_value(val, 0) rescue ""
        else
          return amount(val) rescue ""
        end
      else
        if item.class.reflect_on_association(field)
          return not_set if (item.send(field) rescue nil).nil?
          return render(item.send(field)) rescue item.send(field).to_s rescue ""
        elsif item.class.columns_hash[field.to_s] && item.class.columns_hash[field.to_s].type == :boolean
          return boolean_icon(item.send(field)) rescue ""
        elsif item.class.defined_enums.has_key?(field.to_s)
          return ((item.send("human_#{field}") rescue item.send(field).presence) || not_set).to_s rescue ""
        elsif item.class.columns_hash[field.to_s] && [:date].include?(item.class.columns_hash[field.to_s].type)
          return (item.send(field).blank? ? not_set : l(item.send(field), format: CustomTable.configuration.date_format)) rescue ""
        elsif item.class.columns_hash[field.to_s] && [:datetime].include?(item.class.columns_hash[field.to_s].type)
          return (item.send(field).blank? ? not_set : l(item.send(field), format: CustomTable.configuration.datetime_format)) rescue ""
        elsif item.class.columns_hash[field.to_s] && [:integer, :float, :decimal].include?(item.class.columns_hash[field.to_s].type)
          return not_set if (item.send(field) rescue nil).nil?
          return item.send(field) if !defs.nil? && defs[:amount] === false # Showing simple output if amount is false
          return amount(item.send(field)) rescue ""
        else
          # Non-column attribute
          v = (item.send(field).presence || not_set) rescue nil
          if !defs.nil? && !defs[:type].nil?
            return date_value(v) if [:date, :datetime].include?(defs[:type])
          end
          return v.to_s.presence || not_set
        end
      end
      
    end

    def custom_table_totals collection, fields, totals = {}, fields_totals = {}

      out = {}
      totals = {} if totals.nil?
      fields_totals = {} if fields_totals.nil?

      fields.keys.each do |field|

        # We only work if field total is enabled explicitly with definition or totals
        next if !fields[field][:total] && !totals.has_key?(field)

        # Taking pre-defined value if available
        if !totals[field].nil?
          out[field] = totals[field]
        else
          model_class = collection.model
          # Trying to find helper first
          model_name = model_class.model_name.singular
          helper = "#{model_name}_#{field}_total"

          if self.class.method_defined?(helper)
            # Better use helper!
            out[field] = self.send(helper, collection.except(:limit, :offset, :order, :group))
          else
            if collection.respond_to?(:total_pages) && (!model_class.columns_hash[field.to_s].nil? || !fields[field][:total_scope].nil?) 
              # We can try to sum value from database

              if fields[field][:total_scope].nil?
                out[field] = collection.except(:limit, :offset, :order, :group).distinct(false).sum(field)
              else
                out[field] = collection.except(:limit, :offset, :order, :group).distinct(false).send(fields[field][:total_scope])
              end
            else
              # Taking simple summed value because all data is shown
              out[field] = fields_totals[field]
            end

          end

        end
      end

      out

    end
  
    # Same as above but for Export only
    def raw_field_value_for item, field, definitions: nil, variant: nil
 
      defs = definitions

      model_name = item.model_name.singular
      global_model_name = item.class.model_name.singular

      if !defs.nil?
        if self.class.method_defined?("#{model_name}_data_visible?") && !self.send("#{model_name}_data_visible?", item)
          return nil if !(defs[:visible_when_data_hidden] || defs[:link_to_show])
        end
      end

      helpers = []

      helpers += [
        "#{model_name}_#{variant}_#{field}_field_raw",
        "#{model_name}_#{variant}_#{field}_raw",
      ] if !variant.nil?

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
          return (item.send(field).presence) rescue nil
        elsif item.class.columns_hash[field.to_s] && [:float, :decimal].include?(item.class.columns_hash[field.to_s].type)
          return item.send(field).round(2) rescue nil
        elsif item.class.columns_hash[field.to_s] && [:integer].include?(item.class.columns_hash[field.to_s].type)
          return item.send(field) rescue nil
        else
          return (item.send(field).presence) rescue nil
        end
      end
      
    end
  

    # Returns list of fields to show in table according user settings
    def custom_table_fields_for(model, variant: nil, current_search: {}, predefined_fields: nil, use_all_fields: false)
  
      fields = []
      current_search = {} if current_search.nil?
  
      model_fields = custom_table_fields_definition_for(model, variant)
  
      if (!predefined_fields.nil?)
        out = {}
        predefined_fields.each do |f|
          out[f] = model_fields[f]
        end
        return out.compact
        # return model_fields.select {|k,v| predefined_fields.include?(k) }
      end
  
      fields_key = model.model_name.to_s
      fields_key += "-#{variant}" unless variant.nil?
  
      s = custom_table_user_customized_fields_for(model, variant)
 
      use_all_fields = true if params[:custom_table_use_all_fields]

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
    def custom_table_fields_settings_for(model, variant: nil)
 
      model_fields = custom_table_fields_definition_for(model, variant)
      model_fields = model_fields.reject {|k,v| [:export, :never].include?(v[:appear]) }

      fields_key = model.model_name.to_s
      fields_key += "-#{variant}" unless variant.nil?
  
      user_customization = custom_table_user_customized_fields_for(model, variant)

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
    def custom_table_user_customized_fields_for(model, variant = nil)
      fields_key = custom_table_fields_key(model, variant)
      defs = custom_table_fields_definition_for(model, variant)
      return nil if !self.respond_to?(:current_user) || current_user.nil? || current_user.custom_table.nil? || current_user.custom_table.dig(fields_key, :fields).nil?
      return current_user.custom_table.dig(fields_key, :fields).symbolize_keys.reject{|k,v| defs[k.to_sym].nil?}
  
    end
  
    # Prepares object of user search customization
    def custom_table_user_customization_for(model, variant = nil)
      fields_key = custom_table_fields_key(model, variant)
      return nil if !self.respond_to?(:current_user) || current_user.nil? || current_user.custom_table.nil?
      return current_user.custom_table[fields_key]&.symbolize_keys
    end
  
    def custom_table_fields_key(model, variant = nil)
      fields_key = model.model_name.to_s
      fields_key += "-#{variant}" unless variant.nil?
      return fields_key
    end
  
    def custom_table_customizable_fields_for(model, variant = nil)
      model_fields = custom_table_fields_definition_for(model, variant)
      model_fields.reject {|k,v| [:always, :export, :never].include?(v[:appear]) }
    end
  
    # Base definition for model
    def custom_table_fields_definition_for(model, variant = nil)

      helper_name = "#{model.model_name.singular}_custom_table_fields"
      if (! self.class.method_defined?(helper_name))
        helper_name = "#{model.model_name.element}_custom_table_fields"

        # Removing namespace from model
        if (! self.class.method_defined?(helper_name))
          raise "#{helper_name} helper is not defined so we do not know how to render custom_table for #{model}"
        end
      end

      if variant.nil? || method(helper_name).parameters.empty?
        defs = self.send("#{helper_name}")
      else
        defs = self.send("#{helper_name}", variant)
      end

      return defs.each{|x,y| y[:label] = model.human_attribute_name(x) if y[:label].nil? }
    end

    # Base definition for model
    def custom_table_fields_definition_for_field(model, field, variant = nil)

      helper_name = "#{model.model_name.singular}_custom_table_fields"

      if (! self.class.method_defined?(helper_name))
        raise "#{helper_name} helper is not defined so we do not know how to render custom_table for #{model}"
      end
      if variant.nil? || method(helper_name).parameters.empty?
        defs = self.send("#{helper_name}")
      else
        defs = self.send("#{helper_name}", variant)
      end
      return nil if defs[field].nil?
      defs = defs[field]
      defs[:label] = model.human_attribute_name(field) if defs[:label].nil?
      return defs
    end
  

    # Returns true if model can be customized by current user at least by one field
    def current_user_has_customizable_fields_for?(model, variant=nil)
      return false if current_user.nil?
      custom_table_customizable_fields_for(model, variant).count.positive?
    end
  
    def custom_table_data collection, variant=nil, **params

      params[:collection] = collection
      params[:variant] = variant
      params[:paginate] = true if params[:paginate]!=false
      params[:last_page] = true if params[:last_page]!=false
      params[:namespace] = (controller.class.module_parent == Object) ? nil : controller.class.module_parent.to_s.underscore.to_sym
      params[:modal_edit] = true if params[:modal_edit].nil?
      params[:with_select] = true if params[:with_select].nil? && params[:batch_actions]
      params[:batch_activator] = true if params[:batch_activator].nil? && params[:batch_actions] === true
      params[:per_page] = true if params[:per_page].nil?
      params[:paginator_position] = "bottom" if params[:paginator_position].nil?

      render "custom_table/table", params do
        yield
      end
    end
  
    # Data for updating values via turbo according object id and field name
    def custom_table_row_data item, variant = nil, **params
  
      params[:item] = item
      params[:variant] = variant
      params[:namespace] = (controller.class.module_parent == Object) ? nil : controller.class.module_parent.to_s.underscore.to_sym
      
      render "custom_table/table_row_data", params do
        yield
      end
    end
  
    def custom_table_filter search_model, variant=nil, **params, &block

      return "NO @q (Ransack) object" if @q.nil?

      params[:search_model] = search_model
      params[:variant] = variant
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
  
    def custom_table_download_button collection, **p
      p[:collection] = collection
      p[:downloads] ||= {}
      p[:downloads].unshift({title: t("custom_table.download_as_csv"), href: params.permit!.merge({:format => :csv})}) if p[:csv]
      render "custom_table/download", p
    end
  
    def custom_table_settings search_model, variant=nil, **params

      params[:search_model] = search_model
      params[:variant] = variant
  
      render "custom_table/settings", params
  
    end
  
    def custom_table_settings_button search_model, variant=nil, size: "sm"
      link_to custom_table.edit_setting_path(search_model.model_name, variant: variant), :class => "btn btn-outline-primary btn-#{size}", data: {"turbo-frame": "remote-modal"} do
        custom_table_settings_icon
      end
    end

    def custom_table_variants_for model
      helper_name = "#{model.model_name.singular}_custom_table_variants"
      return self.send(helper_name) if self.class.method_defined?(helper_name)
      return []
    end

    def tree_opener item_id, has_children=false, expanded=false
      content_tag :span, class: "tree-opener #{expanded ? 'opened' : ''}", data: {action: (has_children ? "click->table#toggle" : ""), "table-css-param": ".child-of-#{item_id}"} do
        concat content_tag(:span, (has_children ? "▶" : "▷"), class: "closed")
        concat content_tag(:span, "▼", class: "opened")
      end
    end

    def custom_table_fields_totals fields:, totals:, item:, fields_totals:, variant:
      fields.each do |field, defs|
        if !totals.nil? && totals.has_key?(field) && totals[field].nil? # Auto-counting
          fields_totals[field] = 0 if fields_totals[field].nil?
          fields_totals[field] += raw_field_value_for(item, field, definitions: defs, variant: variant).to_f rescue 0
        end
      end
      return fields_totals
    end

    def custom_table_batch_selector_check_box item, **params

      # abort params.inspect

      params[:param] = "#{item.model_name.plural}[]" if params[:param].nil?
      params[:data] = {"toggle-target": "checkbox", "batch-actions-target": "checkbox", "action": "toggle#recalculateToggler batch-actions#refresh"}

      check_box_tag params[:param], item.id, (!params[item.model_name.plural.to_sym].blank?) && (params[item.model_name.plural.to_sym].include?(item.id.to_s)), params
    end

    # Gets array of fields and results in object of available fields and definitions from fields from list
    def custom_table_fields_list_to_definitions model, fields
      d = custom_table_fields_definition_for(model) 
      out = {}
      fields.each do |f|
        found = d.find {|k, v| k == f }
        out[f] = found[1] if !found.nil?
      end
      return out
    end

    def custom_table_batch_ids items
      return if items.nil? || items.length == 0
      capture do
        items.each do |item|
          concat hidden_field_tag("#{item.model_name.plural}[]", item.id)
        end
        concat content_tag(:p, t("custom_table.batch_selected_items_count", count: items.length))
        concat content_tag(:p, t("custom_table.batch_action_description"))
      end
    end

    def custom_table_batch_fields model
      custom_table_fields_definition_for(model).select{|f, d| d[:batch] == true}.keys
    end

    def custom_table_batch_actions model

      item = model.new
      forms = []
      forms.push (form_for(item, url: [:batch_edit, item.model_name.plural.to_sym], params: "ids[]", html: {class: "d-inline me-1"}, method: :post, "target": "remote-modal", data: {"turbo-frame": "remote-modal", "batch-actions-target": "form", "action": "batch-actions#submit"}) do |f|
        concat(f.submit t("custom_table.batch_update"), class: "btn btn-success btn-sm my-1")
      end)
  
      forms.push (form_for(item, url: [:batch_destroy, item.model_name.plural.to_sym], params: "ids[]", html: {class: "d-inline"}, method: :delete, data: {"turbo-confirm": t("are_you_sure"), "batch-actions-target": "form", "action": "batch-actions#submit"}) do |f|
        concat(f.submit t("custom_table.batch_destroy"), class: "btn btn-danger btn-sm my-1")
      end)
  
      forms.join("").html_safe
  
    end

    # Override for custom logic (namespaces, inheritance, etc)
    def custom_table_has_show_route?(item)
      return (!url_for(controller: item.model_name.plural, action: "show", id: 1).nil?) rescue return false
    end  

    # Override for custom Delete button
    def custom_table_delete_button(path, options = {})
      options[:method] = "delete"
      options[:class] = "btn btn-outline-danger btn-sm action" if options[:class].nil?
      button_to t("destroy"), path, options
    end
  
    # Override for custom Edit button
    def custom_table_edit_button(path, options = {})
      options[:class] = "btn btn-outline-primary btn-sm action" if options[:class].nil?
      link_to(t("edit"), path, options)
    end  

  end
  
end
