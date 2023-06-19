class Order < ApplicationRecord

  enum delivery: {avia: 1, train: 2, car: 3}

  def self.ransackable_attributes(auth_object = nil)
    ["code", "name", "details", "active", "ordered_at", "priority", "delivery"]
  end

  def self.ransackable_scopes(auth_object = nil)
    []
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end


end
