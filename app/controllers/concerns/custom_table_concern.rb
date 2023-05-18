module CustomTableConcern
  extend ActiveSupport::Concern

  included do
    helper CustomTable::ApplicationHelper
  end

  class_methods do 
  end

  def custom_table collection, representation = nil, paginate: true, default_sorts: "created_at asc", default_query: nil
    @q = collection.ransack(params[:q])

    customization = helpers.custom_table_user_customization_for(collection.model, representation)
    per_page = params[:per] || customization&.dig(:per_page).presence || 25
    @q.sorts = customization&.dig(:sorts).presence || default_sorts if @q.sorts.empty?

    collection = @q.result(distict: true)
    collection = collection.page(params[:page]).per(per_page) if format_web && paginate

    if !current_user.nil?
      current_user.save_custom_table_settings(collection.model, per_page: params[:per]) if !params[:per].nil? && paginate
      current_user.save_custom_table_settings(collection.model, sorts: "#{@q.sorts[0].name} #{@q.sorts[0].dir}") if !params[:q].nil? && !params[:q][:s].nil? && !@q.nil? && !@q.sorts[0].nil? && !@q.sorts[0].name.nil?
    end

    return collection
  end

  private
  

end