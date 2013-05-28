
class DealImport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include CSVImportable

  attr_accessor :file, :project, :quotes_type

  def klass
    Deal
  end

  def build_from_fcsv_row(row)
    ret = Hash[row.to_hash.map{ |k,v| [k.underscore.gsub(' ','_'), force_utf8(v)] }].delete_if{ |k,v| !klass.column_names.include?(k) }
    ret[:status_id] = DealStatus.where(:name => row['status']).first.try(:id) if row['status']
    ret[:category_id] = DealCategory.where(:name => row['category']).first.try(:id) if row['category']
    ret[:price] = row['sum'].to_f if row['sum']
    if row['contact'].to_s.match(/^\#(\d+):/)
      ret[:contact_id] = Contact.find_by_id($1).try(:id) 
    end
    ret
  end

end
