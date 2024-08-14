ActiveAdmin.register Exemption do
  menu parent: "Student managment"
  permit_params :course_title, :letter_grade, :course_code, :credit_hour, :department_approval, :dean_approval, :registeral_approval, :exemption_needed, :external_transfer_id

  batch_action "Approve application status by registeral for", method: :put, confirm: "Are you sure?", if: proc { current_admin_user.role == "registrar head" || current_admin_user.role == "admin" } do |ids|
    Exemption.where(id: ids).update(registeral_approval_status: 1, registeral_approval: "Approved by #{current_admin_user&.first_name} #{current_admin_user&.last_name} ")
    redirect_to admin_exemptions_path, notice: "#{ids.size} #{"applicant".pluralize(ids.size)} status approved"
  end

  batch_action "Reject application status by registeral for", method: :put, confirm: "Are you sure?", if: proc { current_admin_user.role == "registrar head" || current_admin_user.role == "admin"} do |ids|
    Exemption.where(id: ids).update(registeral_approval_status: 2, registeral_approval: "Rejected by #{current_admin_user&.first_name} #{current_admin_user&.last_name}")
    redirect_to admin_exemptions_path, notice: "#{ids.size} #{"applicant".pluralize(ids.size)} status rejected"
  end

  batch_action "Approve application status by Department Head", method: :put, confirm: "Are you sure?", if: proc { current_admin_user.role == "department head" || current_admin_user.role == "admin" } do |ids|
    Exemption.where(id: ids).update(department_approval_status: 1, department_approval: "Approved by #{current_admin_user&.first_name} #{current_admin_user&.last_name} ")
    redirect_to admin_exemptions_path, notice: "#{ids.size} #{"applicant".pluralize(ids.size)} status approved"
  end

  batch_action "Reject application status by Department Head", method: :put, confirm: "Are you sure?", if: proc { current_admin_user.role == "department head" || current_admin_user.role == "admin"} do |ids|
    Exemption.where(id: ids).update(department_approval_status: 2, department_approval: "Rejected by #{current_admin_user&.first_name} #{current_admin_user&.last_name}")
    redirect_to admin_exemptions_path, notice: "#{ids.size} #{"applicant".pluralize(ids.size)} status rejected"
  end
  

  batch_action "Approve application status by dean for", method: :put, confirm: "Are you sure?", if: proc { current_admin_user.role == "dean" || current_admin_user.role == "admin"} do |ids|
    Exemption.where(id: ids).update(dean_approval_status: 1, dean_approval: "Approved by #{current_admin_user&.first_name} #{current_admin_user&.last_name} ")
    redirect_to admin_exemptions_path, notice: "#{ids.size} #{"applicant".pluralize(ids.size)} status approved"
  end

  batch_action "Reject application status by dean for", method: :put, confirm: "Are you sure?", if: proc { current_admin_user.role == "dean" || current_admin_user.role == "admin"} do |ids|
    Exemption.where(id: ids).update(dean_approval_status: 2, dean_approval: "Rejected by #{current_admin_user&.first_name} #{current_admin_user&.last_name}")
    redirect_to admin_exemptions_path, notice: "#{ids.size} #{"applicant".pluralize(ids.size)} status rejected"
  end
  
  filter :course_title
  filter :course_code
  filter :created_at

  scope :all, default: true

  index do
    selectable_column
    column "Applicant name", sortable: true do |c|
      c.external_transfer&.first_name + " " + c.external_transfer&.last_name
    end
    column :course_title, sortable: true
    column :letter_grade, sortable: true
    column :course_code, sortable: true
    column :credit_hour, sortable: true
    column :department_approval, sortable: true
    column :dean_approval, sortable: true
    column :registeral_approval, sortable: true
    actions
    # end
  end
end
