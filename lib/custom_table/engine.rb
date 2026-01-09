module CustomTable
  class Engine < ::Rails::Engine
    isolate_namespace CustomTable

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # initializer 'action_controller.include_concern' do

    #   ActiveSupport.on_load(:action_controller) do
    #     include CustomTableConcern
    #   end
    # end

    config.to_prepare do
      # Safely include the concern into the main app's ApplicationController
      ::ApplicationController.include CustomTableConcern

      ::ApplicationHelper.include CustomTable::ApplicationHelper
      ::ApplicationHelper.include CustomTable::FieldsetHelper
      ::ApplicationHelper.include CustomTable::IconsHelper

    end

  end
end
