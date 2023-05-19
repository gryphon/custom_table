require 'rails_helper'

feature "table display" do

  let!(:orders) { FactoryBot.create_pair(:order) }

  describe "authenticated" do

    before :each do
      @user = FactoryBot.create(:user)
      login_as(@user, scope: :user)
    end
  
    describe "simpliest case" do

      it "saves per page" do

        visit orders_path

        expect(page.body).to match /#{orders[0].code}.*#{orders[1].code}/m
  
        click_on("50")

        expect(@user.reload.custom_table["Order"][:per_page]).to eq(50)

      end

      it "loads sorting direstion" do

        @user.save_custom_table_settings(Order, per_page: 50)

        visit orders_path

        within ".page-item.active" do
          expect(page).to have_content "50"
        end
  
      end

    end


  end

end