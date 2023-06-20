require 'rails_helper'

feature "fieldset" do

  let!(:order) { FactoryBot.create(:order) }

  describe "authenticated" do

    before :each do
      @user = FactoryBot.create(:user)
      login_as(@user, scope: :user)
    end
  
    describe "simpliest case" do

      before {
        visit order_path(order)
      }

      it "shows order code" do
        expect(page).to have_content order.code
      end

      it "shows custom label for name" do
        expect(page).to have_content "NAMECUSTOMLABEL"
      end

      it "shows order custom details" do
        expect(page).to have_content "DEDE#{order.details}TAILS"
      end

    end

  end

end
