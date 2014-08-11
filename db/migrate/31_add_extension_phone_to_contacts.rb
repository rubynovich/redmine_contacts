class AddExtensionPhoneToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :phone_ext, :string
  end
end
               