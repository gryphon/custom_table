import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [ "move", "hide", "sum", "sumval" ]

  connect() {
    if (this.hasMoveTarget) this.moveup();
    if (this.hasHideTarget) this.hideEmpty();

    if (!this.hasSumTarget) {
      let d = document.createElement("caption")
      d.classList.add("d-none", "table-sum")
      d.dataset.tableTarget = "sum"
      d.innerHTML = '<i class="fa fa-times-circle mt-1 float-start" data-action="click->table#clearSum"></i><span data-table-target="sumval"></span>'
      this.element.appendChild(d)
    }

    this.element.querySelector("tbody").addEventListener('click', (e) => {
      const cell = e.target.closest('td.amount');
      if (!cell) {return;} // Quit, not clicked on a cell
      if (!isNaN(this.cellValue(cell))) {
        const row = cell.parentElement;
        cell.classList.toggle("selected")
        this.showSum();
      } 
    });

  }

  moveup() {
    console.log("Moving row")
    let elm = this.moveTarget
    let tbl = elm.parentElement
    this.moveTarget.remove()
    tbl.prepend(elm)
  }

  showSum(){
    let elements = this.element.querySelectorAll("td.selected");
    if (elements.length == 0) {
      this.sumTarget.classList.add("d-none")
      return
    }
    this.sumTarget.classList.remove("d-none")
    let sum = 0
    elements.forEach((e) => {
      sum += this.cellValue(e)
    })
    if (this.hasSumTarget) {
      this.sumvalTarget.innerHTML = "SUM="+Math.round(sum * 100) / 100
    }
  }

  cellValue(e){
    if (e.querySelector("span[data-raw]")) {
      return Number(e.querySelector("span[data-raw]").dataset.raw);
    }
    else {
      return Number(e.innerText.replace(/\s,/g, ''));
    }
  }

  clearSum(){
    this.element.querySelectorAll("td.selected").forEach((e) => {
      e.classList.remove("selected")
    })
    this.showSum();
  }

  hideEmpty(){

    console.log("Hiding empty!!!")

    this.element.querySelectorAll("tr th").forEach((e, i) => {

      if (!e.classList.contains("hide-empty")) return;

      let tds = this.element.querySelectorAll("tr td:nth-child(".concat(i+1, ")"));
      if (Array.prototype.slice.call(tds).every(td => { return (td.textContent == "0" || !td.textContent || Number(td.textContent) == 0); })) {
        e.hidden = true;
        tds.forEach(e => {e.hidden = true})
      }

    });

  }

  toggle(event) {
    let params = event.params
    console.log("Table Toggle", event.currentTarget.innerHTML)
    this.element.querySelectorAll(params.css).forEach((e, i) => {
      e.classList.toggle("d-none")
    });
    event.currentTarget.classList.toggle("opened")
  }

  search(event) {
    console.log("Table Search", event.currentTarget.value)
    this.element.querySelectorAll("tbody tr").forEach((tr) => {
      if (tr.innerText.toLowerCase().includes(event.currentTarget.value.toLowerCase())) {
        tr.classList.remove("d-none")
      } else {
        tr.classList.add("d-none")
      }
    })
  }

}
