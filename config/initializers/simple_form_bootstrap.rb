# frozen_string_literal: true

# Please do not make direct changes to this file!
# This generator is maintained by the community around simple_form-bootstrap:
# https://github.com/heartcombo/simple_form-bootstrap
# All future development, tests, and organization should happen there.
# Background history: https://github.com/heartcombo/simple_form/issues/1561

# Uncomment this and change the path if necessary to include your own
# components.
# See https://github.com/heartcombo/simple_form#custom-components
# to know more about custom components.

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Default class for buttons
  config.button_class = 'btn'

  # Define the default class of the input wrapper of the boolean input.
  config.boolean_label_class = 'form-check-label'

  # How the label text should be generated altogether with the required text.
  config.label_text = lambda { |label, required, explicit_label| "#{label} #{required}" }

  # Define the way to render check boxes / radio buttons with labels.
  config.boolean_style = :inline

  # You can wrap each item in a collection of radio/check boxes with a tag
  config.item_wrapper_tag = :div

  # Defines if the default input wrapper class should be included in radio
  # collection wrappers.
  config.include_default_input_wrapper_class = false

  # CSS class to add for error notification helper.
  config.error_notification_class = 'alert alert-danger'

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # :to_sentence to list all errors for each field.
  config.error_method = :to_sentence

  # add validation classes to `input_field`
  config.input_field_error_class = 'is-invalid'
  #config.input_field_valid_class = 'is-valid'
  config.input_field_valid_class = '' # Do not need to show valid class


  # vertical input for radio buttons and check boxes
  config.wrappers :ct_vertical_collection, item_wrapper_class: 'form-check', item_label_class: 'form-check-label', tag: 'fieldset', class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
      ba.use :label_text
    end
    b.use :input, class: 'form-check-input', error_class: 'is-invalid'#, valid_class: 'is-valid'
    b.use :full_error, wrap_with: { class: 'invalid-feedback d-block' }
    b.use :hint, wrap_with: { class: 'form-text' }
  end

  # vertical input for inline radio buttons and check boxes
  config.wrappers :ct_vertical_collection_inline, item_wrapper_class: 'form-check form-check-inline', item_label_class: 'form-check-label', tag: 'fieldset', class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: 'legend', class: 'col-form-label pt-0' do |ba|
      ba.use :label_text
    end
    b.use :input, class: 'form-check-input', error_class: 'is-invalid'#, valid_class: 'is-valid'
    b.use :full_error, wrap_with: { class: 'invalid-feedback d-block' }
    b.use :hint, wrap_with: { class: 'form-text' }
  end

  # inline forms
  #
  # inline default_wrapper
  config.wrappers :ct_inline_form, class: 'col-6' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'visually-hidden'

    b.use :input, class: 'form-control', error_class: 'is-invalid'#, valid_class: 'is-valid'
    b.use :error, wrap_with: { class: 'invalid-feedback' }
    b.optional :hint, wrap_with: { class: 'form-text' }
  end

  # vertical select input
  config.wrappers :ct_inline_select, class: 'col-6' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'form-label visually-hidden'
    b.use :input, class: 'form-select', error_class: 'is-invalid'#, valid_class: 'is-valid'
    b.use :full_error, wrap_with: { class: 'invalid-feedback' }
    b.use :hint, wrap_with: { class: 'form-text' }
  end

  # vertical select input
  config.wrappers :ct_inline_element, class: 'col-6' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'form-label'
    b.use :input, class: 'form-control', error_class: 'is-invalid'#, valid_class: 'is-valid'
    b.use :full_error, wrap_with: { class: 'invalid-feedback' }
    b.use :hint, wrap_with: { class: 'form-text' }
  end
  
  # inline input for boolean
  config.wrappers :ct_inline_boolean, class: 'col-6' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, class: 'form-check' do |bb|
      bb.use :input, class: 'form-check-input', error_class: 'is-invalid'#, valid_class: 'is-valid'
      bb.use :label, class: 'form-check-label'
      bb.use :error, wrap_with: { class: 'invalid-feedback' }
      bb.optional :hint, wrap_with: { class: 'form-text' }
    end
  end


  # bootstrap custom forms
  #
  # custom input switch for boolean
  config.wrappers :ct_custom_boolean_switch, class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, tag: 'div', class: 'form-check form-switch' do |bb|
      bb.use :input, class: 'form-check-input', error_class: 'is-invalid'#, valid_class: 'is-valid'
      bb.use :label, class: 'form-check-label'
      bb.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      bb.use :hint, wrap_with: { class: 'form-text' }
    end
  end

  # Input Group - custom component
  # see example app and config at https://github.com/heartcombo/simple_form-bootstrap
  config.wrappers :ct_input_group, class: 'mb-3' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'form-label'
    b.wrapper :input_group_tag, class: 'input-group' do |ba|
      ba.optional :prepend
      ba.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
      ba.optional :append
      ba.use :full_error, wrap_with: { class: 'invalid-feedback' }
    end
    b.use :hint, wrap_with: { class: 'form-text' }
  end


  # # Custom wrappers for input types. This should be a hash containing an input
  # # type as key and the wrapper that will be used for all inputs with specified type.
  # config.wrapper_mappings = {
  #   boolean:       :vertical_boolean,
  #   check_boxes:   :vertical_collection,
  #   date:          :vertical_multi_select,
  #   datetime:      :vertical_multi_select,
  #   file:          :vertical_file,
  #   radio_buttons: :vertical_collection,
  #   range:         :vertical_range,
  #   time:          :vertical_multi_select,
  #   select:        :vertical_select
  # }
end
