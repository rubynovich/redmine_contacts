module RedmineContacts
  module Hooks
    class ViewsCustomFieldsHook < Redmine::Hook::ViewListener     
      render_on :view_custom_fields_form_deal_custom_field, :partial => "deals/custom_field_form" 
      render_on :view_custom_fields_form_contact_custom_field, :partial => "contacts/custom_field_form" 
    end   
  end
end
