require 'rails_helper'

feature "table display" do

  let!(:order) { FactoryBot.create(:order) }

  describe "simpliest case" do

    it "saves per page" do

      visit row_order_path(order)

      expect(page.body).to include order.name

    end

  end

end
