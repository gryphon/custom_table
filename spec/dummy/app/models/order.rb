class Order < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
    ["code", "name", "details"]
  end

  def self.ransackable_scopes(auth_object = nil)
    []
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end


end
