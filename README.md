# Custom Table

Gem provides powerful set of functionality for showing tables of data:
* Generated table and filter panel for any model
* Declare fields that should be displayed, filtered or sorted
* Customize visible fields for each user
* Exporting table to XLSX (helpers for CAXLSX, fast_excel and CSV)

Requires and works only with Ransack, Kaminari, Bootstrap, simple_form and Turbo.

## Setup

* Run ```rails generate custom_table install``` to create User migration and Initializer
* Generate base helpers
* Add CustomTable engine routes (for table columns customization feature)
`mount CustomTable::Engine, at: "/custom_table"`
* Add CSS import to your application.css: 
```@import 'custom_table/table.css';```
* Add Stimulus controllers to your JS:
```
import TableController from "custom_table/app/javascript/controllers/table_controller.js"
application.register("table", TableController)

import BatchActionsController from "custom_table/app/javascript/controllers/batch_actions_controller.js"
application.register("batch-actions", BatchActionsController)

import FlatpickrController from "custom_table/app/javascript/controllers/flatpickr_controller.js"
application.register("flatpickr", FlatpickrController)

```
* Add concern to User model
* Declare your first model

## Declaring fields

The most important part of using this gem is to correctly declare fields available for showing in table.

This should be declared in helper named by this pattern: 

```{singular_model_name}_custom_table_fields```

And shold return hash of field definitions:

e.g.

    def vegetable_custom_table_fields
      fields = {}
      fields[:color] = { search: { q: :color_eq, type: :text }, appear: :default }
      return fields
    end

Use attribute name as key if possbile. Table will try to get most of options automatically from model if you pass regular attribute.

### Fields declaration options

* ```label``` adds label to the field. Will try to find human attribute name by default
* ```if``` set this boolean to false if you need to hide field. Default: shown
* ```search``` contains search parameters. Skip this if search is not available for this fields
* * ```q``` ransack's "q" search marcher which is used to search by the field. For range use array of two elements, e.g. ```[:created_at_gteq, :created_at_lteq]```
* * ```type``` type of search element to draw
* * ```sm_visible``` set to true to make this field search always be visible in small screens (by default all fields collapsed)
* ```appear``` controls visibility of the field. Default value is hidden if not specially selected
* * ```default``` will appear by default
* * ```always``` will always appear
* * ```export``` will appear only in XLSX export
* ```link_to_show``` if true, this fields will have link to show page of item
* ```sort``` controls sorting ability for the fields (disabled by default). Use ```true``` or ```{default_order: :asc|:desc}```
* ```amount``` if true, applies number-specific formatting to cells (right align)
* ```helper``` helper name (will be used instead default, see below)
* ```total_scope``` scope which will be applied to collection to count total for rows. By defalt it takes sum(:field)

## Controller setup

This gem provides custom_table method for your controller which does Ransack search and Kaminari pagination for you:

    def index
      @vegetables = custom_table(@vegetables)
    end

Is equivalent to:

    def index
      @q = @vegetables.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty? # Sets default sorting for ransack

      @vegetables = @q.result(distinct: true)
      @vegetables = @vegetables.page(params[:page]).per(params[:per] || 25)
    end

Optional parameters are:

* ```default_sorts``` - ```string``` sorting order if user not selected it (default to ```created_at desc```)
* ```default_query``` - default ransack ```q``` object. Default is empty 

## Rendering tables

Invoke this in your index to display table:
```custom_table_data collection: @vegetables```

Options available are:

* Second parameter is variant (can be skipped if you dont use variants)
* ```collection``` is the only required option. Contains paged collection from your controller
* ```parent``` parent resource for inherited routes
* ```skip_fields``` array of field names as symbols. Removes specific fields from table
* ```skip_actions``` removes all actions
* ```skip_default_actions``` removes default actions
* ```actions``` helper name for custom actions. Table also looks for ```{singular_model_name}_custom_table_actions``` helper presence
* ```totals``` object of fields to show totals. Use symbols as keys and pass value or left nil to let table try to count total based on raw/field value
* ```paginate``` set to false to skip pagination
* ```last_page``` set to false to disable last page count request for performance
* ```quick_filter``` set to true to enable simple full-text client-side search
* ```with_select``` allows to add checkboxes toggler. Pass helper name which has (item, position) as parameters
* ```tree``` set to true if you have parent-child relation and you want to show records grouped by parent. Be sure to disable pagination as it will only group current page records 
* ```group_by``` set to helper name to group records by result of it. Be sure to disable pagination as it will only group current page records 
* ```expanded``` expand grouped or trees by default
* ```sortable``` set to true to allow to sort models. Model needs to have ```position``` attribute and use ```acts_as_list``` gem to be sorted. Gem uses ```SortableController``` JS component based on top of SortableJS for sorting. Add `order(:position)` after `custom_table` call in controller to order items correctly.
* ```per_page``` set to false to hide items-per-page selector
* ```paginator_position``` set to `top` or `bottom`. default is `bottom`

