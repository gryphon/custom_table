module CustomTableHelper

  def custom_table_delete_button(path, options = {})
    options[:method] = "delete"
    button_to "Destroy", path, options
  end

  def custom_table_edit_button(path, options = {})
    link_to "Edit", path, options
  end  

  def custom_table_has_show_route?(item)
    return (!url_for(controller: item.model_name.plural, action: "show", id: 1).nil?) rescue return false
  end

end
