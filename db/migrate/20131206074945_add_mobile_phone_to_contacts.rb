class AddMobilePhoneToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :mobile_phone, :string
  end
end
