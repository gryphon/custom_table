require 'rubygems'
require 'rails'

module CustomTable
  module Rails
    class Engine < ::Rails::Engine
      initializer 'custom_table.assets' do |app|
        %w(stylesheets javascripts).each do |sub|
          app.config.assets.paths << root.join('assets', sub).to_s
        end
      end
    end
  end
end
