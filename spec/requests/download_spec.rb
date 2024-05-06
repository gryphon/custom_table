require "rails_helper"
require 'roo'

describe "orders/index.xlsx", type: :request do

  let!(:orders) { FactoryBot.create_pair(:order) }

  before :each do
    @user = FactoryBot.create(:user)
    login_as(@user, scope: :user)
  end

  it "renders output document for orders list" do

    get orders_path(format: :xlsx)

    expect(response.status).to be(200)

    file = Tempfile.new(['reqs_orders_spec', '.xlsx'])
    IO.binwrite(file.path, response.body)

    sheet = Roo::Excelx.new(file.path)
    row = sheet.row(3)
    expect(row).to include(orders[0].name)

    File.delete(file.path)
  end
end