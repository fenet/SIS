# frozen_string_literal: true
ActiveAdmin.register_page "FinanceReport" do
  menu parent: "Student Payments", priority: 1, label: "Payment Report"
  breadcrumb do
    ["Financial ", "Report"]
  end

  page_action :foo, method: :get do
    @student = Student.where(semester: params[:search])

    redirect_to admin_financereport_path
  end
  
  content title: "Payment Report" do
    panel "Student Payment Report" do
      div do
        render "admin/FinanceReports/search_user"
      end
    end
  end
end
