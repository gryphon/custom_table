import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [ "checkbox", "form", "activator" ]

  connect() {
    if (this.hasFormTarget && this.hasCheckboxTarget) {
      console.log("Batch actions form", this.formTarget)

      if (this.hasActivatorTarget) {
        this.element.classList.add("batch-hidden")
        this.activatorTarget.indeterminate = true
      }

      this.refresh();
    }
  }

  activate() {
    this.element.classList.remove("batch-hidden")
    this.activatorTarget.classList.add("d-none")

  }

  submit(event) {

    if (!this.hasCheckboxTarget) {
      console.log("No checkbox targets at all")
      return
    }

    // Clearing any matching hidden fields from form

    this.formTargets.forEach((form) => {
      form.querySelectorAll('input[name="'+this.checkboxTargets[0].getAttribute("name")+'"]').forEach((cb) => {
        cb.parentNode.removeChild(cb)
      });
    });

    // Adding selected fields to form as hiddens
    this.checkboxTargets.forEach((cb) => {

      if (!cb.checked) return;


      this.formTargets.forEach((form) => {
        let input = document.createElement('input');
        input.setAttribute('name', cb.getAttribute("name"));
        input.setAttribute('value', cb.getAttribute("value"));
        input.setAttribute('type', "hidden")
        form.appendChild(input);//append the input to the form
      });
  
    })

    // event.preventDefault()
    console.log("Batch actions submit form")

  }

  refresh(){

    if (!this.hasFormTarget) return;

    let v = false
    this.checkboxTargets.forEach((cb) => {
      if (cb.checked) v = true;
    });

    this.formTargets.forEach((form) => {
      form.querySelector('input[type="submit"]').disabled = !v
    })

  }

}
