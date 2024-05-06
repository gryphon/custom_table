require 'rails_helper'

feature "settings display" do

  describe "authenticated" do

    before :each do
      @user = FactoryBot.create(:user)
      login_as(@user, scope: :user)
    end
  
    describe "never customizated" do

      it "shows default settings" do

        visit custom_table.edit_setting_path("Order")

        expect(page).to have_content "Code"
        expect(page).to have_content "Name"

        # abort page.body.to_s

        expect(find_field("user[fields][code]", disabled: true).checked?).to eq true
   
        expect(find_field("user[fields][name]").checked?).to eq true
        expect(find_field("user[fields][details]").checked?).to eq false

      end

      it "saves settings" do

        visit custom_table.edit_setting_path("Order")

        expect(page).to have_content "Code"
        expect(page).to have_content "Name"

        expect(find_field("user[fields][name]").checked?).to eq true

        find_field("user[fields][name]").set(false)
        click_on("Save")

        expect(@user.reload.custom_table["Order"][:fields][:name]).to eq(false)

      end


    end

    describe "customizated before" do

      it "shows user settings" do

        @user.save_custom_table_settings(Order, fields: {details: false, name: false})

        visit custom_table.edit_setting_path("Order")

        expect(find_field("user[fields][name]").checked?).to eq false

      end

    end

    describe "with variant" do

      it "shows user settings" do

        @user.save_custom_table_settings(Order, "another", fields: {details: false, name: false})

        visit custom_table.edit_setting_path("Order", variant: "another")

        expect(find_field("user[fields][name]").checked?).to eq false

      end

    end

    describe "reset" do

      it "resets user settings" do

        @user.save_custom_table_settings(Order, fields: {details: false, name: false})

        visit custom_table.edit_setting_path("Order")

        click_on "Reset to default"

        expect(@user.reload.custom_table).to eq({})

      end

    end


  end

end
