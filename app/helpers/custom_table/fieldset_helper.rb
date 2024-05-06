module CustomTable

  module FieldsetHelper

    class FieldsetBuilder

      def initialize(object, template, **params)
        @object = object
        @template = template
        @params = params
      end

      def has_editable?
        @template.respond_to?(:editable)
      end

      def field column, **params, &block

        defs = @template.custom_table_fields_definition_for_field(@object.class, column) rescue nil

        params = {} if params.nil?
        params = params.deep_merge(@params)
        params[:editable] = true if params[:editable].nil?
        params[:adaptive] = false if params[:adaptive].nil?

        if params[:label].nil?
          if !defs.nil? && !defs[:label].blank?
            params[:label] = defs[:label]
          else
            params[:label] = @object.class.human_attribute_name(column) 
          end
        end


        params[:template] = "field" if params[:template].nil?
        params[:column] = column
        params[:object] = @object

        hint_key = "simple_form.hints.#{@object.model_name.singular}.#{column}"
        if I18n.exists?(hint_key)
          params[:hint] = I18n.t(hint_key)
        end

        @template.render "custom_table/#{params[:template]}", **params do
          if params[:editable] && has_editable?
            params[:editable_params] = {} if params[:editable_params].nil?
            editable_field = params[:editable_params][:field] || column
            @template.editable @object, editable_field, **params[:editable_params] do
              if block_given?
                yield
              else
                @template.field_value_for(@object, column, definitions: defs)
              end
            end
          else
            if block_given?
              yield
            else
              @template.field_value_for(@object, column, definitions: defs)
            end
          end

        end
      end

    end

    def fieldset object=nil, **params, &block

      builder = FieldsetBuilder.new(object, self, **params)
      output = capture(builder, &block)

      render "custom_table/fieldset" do
        output
      end

    end

    def field object, column, **params, &block

      params[:template] = "field_plain"

      builder = FieldsetBuilder.new(object, self, **params)

      builder.field(column, **params, &block)

    end

  end

end