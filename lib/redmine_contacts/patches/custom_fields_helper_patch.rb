require_dependency 'custom_fields_helper'

module RedmineContacts
  module Patches    

    module CustomFieldsHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          if Redmine::VERSION::MAJOR >= 2 && Redmine::VERSION::MINOR >= 5
            alias_method_chain :render_custom_fields_tabs, :render_contacts_tab
            alias_method_chain :custom_field_type_options, :contacts_tab_options
          else
            alias_method_chain :custom_fields_tabs, :contacts_tab
          end
        end
      end

      module InstanceMethods

        def custom_fields_tabs_with_contacts_tab
          add_ct
          custom_fields_tabs_without_contacts_tab
        end

        def render_custom_fields_tabs_with_render_contacts_tab(types)
          add_ct
          render_custom_fields_tabs_without_render_contacts_tab(types)
        end

        def custom_field_type_options_with_contacts_tab_options
          add_ct
          custom_field_type_options_without_contacts_tab_options
        end

        private

        def add_ct
          new_tabs = []
          new_tabs << {:name => 'ContactCustomField', :partial => 'custom_fields/index', :label => :label_contact_plural}
          new_tabs << {:name => 'DealCustomField', :partial => 'custom_fields/index', :label => :label_deal_plural}
          new_tabs << {:name => 'NoteCustomField', :partial => 'custom_fields/index', :label => :label_note_plural}
          new_tabs.each do |new_tab|
            unless CustomFieldsHelper::CUSTOM_FIELDS_TABS.index { |f| f[:name] == new_tab[:name] }
              CustomFieldsHelper::CUSTOM_FIELDS_TABS << new_tab
            end
          end
        end

      end
      
    end
    
  end
end

unless CustomFieldsHelper.included_modules.include?(RedmineContacts::Patches::CustomFieldsHelperPatch)
  CustomFieldsHelper.send(:include, RedmineContacts::Patches::CustomFieldsHelperPatch)
end
