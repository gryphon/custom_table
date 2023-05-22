require 'rails_helper'

feature "table display" do

  let!(:orders) { FactoryBot.create_pair(:order) }

  describe "unauthenticated" do

    it "sorts list of orders" do

      visit orders_path

      expect(page.body).to match /#{orders[0].code}.*#{orders[1].code}/m

      find("[data-sort=custom-table-sort-code-desc]").click

      expect(page.body).to match /#{orders[1].code}.*#{orders[0].code}/m

    end

  end

  describe "authenticated" do

    before :each do
      @user = FactoryBot.create(:user)
      login_as(@user, scope: :user)
    end
  
    describe "simpliest case" do

      it "saves sorting direstion" do

        visit orders_path

        expect(page.body).to match /#{orders[0].code}.*#{orders[1].code}/m
  
        find("[data-sort=custom-table-sort-code-desc]").click

        expect(@user.reload.custom_table["Order"][:sorts]).to eq("code desc")

      end

      it "loads sorting direstion" do

        @user.save_custom_table_settings(Order, sorts: "code desc")

        visit orders_path

        expect(page.body).to match /#{orders[1].code}.*#{orders[0].code}/m
  
      end

    end

    describe "representation" do

      it "saves sorting direstion" do

        visit another_orders_path

        expect(page.body).to match /#{orders[0].code}.*#{orders[1].code}/m
  
        find("[data-sort=custom-table-sort-code-desc]").click

        expect(@user.reload.custom_table["Order-another"][:sorts]).to eq("code desc")

      end

    end

  end

end
