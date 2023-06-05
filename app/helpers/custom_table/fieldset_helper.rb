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

        defs = custom_table_fields_definition_for_field(@object.class, column) rescue nil

        params = {} if params.nil?
        params = params.deep_merge(@params)
        params[:editable] = true if params[:editable].nil?

        if params[:label].nil?
          if !defs.nil? && !defs[:label].blank?
            params[:label] = defs[:label].nil?
          else
            params[:label] = @object.class.human_attribute_name(column) 
          end
        end

        if block_given?
          # We will render provided block
          @template.field params[:label], &block
        else
          @template.field params[:label] do
            if params[:editable] && has_editable?
              params[:editable_params] = {} if params[:editable_params].nil?
              @template.editable @object, column, **params[:editable_params] do
                @template.field_value_for(@object, column)
              end
            else
              @template.field_value_for(@object, column)
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

    def field label, adaptive: false, **params
      params[:label] = label
      params[:adaptive] = adaptive
      render "custom_table/field", **params do
        yield
      end
    end
  end

end