require "custom_table/version"
require "custom_table/engine"
require "custom_table/configuration"
module CustomTable

  def self.configuration
    @configuration ||= Configuration.new
  end
  
  def self.configure(&block)
    yield(configuration)
  end

end
