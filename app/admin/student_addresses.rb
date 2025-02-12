ActiveAdmin.register StudentAddress do
menu parent: "Student managment"

active_admin_import validate: true,
headers_rewrites: { 'Student ID': :student_id },  # Ensure CSV header matches
before_batch_import: ->(importer) {
  student_ids = importer.values_at(:student_id)  # Get all student IDs from CSV

  # Fetch matching students from the database
  students = Student.where(student_id: student_ids).pluck(:student_id, :id).to_h

  # Replace student_id with the actual UUID (database ID)
  importer.batch_replace(:student_id, students) do |student_id|
    students[student_id] || raise("Error: No student found for Student ID #{student_id}")
  end
}

 permit_params :special_location, :mobile_number, :telephone_number, :country, :student_id,:city,:region,:zone,:sub_city,:house_number,:cell_phone,:house_phone,:pobox,:woreda,:created_by,:last_updated_by,:created_at
  
end
