require 'rails_helper'

feature "orders" do

  before :each do
    @user = FactoryBot.create(:user)
    login_as(@user, scope: :user)
  end

  describe "index" do

    it "shows list of orders" do

      orders = FactoryBot.create_pair(:order)

      visit orders_path

      expect(page).to have_content orders[0].code
      expect(page).to have_content orders[1].code

    end

  end

end
