module RedmineContacts
  module Hooks
    class ControllersTimeEntryReportsHook < Redmine::Hook::ViewListener   
      def controller_timelog_available_criterias(context={})
        context[:available_criterias]["contacts"] = {:sql => "contacts_issues.contact_id",
                                         			 :klass => Contact,
                                         			 :label => :label_contact}
      end  

      def controller_timelog_time_report_joins(context={})
      	context[:sql] << " LEFT JOIN contacts_issues ON contacts_issues.issue_id = #{Issue.table_name}.id"
      end
    end   
  end
end


