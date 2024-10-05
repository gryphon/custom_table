module CustomTableSettings

  extend ActiveSupport::Concern

  included do
    serialize :custom_table, coder: YAML
  end

  def save_custom_table_settings model_class, variant = nil, fields: nil, sorts: nil, per_page: nil

    model = model_class.model_name.to_s
    key = model
    key = "#{model}-#{variant}" if !variant.nil?
    self.custom_table = {} if self.custom_table.nil?
    self.custom_table[key] = {} if self.custom_table[key].nil?
    self.custom_table[key][:model] = model
    self.custom_table[key][:fields] = fields.symbolize_keys if !fields.nil?
    self.custom_table[key][:sorts] = sorts if !sorts.nil?
    self.custom_table[key][:per_page] = per_page.to_i if !per_page.nil? && [25, 50, 100].include?(per_page.to_i)

    return save!
    # write_attribute :custom_table, (custom_table||{}).merge(ss)
  end


  def destroy_custom_table_settings model_class, variant = nil

    return true if self.custom_table.nil?

    model = model_class.model_name.to_s
    key = model
    key = "#{model}-#{variant}" if !variant.nil?

    return true if self.custom_table[key].nil?

    self.custom_table.delete(key)

    return save
    # write_attribute :custom_table, (custom_table||{}).merge(ss)
  end

end
