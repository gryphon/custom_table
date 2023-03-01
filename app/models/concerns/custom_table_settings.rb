module CustomTableSettings

  extend ActiveSupport::Concern

  included do
    serialize :custom_table
  end

  def set_custom_table=(ss)
    self.custom_table = {} if custom_table.nil?
    custom_table[ss[:model]] = ss[:fields].reject(&:empty?)
    # write_attribute :custom_table, (custom_table||{}).merge(ss)
  end

  # def has_custom_fields_for?(model)
  #   model.custom_table_fields(self).reject { |_x, y| [:always].exclude?(y[:appear]) }.keys.count.positive?
  # end

  # # Returns list of fields according user settings
  # def custom_table_for(m, representation = nil, current_search = {})
  #   fields = []

  #   current_search = {} if current_search.nil?

  #   fields_key = m.model_name.plural
  #   fields_key += "-#{representation}" unless representation.nil?

  #   if !custom_table.nil? && !custom_table[fields_key].nil?
  #     s = custom_table[fields_key]
  #     fields = m.custom_table_fields(self).select { |x, y| [:always].include?(y[:appear]) || s.include?(x.to_s) || current_search.keys.include?(x.to_s) }.keys
  #   else
  #     fields = m.custom_table_fields(self).select { |x, y| [:always, :default].include?(y[:appear]) || current_search.keys.include?(x.to_s) }.keys
  #   end

  #   m.custom_table_fields(self).select { |k, _v| fields.include?(k) }.compact
  # end
end
