
 ActiveAdmin.register Section , as: "ProgramSection" do
permit_params :program_id, :section_short_name, :batch ,:section_full_name, :total_capacity,:semester,:year,:created_by,:updated_by
menu parent: ["Student managment", "Section managment"], label: "Create Section", priority: 1
# menu parent: ["Student managment", "Section managment"], label: "Asign Section"

  index do
    selectable_column
    column :section_short_name
    column :section_full_name
    column "Program" do |pr|
      link_to pr.program.program_name, admin_program_path(pr.program.id)
    end
    column :semester
    column :year
    
    column :total_capacity
    column "Remaining Capacity" do |se|
      se.total_capacity || 0 - se.students.count
    end
    column "Created At", sortable: true do |c|
      c.created_at.strftime("%b %d, %Y")
    end
    actions
  end 

  filter :program_id, as: :search_select_filter, url: proc { admin_programs_path },fields: [:program_name, :id], display_name: 'program_name', minimum_input_length: 2,order_by: 'id_asc'
  filter :section_short_name
  filter :section_full_name
  filter :semester
  filter :year
  filter :total_capacity
  filter :updated_by
  filter :created_by
  filter :created_at
  filter :updated_at

  form do |f|
    f.semantic_errors
    f.inputs "Section information" do
      f.input :program_id, as: :search_select, url: admin_programs_path,
              fields: [:program_name, :id], display_name: 'program_name', minimum_input_length: 2,lebel: "attendance title",
              order_by: 'created_at_asc'
      f.input :section_short_name
      f.input :section_full_name
      f.input :total_capacity
      f.input :batch 
      f.input :year
      f.input :semester
      if f.object.new_record?
        f.input :created_by, as: :hidden, :input_html => { :value => current_admin_user.name.full}
      else
        f.input :updated_by, as: :hidden, :input_html => { :value => current_admin_user.name.full}
      end 
    end
    f.actions
  end

  show title: :section_full_name do
    columns do
      column do
          attributes_table title: "Section information" do
            row :section_short_name
            row :section_full_name
            row :year
            row :semester
            row :section_status
            row :batch
            row :total_capacity
            row :created_by
            row :updated_by
            row :created_at
            row :updated_at
        end



      end
      column do
        panel "Students list " do
        table_for program_section.students do
          column "Student Full Name" do |n|
            link_to n.name.full, admin_student_path(n.id)
          end
          column "Student ID" do |n|
            n.student_id
          end
          column "Department" do |n|
            n.department.department_name
          end 
          column "Program Name" do |n|
            n.program.program_name
          end
          column "Year" do |n|
            n.year
          end
          column "Semester" do |n|
            n.semester
          end
        end
        end
      end 
    end
  end
  
end
