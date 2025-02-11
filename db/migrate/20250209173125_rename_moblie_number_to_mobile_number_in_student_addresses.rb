class RenameMoblieNumberToMobileNumberInStudentAddresses < ActiveRecord::Migration[7.0]
  def change
    rename_column :student_addresses, :moblie_number, :mobile_number

  end
end
