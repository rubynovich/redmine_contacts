class AddFaxToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :fax, :string
  end
end