## Rendering search panel

Use this helper in order to show filter panel:

```custom_table_filter search_model: Vegetable```

Options:

* ```search_model``` model class to use with this filter. The only required parameter.
* ```hide_customization``` hides customization button
* ```fields``` if you want to have pre-defined fields, not from model definition

## Displaying custom fields

You can declare fields which your model doesn't have. In this case table can't render field value so you have to provide helpers for rendering the field. Table renderer will try to look for these helpers in prioritizing order:

* ```#{singular_model_name}_#{field}_field``` to avoid naming collisions
* ```#{singular_model_name}_#{field}``` best choise for most projects
* ```#{singular_model_name}_#{field}_raw``` use this to produce non-decorated raw data which can be used in tables

If helper is not accessible table will try to render item via following methods:

* Association via ```to_s``` method
* Numeric attribute via ```amount``` helper which formats number
* Raw text attributes
* Boolean attribute via ```boolean_icon``` helper. Uses bootstrap icons and can be overriden

If you use variant, following helper will have the priority over all options:
* ```#{singular_model_name}_#{variant}_#{field}_field```
* ```#{singular_model_name}_#{variant}_#{field}```

## Displaying custom actions


## Customizing user columns

Enable Rails Turbo, Bootstrap, Stimulus in your application.js:

```
  import "@hotwired/turbo-rails"
  import "@hotwired/stimulus"
  import "bootstrap"
```

Add turbo-remote-modal Gem: https://github.com/gryphon/turbo_remote_modal

Add CustomTable as engine to your routes:

`mount CustomTable::Engine, at: "/custom_table"`

And ```custom_table``` attribute as text to your model to store search configuration

Search Settings button will show up automatically if you have at least one customizable field and your app has users support via `current_user` and `user_signed_in?` view helpers (Devise-compartible).

You can also show settings button separatelly. It uses Rails Turbo and you need to declare ```remote-modal``` Turbo Tag within your HTML body.

## Variants

For each table you can declare additional variants (set of parameters to be saved to user customization).

Important to note that you need to explicitly set list of available variants. Declare the following helper function:

```{singular_model_name}_custom_table_fields```

Which returns the array of available variant.

Then just pass variant to filter and data helpers.

## Table Stimulus helper

## Authorization support (Cancancan compartible)

If your app provides `can?` view helper custom_table will check if user can update or destroy record while showing table row buttons.

## Batch Actions

You can set ```batch``` option to field definition to enable batch editing

You need to set following options to ```custom_table_data```:

* ```batch_actions``` - shows batch actions. Set to helper name for custom actions
* ```batch_activator``` - shows more compact batch selecting view. Enabled by default

You have to declare the following routes for the resource:

* ```batch_edit``` - POST with ```plural model name``` array will be requested to show form for mass editing
* ```batch_update``` - POST with ```plural model name``` array will be requested to update records with params
* ```batch_destroy``` - DELETE with ```plural model name``` array will be requested to delete records

## Downloading data as XLSX table

This gem also provide partial for exporting all available columns as XLSX file via CAXLSX gem:

    wb = xlsx_package.workbook
    wb.add_worksheet(name: "Aircrafts") do |sheet|
      render 'custom_table/table', sheet: sheet, collection: @aircrafts.except(:limit, :offset)
    end

## Using fieldset helper for show actions

You can use the same fields declared for table within show views.
This also can be used without any table fields declaration and setup.

The simpliest case here is (haml):

    = fieldset @instance do |fs|
      = fs.field :name

It will produce bootstrap fieldset formatting as well as value logic from tables.

Fieldset formatting can be overriden via views (custom_table/_fieldset and custom_table/field)

By default fieldset is integrated with ```turbo_editable``` gem and each field is wrapped with it. You can disable it by passing ```editable: false``` as param to fieldset of field.

Options available are:

* ```label``` - if it cannot be received via field definition 
* ```editable_params``` - hash of params to be passed to editable

All options from fieldset are proxied to field. So you can declare it once if suitable.

You can declare how each field is displayed. Just add it as block within field:

    = fieldset @instance do |fs|
      = fs.field :name do
        = @instance.name.upcase

## Testing hints for your app

Use ```custom_table_use_all_fields``` GET param with any value to show all available fields in your feature tests

## Development

Running tests: 

* `bundle install`
* `bundle exec rails db:migrate`
* `RAILS_ENV=test bundle exec rspec`


