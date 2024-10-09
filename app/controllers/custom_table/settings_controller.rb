module CustomTable
  class SettingsController < ::ApplicationController

    before_action :authenticate_user!
    skip_authorization_check # Because we do it manually

    layout false

    def edit
      @search_model = get_model(params[:id])
      @variant = params[:variant].presence
      if !@variant.nil? && !helpers.custom_table_variants_for(@search_model).include?(@variant)
        render status: 404, html: "No such variant: #{@variant}"
        return
      end
    end

    # PATCH/PUT settings
    def update

      p = settings_params.to_h

      model = get_model(p[:model])
      variant = p[:variant].presence

      defs = helpers.custom_table_fields_definition_for(model, variant)
      variants = helpers.custom_table_variants_for(model)

      if !variant.nil? && !variants.include?(variant)
        render status: 422, html: "No such variant: #{variant}"
        return
      end

      if defs.nil?
        optional_redirect_to profile_path, alert: t("custom_table.customization_not_allowed", model: model)
      end

      p[:fields].reject!{|k,v| defs[k.to_sym].nil?} # Clearing unknown fields
      p[:fields].each { |k, v| p[:fields][k] = (defs[k.to_sym][:appear] == :always) ? true : ActiveModel::Type::Boolean.new.cast(v) } 

      if current_user.save_custom_table_settings(model, variant, fields: p[:fields])
        flash[:notice] = t("custom_table.customization_saved")
        respond_to do |format|
          format.html { render nil, status: :ok }
          format.turbo_stream {render turbo_stream: turbo_stream.action(:refresh, nil)}
        end
      else
        # optional_redirect_to main_app.root_path, alert: t("custom_table.cannot_save_customization")
      end

    end

    # PATCH/PUT settings
    def destroy

      model = get_model(params[:id])
      variant = params[:variant].presence

      defs = helpers.custom_table_fields_definition_for(model)
      variants = helpers.custom_table_variants_for(model)

      if !variant.nil? && !variants.include?(variant)
        render status: 422, html: "No such variant: #{variant}"
        return
      end

      if current_user.destroy_custom_table_settings(model, variant)
        flash[:notice] = t("custom_table.customization_saved")
        respond_to do |format|
          format.html { render nil, status: :ok }
          format.turbo_stream {render turbo_stream: turbo_stream.action(:refresh, nil)}
        end
      else
        # optional_redirect_to main_app.root_path, alert: t("custom_table.cannot_save_customization")
      end

    end


    private

      def get_model model
        helper_name = "#{model.underscore}_custom_table_fields"
        if (! helpers.respond_to?(helper_name))
          return nil
        else
          return model.constantize
        end
      end

      # Only allow a list of trusted parameters through.
      def settings_params
        params.require(:user).permit(:model, :variant, { fields: {} })
      end

  end
end