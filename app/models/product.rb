require 'csv'
require 'rubygems'
require 'roo'

class Product < ApplicationRecord
   validates_presence_of :price
   
   def self.accessible_attributes
    [:id,:name,:released_on,:price]
   end

  def self.to_csv(options = {})
    desired_columns = ["id", "name", "released_on","price"]
    CSV.generate(options) do |csv|
      csv << desired_columns
      all.each do |product|
        csv << product.attributes.values_at(*desired_columns)
      end
    end
  end

  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      product = Product.find_by_id(row["id"]) || Product.new
      product.attributes =  row.to_hash()
      product.save!
    # Product.create! row.to_hash
    end
  end

  def self.spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::CSV.new(file.path, :ignore)
    when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
    when '.xlsx' then Roo::Excelx.new(file.path, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end

#   spreadsheet = Roo::Spreadsheet.open(file.path)
#    header = spreadsheet.row(1)
#    (2..spreadsheet.last_row).each do |i|
#      row = Hash[[header, spreadsheet.row(i)].transpose]
#      product = find_by(id: row["id"]) || new
#      product.attributes = row.to_hash
#      product.save!
#    end
#  end
#  spreadsheet = Roo::Spreadsheet.open(file.path)
# end