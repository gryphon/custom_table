module OrdersHelper

  def order_icon
    content_tag(:i, "", class: "bi bi-airplane-engines")
  end

  def order_custom_table_fields
    fields = {}
    fields[:code] = { search: { q: :code_cont, type: :text }, appear: :always, link_to_show: true }    
    fields[:name] = { search: { q: :name_cont, type: :text }, appear: :default }
    fields[:details] = {  }
    fields
  end


end
