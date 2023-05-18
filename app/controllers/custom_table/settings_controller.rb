module CustomTable
  class SettingsController < ::ApplicationController

    before_action :authenticate_user!

    layout false

    def edit
      @search_model = params[:id].constantize
      @representation = params[:representation]
    end

    # PATCH/PUT settings
    def update

      p = settings_params.to_h

      model = p[:model].constantize
      defs = helpers.custom_table_fields_definition_for(model)

      if defs.nil?
        optional_redirect_to profile_path, alert: t("custom_table.customization_not_allowed", model: model)
      end

      p[:fields].reject!{|k,v| defs[k.to_sym].nil?} # Clearing unknown fields
      p[:fields].each { |k, v| p[:fields][k] = (defs[k.to_sym][:appear] == :always) ? true : ActiveModel::Type::Boolean.new.cast(v) } 

      if current_user.save_custom_table_settings(model, fields: p[:fields])
        flash[:notice] = t("custom_table.customization_saved")
      else
        # optional_redirect_to main_app.root_path, alert: t("custom_table.cannot_save_customization")
      end

    end

    private

      # Only allow a list of trusted parameters through.
      def settings_params
        params.require(:user).permit(:model, { fields: {} })
      end

  end
end