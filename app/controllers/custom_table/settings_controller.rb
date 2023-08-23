module CustomTable
  class SettingsController < ::ApplicationController

    before_action :authenticate_user!
    skip_authorization_check # Because we do it manually

    layout false

    def edit
      @search_model = params[:id].constantize
      @representation = params[:representation].presence
      if !@representation.nil? && !helpers.custom_table_representations_for(@search_model).include?(@representation)
        render status: 404, html: "No such representation: #{@representation}"
        return
      end
    end

    # PATCH/PUT settings
    def update

      p = settings_params.to_h

      model = p[:model].constantize
      representation = p[:representation].presence

      defs = helpers.custom_table_fields_definition_for(model, representation)
      representations = helpers.custom_table_representations_for(model)

      if !representation.nil? && !representations.include?(representation)
        render status: 422, html: "No such representation: #{representation}"
        return
      end

      if defs.nil?
        optional_redirect_to profile_path, alert: t("custom_table.customization_not_allowed", model: model)
      end

      p[:fields].reject!{|k,v| defs[k.to_sym].nil?} # Clearing unknown fields
      p[:fields].each { |k, v| p[:fields][k] = (defs[k.to_sym][:appear] == :always) ? true : ActiveModel::Type::Boolean.new.cast(v) } 

      if current_user.save_custom_table_settings(model, representation, fields: p[:fields])
        flash[:notice] = t("custom_table.customization_saved")
      else
        # optional_redirect_to main_app.root_path, alert: t("custom_table.cannot_save_customization")
      end

    end

    # PATCH/PUT settings
    def destroy

      model = params[:id].constantize
      representation = params[:representation].presence

      defs = helpers.custom_table_fields_definition_for(model)
      representations = helpers.custom_table_representations_for(model)

      if !representation.nil? && !representations.include?(representation)
        render status: 422, html: "No such representation: #{representation}"
        return
      end

      if current_user.destroy_custom_table_settings(model, representation)
        flash[:notice] = t("custom_table.customization_saved")
      else
        # optional_redirect_to main_app.root_path, alert: t("custom_table.cannot_save_customization")
      end

    end


    private

      # Only allow a list of trusted parameters through.
      def settings_params
        params.require(:user).permit(:model, :representation, { fields: {} })
      end

  end
end