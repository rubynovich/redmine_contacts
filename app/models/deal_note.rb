class DealNote < Note
  unloadable
  belongs_to :deal, :foreign_key => :source_id
  acts_as_searchable :columns => ["#{table_name}.content"],  
                     :include => [:deal => :project], 
                     :project_key => "#{Project.table_name}.id", 
                     :permission => :view_deals,            
                     # sort by id so that limited eager loading doesn't break with postgresql
                     :order_column => "#{table_name}.id"

  acts_as_activity_provider :type => 'deals',               
                            :permission => :view_deals,  
                            :author_key => :author_id,
                            :find_options => {:include => [:deal => :project],
                                              :conditions => {:source_type => 'Deal'}} 

  scope :visible, lambda {|*args| { :include => [:deal => :project],
                                          :conditions => Project.allowed_to_condition(args.first || User.current, :view_deals) +
                                                         " AND (#{DealNote.table_name}.source_type = 'Deal')"} }
end  
