# Redmine CRM plugin

# require 'redmine'  

CONTACTS_VERSION_NUMBER = '3.2.3'
CONTACTS_VERSION_STATUS = ''

Redmine::Plugin.register :redmine_contacts do
  name 'Redmine CRM plugin'
  author 'RedmineCRM'
  description 'This is a CRM plugin for Redmine that can be used to track contacts and deals information'
  version CONTACTS_VERSION_NUMBER + '-pro' + CONTACTS_VERSION_STATUS

  url 'http://redminecrm.com'
  author_url 'mailto:support@redminecrm.com'

  requires_redmine :version_or_higher => '2.1.2'
  
  settings :default => {
    :use_gravatars => false, 
    :name_format => :lastname_firstname.to_s,
    :auto_thumbnails  => true,
    :contact_list_default_columns => ["first_name", "last_name"],
    :max_thumbnail_file_size => 300
  }, :partial => 'settings/contacts'
  
  project_module :contacts_module do
    permission :view_contacts, { 
      :contacts => [:show, :index, :live_search, :contacts_notes, :context_menu],
      :notes => [:show]
    }
    permission :view_private_contacts, {
      :contacts => [:show, :index, :live_search, :contacts_notes, :context_menu],
      :notes => [:show]      
    }

    permission :add_contacts, {
      :contacts => [:new, :create],
      :contacts_duplicates => [:index, :duplicates],
      :contacts_vcf => [:load]
    }
    
    permission :edit_contacts, { 
      :contacts => [:edit, :update],
      :notes => [:add_note, :destroy, :edit, :update],
      :contacts_tasks => [:new, :add, :delete, :close],
      :contacts_duplicates => [:index, :merge, :duplicates],
      :contacts_projects => [:add, :delete],
      :contacts_vcf => [:load]
    }
    permission :delete_contacts, :contacts => [:destroy, :bulk_destroy]
    permission :add_notes, :notes => [:add_note]
    permission :delete_notes, :notes => [:destroy, :edit, :update]
    permission :delete_own_notes, :notes => [:destroy, :edit, :update]
    permission :send_contacts_mail, :contacts => [:edit_mails, :send_mails, :preview_email]
    permission :delete_deals, :deals => [:destroy, :bulk_destroy]
    permission :view_deals, {
      :deals => [:index, :show, :context_menu], 
      :sales_funnel => [:index], :public => true
    }
    permission :edit_deals, {
      :deals => [:edit, :update, :add_attachment, :bulk_update, :bulk_edit],   
      :deal_contacts => [:add, :delete],           
      :notes =>  [:add_note, :destroy_note]  
    }
    permission :add_deals, {
      :deals => [:new, :create]
    }
    permission :manage_contacts, { 
      :projects => :settings, 
      :contacts_settings => :save, 
      :deal_categories => [:new, :edit, :destroy], 
      :deal_statuses => [:assing_to_project], :require => :member
    }
    %w(contacts deals).each do |resource|
      permission "import_#{resource}".to_sym, {"#{resource.singularize}_imports" => [:new, :create]}
    end
    
    permission :manage_public_contacts_queries, {:contacts_queries => [:new, :create, :edit, :update, :destroy]}, :require => :member
    permission :save_contacts_queries, {:contacts_queries => [:new, :create, :edit, :update, :destroy]}, :require => :loggedin

  end

  menu :project_menu, :contacts, {:controller => 'contacts', :action => 'index'}, :caption => :contacts_title, :param => :project_id

  menu :application_menu, :contacts, 
                          {:controller => 'contacts', :action => 'index'}, 
                          :caption => :label_contact_plural, 
                          :param => :project_id, 
                          :if => Proc.new{User.current.allowed_to?({:controller => 'contacts', :action => 'index'}, 
                                          nil, {:global => true}) && RedmineContacts.settings[:show_in_app_menu]}

  # menu :top_menu, :deals, {:controller => 'deals', :action => 'index', :project_id => nil}, :caption => :label_deal_plural, :if => Proc.new {
  #   User.current.allowed_to?({:controller => 'deals', :action => 'index'}, nil, {:global => true}) && RedmineContacts.settings[:show_deals_in_top_menu]
  # }    

  menu :project_menu, :deals, {:controller => 'deals', :action => 'index' }, 
                              :caption => :label_deal_plural, 
                              :if => Proc.new{|p| ContactsSetting[:contacts_show_deals_tab, p.id].to_i > 0 },
                              :param => :project_id

  menu :application_menu, :deals, 
                          {:controller => 'deals', :action => 'index'}, 
                          :caption => :label_deal_plural, 
                          :param => :project_id, 
                          :if => Proc.new{User.current.allowed_to?({:controller => 'deals', :action => 'index'}, 
                                          nil, {:global => true}) && RedmineContacts.settings[:show_in_app_menu]}
  
  # menu :top_menu, :contacts, {:controller => 'contacts', :action => 'index', :project_id => nil}, :caption => :contacts_title, :if => Proc.new {
  #   User.current.allowed_to?({:controller => 'contacts', :action => 'index'}, nil, {:global => true})
  # }  

  menu :admin_menu, :contacts, {:controller => 'settings', :action => 'plugin', :id => "redmine_contacts"}, :caption => :contacts_title

  Redmine::MenuManager.map :top_menu do |menu| 

    parent = menu.exists?(:public_intercourse) ? :public_intercourse : :top_menu

    # menu.push(:deals, 
    #           {:controller => 'deals', :action => 'index', :project_id => nil}, 
    #           { :parent => parent,
    #             :caption => :label_deal_plural, 
    #             :if => Proc.new {
    #               User.current.allowed_to?({:controller => 'deals', :action => 'index'}, nil, {:global => true}) && RedmineContacts.settings[:show_deals_in_top_menu]
    #             }
    #           })
    
    menu.push(:contacts, 
              {:controller => 'contacts', :action => 'index', :project_id => nil}, 
              { :parent => parent,
                :caption => :contacts_title, 
                :if => Proc.new {User.current.allowed_to?({:controller => 'contacts', :action => 'index'}, nil, {:global => true})}  
              })
    
  end


  
  activity_provider :contacts, :default => false, :class_name => ['ContactNote', 'Contact']
  activity_provider :deals, :default => false, :class_name => ['DealNote', 'Deal']

  Redmine::Search.map do |search|
    search.register :contacts
    search.register :contact_notes
    search.register :deals
    search.register :deal_notes
  end
 
end

require 'redmine_contacts'
