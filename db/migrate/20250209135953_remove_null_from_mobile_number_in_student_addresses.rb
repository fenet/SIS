class RemoveNullFromMobileNumberInStudentAddresses < ActiveRecord::Migration[7.0]
  def change
    change_column_null :student_addresses, :moblie_number, true
  end
end
