
class DealImportsController < ImporterBaseController

  def klass
    DealImport
  end

  def instance_index
    project_deals_path(:project_id => @project.id)
  end
end
