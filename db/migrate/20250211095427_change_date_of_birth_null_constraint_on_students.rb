class ChangeDateOfBirthNullConstraintOnStudents < ActiveRecord::Migration[7.0]
  def change
    change_column_null :students, :date_of_birth, true
  end
end
