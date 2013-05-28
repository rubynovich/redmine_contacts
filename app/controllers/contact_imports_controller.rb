class ContactImportsController < ImporterBaseController
  menu_item :contacts
  helper :contacts

  def klass
    ContactImport
  end

  def instance_index
    project_contacts_path(:project_id => @project.id)
  end
end
