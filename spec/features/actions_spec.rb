require 'rails_helper'

feature "table display" do

  let!(:orders) { FactoryBot.create_pair(:order) }

  describe "authenticated" do

    before :each do
      @user = FactoryBot.create(:user)
      login_as(@user, scope: :user)
    end

    describe "default actions" do

      it "shows simple actions" do

        visit orders_path

        expect(page).to have_css("#destroy_order_#{orders[0].id}")

      end

    end

    describe "custom actions" do

      it "shows custom actions passed via param" do

        visit actions_custom_orders_path

        expect(page).to have_content("CUSTOM_ACTIONS")

      end

    end

  
    describe "skip default actions" do

      it "shows list of orders" do

        visit actions_skip_default_orders_path

        expect(page).not_to have_css("#destroy_order_#{orders[0].id}")

      end

    end

    describe "skip all actions" do

      it "shows list of orders without any actions" do

        visit actions_skip_orders_path

        expect(page).not_to have_content("CUSTOM_ACTIONS")
        expect(page).not_to have_css("#destroy_order_#{orders[0].id}")

      end

    end

    describe "representation" do

      it "shows actions for representation" do

        visit actions_representation_orders_path

        expect(page).to have_content("OLEILO")

      end

    end


  end

end
