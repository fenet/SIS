# frozen_string_literal: true
ActiveAdmin.register_page "ExternalTransfer" do
  menu label: "Student Transfer"

  content do
    div id: "approval" do
    end
    tabs do
      transfers = current_admin_user.department.external_transfers
      tab "New Transfer Application (#{transfers.where(status: 0).size} application on pending)" do
        table_for transfers.where(status: 0) do
          column :first_name
          column :last_name
          column :previous_institution, sortable: true
          column "Student ID", sortable: true do |c|
            c.previous_student_id
          end
          column :admission_type do |c|
            c.admission_type&.capitalize
          end
          column :study_level do |c|
            c.study_level&.capitalize
          end

          column :status do |c|
            status_tag c.status
          end
          column "Action" do |c|
            link_to "Approve", transfer_approval_path(c, "#{current_admin_user&.first_name} #{current_admin_user&.last_name}"), class: "btn btn-primary", target: "_blank"
          end
        end
      end
      tab "Course Exemption" do
        table_for transfers.where.not(status: 0) do
          column :first_name
          column :last_name
          column :previous_institution, sortable: true
          column "Student ID", sortable: true do |c|
            c.previous_student_id
          end
          column :admission_type do |c|
            c.admission_type&.capitalize
          end
          column :study_level do |c|
            c.study_level&.capitalize
          end

          column :status do |c|
            status_tag c.status
          end
          column "Action" do |c|
            link_to "Change Status", transfer_approval_path(c, "#{current_admin_user&.first_name} #{current_admin_user&.last_name}"), class: "btn btn-primary", target: "_blank"
          end
          column "Exemption" do |c|
            if c.rejected?
              status_tag "No Exemption"
            else
              link_to "Manage Exemption", index_exemptions_path(c, "Approved by #{current_admin_user&.first_name} #{current_admin_user&.last_name}"), class: "btn btn-primary", target: "_blank"
            end
          end
        end
      end
    end
  end
end
