class AddStudentToPayments < ActiveRecord::Migration[7.0]
  def change
    add_reference :payments, :student, null: true, foreign_key: true, type: :uuid
  end
end
