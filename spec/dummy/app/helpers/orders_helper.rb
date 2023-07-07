module OrdersHelper

  def order_icon
    content_tag(:i, "", class: "bi bi-airplane-engines")
  end

  def order_custom_table_representations
    ["another"]
  end

  def order_custom_table_fields
    fields = {}
    fields[:code] = { search: { q: :code_cont, type: :text }, appear: :always, sort: {default_order: :desc}, link_to_show: true }    
    fields[:name] = { search: { q: :name_cont, type: :text }, appear: :default }

    fields[:active] = { search: { q: :active_eq, type: :switch }, appear: :default }
    fields[:delivery] = { search: { q: :delivery_eq, type: :enum }, appear: :default }
    fields[:priority] = { search: { q: :priority_eq, type: :text }, appear: :default }
    fields[:ordered_at] = { search: { q: [:ordered_at_gteq, :ordered_at_lteq], type: :dates }, appear: :default }

    fields[:details] = {  }

    fields[:user] = { search: {q: :user_id_eq, type: :select, collection: User.all}, appear: :default }

    fields
  end

  def order_another_priority order
    "ANOT#{order.priority}HER"
  end

  def order_name order
    "FILTER#{order.name}ED"
  end

  def passed_custom_actions_for_orders order
    "PASSED_CUSTOM_ACTIONS"
  end

  def actions_order_custom_table_actions item
    "OLEILO"
  end
  
end
