
require File.expand_path('../../test_helper', __FILE__)  

class DealImportTest < ActiveSupport::TestCase
    ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', 
                            [:contacts,
                             :contacts_projects,
                             :deals,
                             :deal_statuses,
                             :deal_categories,
                             :roles,
                             :enabled_modules])   

  def fixture_files_path
    "#{File.expand_path('../..',__FILE__)}/fixtures/files/"
  end

  def test_open_correct_csv
    deal_import = DealImport.new(
      :file => Rack::Test::UploadedFile.new(fixture_files_path + "deals_correct.csv", 'text/comma-separated-values'),
      :project => Project.first,
      :quotes_type => '"'
      )
    assert_difference('Deal.count', 1, 'Should have 1 deal in the database') do
      assert_equal 1, deal_import.imported_instances.count, 'Should find 1 deal in file'
      assert deal_import.save, 'Should save successfully'
    end
    deal = Deal.last
    assert_equal 2, deal.status_id, "Status doesn't mach"
    assert_equal 1, deal.category_id, "Category should be Design"
  end
end
