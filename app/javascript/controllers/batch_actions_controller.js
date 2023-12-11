import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [ "checkbox", "form" ]

  connect() {
    if (this.hasFormTarget && this.hasCheckboxTarget) {
      console.log("Batch actions form", this.formTarget)
      this.refresh();
    }
  }

  submit(event) {

    if (!this.hasCheckboxTarget) {
      console.log("No checkbox targets at all")
      return
    }

    // Clearing any matching hidden fields from form
    this.formTarget.querySelectorAll('input[name="'+this.checkboxTargets[0].getAttribute("name")+'"]').forEach((cb) => {
      cb.parentNode.removeChild(cb)
    });

    // Adding selected fields to form as hiddens
    this.checkboxTargets.forEach((cb) => {

      if (!cb.checked) return;

      let input = document.createElement('input');
      input.setAttribute('name', cb.getAttribute("name"));
      input.setAttribute('value', cb.getAttribute("value"));
      input.setAttribute('type', "hidden")
  
      this.formTarget.appendChild(input);//append the input to the form
  
    })

    // event.preventDefault()
    console.log("Batch actions submit form")

  }

  refresh(){
    let v = false
    this.checkboxTargets.forEach((cb) => {
      if (cb.checked) v = true;
    });
    this.formTarget.querySelector('input[type="submit"]').disabled = !v
  }

}
