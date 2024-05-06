class DatePickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    set_html_options
    set_value_html_option

    classes = ["input-group"]

    input_html_options[:data] ||= {}
    input_html_options[:data]["controller"] = "flatpickr"

    picker_options = (options[:picker] || {}).merge!(flatpickr_options)

    picker_options.each do |k, v|
      input_html_options[:data]["flatpickr-#{k}-value"] = v
    end

    input_html_options[:data]["flatpickr-locale-value"] = I18n.locale

    classes.push("input-group-sm") if input_html_options[:class].include? "input-sm"

    # template.content_tag :div, class: classes do
    input = super(wrapper_options) # leave StringInput do the real rendering
    # end
  end

  def input_html_classes
    super.push '' # 'form-control'
  end

  private

  def set_html_options
    input_html_options[:type] = 'text'
    input_html_options[:data] ||= {}
  end

  def set_value_html_option
    # return unless value.present?
    # input_html_options[:value] ||= I18n.localize(value, format: display_pattern)
  end

  def value
    v = object.send(attribute_name) if object.respond_to?(attribute_name) || object.is_a?(Ransack::Search)
    v = v.to_date if v.is_a?(String)
    v
  end

  def flatpickr_options
    {}
  end

end
