require_dependency 'custom_fields_helper'

module RedmineContacts
  module Patches    

    module CustomFieldsHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method_chain :custom_fields_tabs, :contacts_tab
        end
      end

      module InstanceMethods
        def custom_fields_tabs_with_contacts_tab
          new_tabs = []
          new_tabs << {:name => 'ContactCustomField', :partial => 'custom_fields/index', :label => :label_contact_plural}
          new_tabs << {:name => 'DealCustomField', :partial => 'custom_fields/index', :label => :label_deal_plural}
          new_tabs << {:name => 'NoteCustomField', :partial => 'custom_fields/index', :label => :label_note_plural}
          return custom_fields_tabs_without_contacts_tab | new_tabs
        end
      end
      
    end
    
  end
end

unless CustomFieldsHelper.included_modules.include?(RedmineContacts::Patches::CustomFieldsHelperPatch)
  CustomFieldsHelper.send(:include, RedmineContacts::Patches::CustomFieldsHelperPatch)
end
