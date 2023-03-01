module CustomTableHelper
  
  def custom_table_form_for(record, options = {}, &block)
    options[:url] = "" if options[:url].nil?
    options[:method] = :get

    inline_form_for(record, options, &block)
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
        return l(item.send(field), format: :short) rescue ""
      else
        return item.send(field) rescue ""
      end
    end
    
  end

  # Returns list of fields according user settings
  def custom_table_fields_for(model, representation: nil, current_search: {}, predefined_fields: nil)

    fields = []
    current_search = {} if current_search.nil?

    model_fields = custom_table_fields_definition_for(model)

    if (!predefined_fields.nil?)
      return model_fields.select {|k,v| predefined_fields.include?(k) }
    end

    fields_key = model.model_name.plural
    fields_key += "-#{representation}" unless representation.nil?

    if !current_user.nil? && !current_user.custom_table.nil? && !current_user.custom_table[fields_key].nil?
      # Use saved user settings for the model
      s = current_user.custom_table[fields_key]
      selected_fields = model_fields.select { |x, y| [:always].include?(y[:appear]) || s.include?(x.to_s) || current_search.keys.include?(x.to_s) }.keys
    else
      # Use default model settings
      selected_fields = model_fields.select { |x, y| [:always, :default].include?(y[:appear]) || current_search.keys.include?(x.to_s) }.keys
    end

    # Filter selection again with model settings for sure
    model_fields.select { |k, _v| selected_fields.include?(k) }.compact

  end

  def custom_table_customizable_fields_for(model)
    model_fields = custom_table_fields_definition_for(model)
    model_fields.reject {|k,v| [:always, :export].include?(v[:appear]) }.collect{|x,y| [y[:label].nil? ? model.human_attribute_name(x) : y[:label],x]}
  end

  def custom_table_fields_definition_for(model)
    helper_name = "#{model.model_name.singular}_custom_table_fields"
    if (! self.class.method_defined?(helper_name))
      raise "#{helper_name} helper is not defined so we do not know how to render custom_table"
    end
    return self.send("#{helper_name}")
  end

  def current_user_has_custom_fields_for?(model)
    return false if current_user.nil?
    custom_table_fields_for(model).reject { |_x, y| [:always].exclude?(y[:appear]) }.keys.count.positive?
  end

  def custom_table **params
    render "custom_table/table", params do
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



end
