require 'rails_helper'

feature "table display" do

  let!(:orders) { FactoryBot.create_pair(:order) }

  describe "unauthenticated" do

    it "shows list of orders" do

      visit orders_path

      expect(page).to have_content orders[0].code
      expect(page).to have_content orders[1].code

    end

  end

  describe "authenticated" do

    before :each do
      @user = FactoryBot.create(:user)
      login_as(@user, scope: :user)
    end
  
    describe "simpliest case" do

      it "shows list of orders" do

        visit orders_path

        expect(page).to have_content orders[0].code
        expect(page).to have_content orders[1].code

      end

    end

    describe "customized fields" do

      it "shows list of orders" do

        @user.save_custom_table_settings(Order, fields: {name: true})

        visit orders_path

        expect(page).to have_content orders[0].code # Always visible
        expect(page).to have_content orders[0].name
        expect(page).to_not have_content orders[0].details # Excluded by default

      end

      it "shows correct order of fields" do

        @user.save_custom_table_settings(Order, fields: {details: true, name: true, code: true})

        visit orders_path

        expect(page.body).to match /#{orders[0].details}.*#{orders[0].name}.*#{orders[0].code}/m

      end
      
    end



    describe "representation" do

      it "shows list of orders" do

        @user.save_custom_table_settings(Order, "another", fields: {name: true})

        visit another_orders_path

        expect(page).to have_content orders[0].code # Always visible
        expect(page).to have_content orders[0].name
        expect(page).to_not have_content orders[0].details # Excluded by default

      end

      it "shows correct order of fields" do

        @user.save_custom_table_settings(Order, "another", fields: {details: true, name: true, code: true})

        visit another_orders_path

        expect(page.body).to match /#{orders[0].details}.*#{orders[0].name}.*#{orders[0].code}/m

        visit orders_path

        # Excluded in defailt representation by default
        expect(page.body).not_to match have_content orders[0].details

      end
      
    end


  end

end
