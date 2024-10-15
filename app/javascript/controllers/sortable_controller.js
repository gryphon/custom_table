import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs";
import { patch } from "@rails/request.js"
 
export default class extends Controller {
  static values = {
    group: {type: String, default: "group"},
    resourceName: String,
    paramName: {type: String, default: "position"},
    responseKind: {type: String, default: "html"},
    animation: {type: Number, default: 150},
    handle: String,
  }

  connect() {
    new Sortable(this.element, {
      group: this.groupValue,
      handle: this.handleValue,
      animation: this.animationValue,
      onUpdate: ({ item, newIndex }) => {this.onUpdate({ item, newIndex })},
      onAdd: ({ item, newIndex }) => {this.onUpdate({ item, newIndex })}
    })
  }

  async onUpdate({ item, newIndex }) {
    if (!item.dataset.sortableUpdateUrl) return

    const listId = this.element.dataset.sortableListId
    const param = this.resourceNameValue ? `${this.resourceNameValue}[${this.paramNameValue}]` : this.paramNameValue

    const data = new FormData()
    data.append(param, newIndex + 1)
    if (listId) {
      const list_param = this.resourceNameValue ? `${this.resourceNameValue}[parent_id]` : this.paramNameValue
      data.append(list_param, listId)
    }

    return await patch(item.dataset.sortableUpdateUrl, { body: data, responseKind: this.responseKindValue })
  }
}
