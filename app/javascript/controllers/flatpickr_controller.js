import { Controller } from "@hotwired/stimulus"
import Flatpickr from 'flatpickr'
import { Russian } from "flatpickr/dist/l10n/ru.js"
import English from "flatpickr/dist/l10n/default.js"
import monthSelectPlugin, {
  Config as PluginConfig,
} from "flatpickr/dist/plugins/monthSelect";
 
// Connects to data-controller="flatpickr"
export default class extends Controller {
  static values = {
    mode: String,
    date: String,
    locale: String,
    month: {type: Boolean, default: false},
    opened: {type: Boolean, default: false},
    time: {type: Boolean, default: false}
  }

  initialize() {

    let l = navigator.language || navigator.languages[0];

    let locale = English 
    if (l == "ru" || l == "be" || l == "uk") locale = Russian

    this.config = {
      altInput: true,
      allowInput: true,
      altFormat: "d.m.y",
      locale: locale,
      plugins: []
    }

    if (this.monthValue) {
      this.config.plugins.push(
        new monthSelectPlugin({
          shorthand: false, //defaults to false
          dateFormat: "Y-m", //defaults to "F Y"
          altFormat: "F Y", //defaults to "F Y"
          theme: "light" // defaults to "light"
        })
      )
    }
    
    console.log("Flatpickr config", this.config)

  }

  dateValueChanged() {
    if (this.dateValue) this.fp.setDate(this.dateValue)
  }

  connect() {
    //this._initializeOptions()

    if (this.modeValue) this.config.mode = this.modeValue;

    this.config.enableTime = this.timeValue;
    if (this.config.enableTime) {
      this.config.altFormat = "d.m.y H:i"
    }

    this.fp = Flatpickr(this.element, {
      ...this.config
    })

    if (this.openedValue) this.fp.open();

    console.log("Flatpickr initialized", this.fp)

    document.addEventListener("turbo:morph", (event) => {
      this.connect(); // Reinitialize
    });    

  }


  openedValueChanged() {
    console.log("Opened Value Changed", this.openedValue)
    if (this.openedValue) this.fp.open();
  }

  disconnect() {
    //const value = this.inputTarget.value
    this.fp.destroy()
    //this.inputTarget.value = value
  }

  _initializeOptions() {
    Object.keys(options).forEach((optionType) => {
      const optionsCamelCase = options[optionType]
      optionsCamelCase.forEach((option) => {
        const optionKebab = kebabCase(option)
        if (this.data.has(optionKebab)) {
          this.config[option] = this[`_${optionType}`](optionKebab)
        }
      })
    })
    this._handleDaysOfWeek()
  }

}
