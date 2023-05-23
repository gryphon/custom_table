# Custom Table

Provides powerful set of functionality for showing tables of data:
* Generated table and filter panel for any model
* Declare fields that should be displayed, filtered or sorted
* Customize visible fields for each user
* Exporting table to XLSX

## Setup

* Generate base helpers
* Add CustomTable engine routes
* Add concern to controllers
* Add CSS import to your application.css: ```@import 'custom_table/table.css';```
* Add concern to User model and user ```custom_table``` field
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
* ```link_to_show``` if true, this fields will have link to show page of item
* ```sort``` controls sorting ability for the fields (disabled by default). Use ```true``` or ```{default_order: :asc|:desc}```
* ```amount``` if true, applies number-specific formatting to cells (right align)

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
* ```pagination``` - ```boolean``` if pagination is enabled (default to ```true```)
* ```default_query``` - default ransack ```q``` object. Default is empty 

## Rendering tables

Invoke this in your index to display table:
```custom_table_data collection: @vegetables```

Options available are:

* ```collection``` is the only required option. Contains paged collection from your controller
* ```parent``` parent resource for inherited routes
* ```skip_fields``` array of field names as symbols. Removes specific fields from table
* ```skip_actions``` removes all actions
* ```skip_default_actions``` removes default actions
* ```actions``` helper name for custom actions. Table also looks for ```{singular_model_name}_custom_table_actions``` helper presence
* ```totals``` object of fields to show totals. Use symbols as keys and pass value or left nil to let table try to count total based on raw/field value

## Rendering search panel

Use this helper in order to show filter panel:

```custom_table_filter search_model: Vegetable```

Options:

* ```search_model``` model class to use with this filter. The only required parameter.

## Displaying custom fields

You can declare fields which your model doesn't have. In this case table can't render field value so you have to provide helpers for rendering the field. Table renderer will try to look for these helpers in prioritizing order:

* ```{singular_model_name}_#{field}_field``` to avoid naming collisions
* ```{singular_model_name}_#{field}``` best choise for most projects
* ```{singular_model_name}_#{field}_raw``` use this to produce non-decorated raw data which can be used in tables

## Displaying custom actions



## Customizing user columns

Add CustomTable as engine to your routes:

And ```custom_table``` attribute as text to your model

Search Settings button will show up automatically if you have at least one customizable field.

You can also use settings button separatelly. It uses Rails turbo and you need to declare ```turbo-modal``` Turbo Tag within your HTML body.

## Representations

For each table you can declare additional representations (set of parameters to be saved to user customization).

Important to note that you need to explicitly set list of available representations. Declare the following helper function:

```{singular_model_name}_custom_table_fields```

Which returns the array of available representation.

Then just pass representation to filter and data helpers.