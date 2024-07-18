ActiveAdmin.register AdminUser, as: "instructor"  do
  menu parent: "Department"
  permit_params :photo, :email, :password, :password_confirmation,:first_name,:last_name,:middle_name,:role,:username
  
  controller do
    def scoped_collection
      if current_admin_user.role == "department head"
        department_head_name = "#{current_admin_user.first_name} #{current_admin_user.last_name}"
        joins_clause = <<-SQL
          LEFT JOIN course_instructors ON course_instructors.admin_user_id = admin_users.id
        SQL
        super.joins(joins_clause)
             .where(course_instructors: { created_by: department_head_name })
             .where(admin_users: { role: "instructor" })
      else
        super.where(role: "instructor")
      end
    end

    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update : :update_without_password
      object.send(update_method, *attributes)
    end
  end

  index do
    selectable_column
    column "Full Name", sortable: true do |n|
      n.name.full 
    end
    column :email
    column :role
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :first_name
  filter :last_name
  filter :middle_name
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Instructor Account" do
      f.input :first_name
      f.input :last_name
      f.input :middle_name
      f.input :username
      f.input :email
      if !f.object.new_record?
        f.input :current_password
      else
        f.input :role, as: :hidden, :input_html => { :value => "instructor"}
      end
      f.input :password
      f.input :password_confirmation
      f.input :photo, as: :file
    end
    f.actions
  end

  show :title => proc{|instructor| instructor.name.full }  do
    panel "Instructor Information" do
      attributes_table_for instructor do
        row "photo" do |pt|
          span image_tag(pt.photo, size: '150x150', class: "img-corner") if pt.photo.attached?
        end
        row :first_name
        row :last_name
        row :middle_name
        row :username
        row :email
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
        row :current_sign_in_ip
        row :last_sign_in_ip
        row :created_at
        row :updated_at
      end
    end
  end 

  action_item :course_assignments_report, only: :index do
    if current_admin_user.role == 'department head'
      link_to 'Instructor Load Report', course_assignments_report_path, class: 'button'
    end
  end
  
end
