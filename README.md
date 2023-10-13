# Custom Table

Provides powerful set of functionality for showing tables of data:
* Generated table and filter panel for any model
* Declare fields that should be displayed, filtered or sorted
* Customize visible fields for each user
* Exporting table to XLSX

## Setup

* Run ```rails generate custom_table install``` to create User migration and Initializer
* Generate base helpers
* Add CustomTable engine routes
* Add concern to controllers
* Add CSS import to your application.css: ```@import 'custom_table/table.css';```
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
* ```search``` contains search parameters. Skip this if search is not available for this fields
* * ```q``` ransack's "q" search marcher which is used to search by the field. For range use array of two elements, e.g. ```[:created_at_gteq, :created_at_lteq]```
* * ```type``` type of search element to draw
* ```appear``` controls visibility of the field. Default value is hidden if not specially selected
* * ```default``` will appear by default
* * ```always``` will always appear
* * ```export``` will appear only in XLSX export
* ```link_to_show``` if true, this fields will have link to show page of item
* ```sort``` controls sorting ability for the fields (disabled by default). Use ```true``` or ```{default_order: :asc|:desc}```
* ```amount``` if true, applies number-specific formatting to cells (right align)
* ```helper``` helper name (will be used instead default, see below)

## Controller setup

Add ```CustomTableConcern``` to your controller to get easy index page solution.

This gem provides custom_table method for your controller which does Ransack search and Kaminari pagination for you:

    def index
      @q = @vegetables.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty? # Sets default sorting for ransack

      @vegetables = @q.result(distict: true)
      @vegetables = @vegetables.page(params[:page]).per(params[:per] || 25)
    end

Is equivalent to:

    def index
      @vegetables = custom_table(@vegetables)
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

Add CustomTable as engine to your routes:

And ```custom_table``` attribute as text to your model

Search Settings button will show up automatically if you have at least one customizable field.

You can also use settings button separatelly. It uses Rails turbo and you need to declare ```turbo-modal``` Turbo Tag within your HTML body.

## Variants

For each table you can declare additional variants (set of parameters to be saved to user customization).

Important to note that you need to explicitly set list of available variants. Declare the following helper function:

```{singular_model_name}_custom_table_fields```

Which returns the array of available variant.

Then just pass variant to filter and data helpers.

## Table Stimulus helper




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

## Testing

Use ```custom_table_use_all_fields``` GET param with any value to show all available fields in your feature tests

## Development

Running tests: rspec

