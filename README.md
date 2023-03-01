# Custom Table

Provides powerful set of functionality for showing tables of data:
* Generated table and filter panel for any model
* Declare fields that should be displayed, filtered or sorted
* Customize visible fields for each user
* Exporting table to XLSX

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

Make sure you are using Ransack and Kaminari in your index just as recommended in their documentation:

    def index
      @q = @vegetables.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty? # Sets default sorting for ransack

      @vegetables = @q.result(distict: true)
      @vegetables = @vegetables.page(params[:page]).per(params[:per] || 25)
    end

## Rendering tables

Invoke this in your index to display table:
```custom_table collection: @vegetables```

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


