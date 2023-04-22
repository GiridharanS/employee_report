class Employee < ApplicationRecord
  scope :filter_by_state, ->(name) { where('lower(state) = ?', name.downcase).first }

  STATES = %w[India UAE]

  # def import
  #   xlsx = Roo::Excelx.new(file)

  #   data = []

  #   xlsx.each_row_streaming(offset: 1) do |row|
  #     site = row[0].value
  #     permanent = row[1].value.to_i
  #     contract = row[2].value.to_i
  #     permanent_male = row[3].value.to_i
  #     permanent_female = row[4].value.to_i
  #     contract_male = row[5].value.to_i
  #     contract_female = row[6].value.to_i
  #     overall_workforce = row[7].value.to_i
  #     male_female_ratio = row[8].value

  #     data << {
  #       site:,
  #       permanent:,
  #       contract:,
  #       permanent_male:,
  #       permanent_female:,
  #       contract_male:,
  #       contract_female:,
  #       overall_workforce:,
  #       male_female_ratio:
  #     }
  #   end
  # end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |employee|
        csv << employee.attributes.values_at(*column_names)
      end
    end
  end
end
