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
    fields[:details] = {  }
    fields
  end


end
