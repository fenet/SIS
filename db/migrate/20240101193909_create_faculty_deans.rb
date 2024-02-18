class CreateFacultyDeans < ActiveRecord::Migration[7.0]
  def change
    create_table :faculty_deans, id: :uuid  do |t|
      t.references :admin_user, null: false, foreign_key: true, type: :uuid
      t.references :faculty, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
