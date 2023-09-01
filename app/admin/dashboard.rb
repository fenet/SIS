ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do

      tabs do
        tab :student_related_report do
          div class: 'widget-container' do
          
            div class: 'widget widgetContainer' do
             div class: 'left' do
              span "admission type ", class: 'widget-title'
                div class: 'each' do
                   Student.group(:admission_type).count.each do |key, value|
                     div do
                      span "#{key}: "
                      span "#{value} student".pluralize(value)
                     end
                    end
                end
             end
            div class: 'right' do
              div class: 'icon' do
                 fa_icon('address-card')
              end
               div class: '' do
                 link_to "See chart",'/admin/dashboard#chart', class: 'link'
               end
              end
              div do
              # link_to truncate(page.body, length: 200) { link_to 'Read More', '#' }
              end
            end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
            
            div class: 'widget widgetContainer' do
              div class: 'left' do
               span "study level", class: 'widget-title'
                 div class: 'each' do
                  Student.group(:study_level).count.each do |key, value|
                    div do
                      span "#{key}: "
                      span "#{value} student".pluralize(value)
                     end
                    end 
                 end
              end
             div class: 'right' do
               div class: 'icon' do
                  fa_icon('address-card')
               end
                div class: '' do
                  link_to "See chart",'/admin/dashboard#study_level', class: 'link'
                end
               end
             end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
           
            
             
             div class: 'widget widgetContainer' do
              div class: 'left' do
               span "departement", class: 'widget-title'
                 div class: 'each' do
                  Student.all.joins(:department).group('departments.department_name').count.each do |key, value|
                    div do
                     span "#{key}: "
                     span "#{value} student".pluralize(value)
                    end
                   end
                 end
              end
             div class: 'right' do
               div class: 'icon' do
                  fa_icon 'object-group'
               end
                div class: '' do
                  link_to "See chart",'/admin/dashboard#student_in_dept', class: 'link'
                end
               end
             end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
                       

             div class: 'widget widgetContainer' do
              div class: 'left' do
               span "Program", class: 'widget-title'
                 div class: 'each' do
                  Student.all.joins(:program).group('programs.program_name').count.each do |key, value|
                    div do
                     span "#{key}: "
                     span "#{value} student".pluralize(value)
                    end
                   end 
                 end
              end
             div class: 'right' do
               div class: 'icon' do
                  fa_icon('calendar-days')
               end
                div class: '' do
                  link_to "See chart",'/admin/dashboard#student_in_program', class: 'link'
                end
               end
             end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
            
           
             div class: 'widget widgetContainer' do
              div class: 'left' do
               span "Document verification", class: 'widget-title'
                 div class: 'each' do
                  Student.group(:document_verification_status).count.each do |key, value|
                  div do
                    span "#{key}: ".camelize
                    span "#{value} document".pluralize(value)
                  end
                  end 
                 end
              end
             div class: 'right' do
               div class: 'icon' do
                fa_icon "book"

               end
                div class: '' do
                  link_to "See chart",'/admin/dashboard#document_verification', class: 'link'
                end
               end
             end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
            
             div class: 'widget widgetContainer' do
              div class: 'left' do
               span "Account verification", class: 'widget-title'
                 div class: 'each' do
                Student.group(:account_verification_status).count.each do |key, value|
                  div do
                   span "#{key}: ".camelize
                   span "#{value} account".pluralize(value)
                  end
                end 
              end
              end
             div class: 'right' do
               div class: 'icon' do
                  fa_icon('book')
               end
                div class: '' do
                  link_to "See chart",'/admin/dashboard#account_verification', class: 'link'
                end
               end
             end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
       
            end

          div class: 'main-chart-container' do
            div id: 'chart', class: 'left' do
              div class: 'main-chart1' do
                column_chart Student.group(:batch).count, dataset: {barThickness: 80, maxBarThickness: 100, borderColor: '#ccc',borderWidth: 6, clip: true, label: 'Number of student', barPercentage: 10, backgroundColor: 'red'}, title: "All Students in each batch", download: {filename: 'students', background: '#fff'}, stacked: true, colors: ["#fff", "#f2f2f2"], empty: "There is no student"
              end
            end 
            div class: 'right' do
              div do
               pie_chart Student.group(:admission_type).count, dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Student Admission Type", download: {filename: 'admission', background: '#fff'}
              end
            end
          end if RoleFilter.allowed_for_common(current_admin_user)
          hr
       div class: 'main-chart-container' do
         div class: 'other-chart', id: 'study_level' do
          column_chart Student.group(:study_level).count, dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Students study level", download: {filename: 'study_level', background: '#fff'}
         end
    
         div class: 'other-chart', id: 'student_in_dept' do
          pie_chart Student.all.joins(:department).group('departments.department_name').count,dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Students in each departement", download: {filename: 'student_in_dept', background: '#fff'}
         end
    
         div class: 'other-chart', id: 'student_in_program' do
          pie_chart Student.all.joins(:program).group('programs.program_name').count, dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Students in each program", download: {filename: 'student_in_program', background: '#fff'}
         end
    
         div class: 'other-chart', id: 'account_verification' do
          pie_chart Student.group(:account_verification_status).count,donut: true, dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Account Verification Status", download: {filename: 'account_verification', background: '#fff'}
         end
    
         div class: 'other-chart', id: 'document_verification' do
          pie_chart Student.group(:document_verification_status).count,donut: true, dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Document Verification Status", download: {filename: 'document_verification', background: '#fff'}
         end
       end
        end
      
        tab :general_report do
         
          div class: 'widget-container' do
            div class: 'widget widgetContainer' do
              div class: 'left' do
               span "departement in faculity", class: 'widget-title'
                 div class: 'each' do
                  Department.all.joins(:faculty).group("faculties.faculty_name").count.each do |key, value|
                    div do
                      span "#{key}: "
                      span value
                     end
                  end
                 end
              end
             div class: 'right' do
               div class: 'icon' do
                  fa_icon('calendar-days')
               end
                div class: '' do
                  link_to "See chart",'/admin/dashboard#dept_in_faculity', class: 'link'
                end
               end
             end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
          
             div class: 'widget widgetContainer' do
              div class: 'left' do
               span "Courses in program", class: 'widget-title'
                 div class: 'each' do
                  Course.all.joins(:program).group('programs.program_name').count.each do |key, value|
                    div do
                      span "#{key}: "
                      span value
                     end
                  end
                 end
              end
             div class: 'right' do
               div class: 'icon' do
                  fa_icon('calendar-days')
               end
                div class: '' do
                  link_to "See chart",'/admin/dashboard#course_in_program', class: 'link'
                end
               end
             end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
            
             div class: 'widget widgetContainer' do
              div class: 'left' do
               span "Programs in department", class: 'widget-title'
                 div class: 'each' do
                  if current_admin_user.role == 'department head'
                    RoleFilter.department_head_filter(current_admin_user).each do |key, value|
                     div do
                      span "#{key}: "
                      span "#{value} program".pluralize(value)
                     end
                    end
                   else
                     Program.all.joins(:department).group("departments.department_name").count.each do |key, value|
                       div do
                        span "#{key}: "
                        span "#{value} program".pluralize(value)
                       end
                      end 
                   end
                 end
              end
             div class: 'right' do
               div class: 'icon' do
                  fa_icon('user-pen')
               end
                div class: '' do
                  link_to "See chart",'/admin/dashboard#program_in_dept', class: 'link'
                end
               end
             end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
          
          
             div class: 'widget widgetContainer' do
              div class: 'left' do
               span "Curriculums in program", class: 'widget-title'
                 div class: 'each' do
                  if current_admin_user.role == 'department head'
                    RoleFilter.department_curriculum_filter(current_admin_user).each do |key, value|
                     div do
                      span "#{key}: "
                      span "#{value} program".pluralize(value)
                     end
                    end
                   else
                     Program.all.joins(:curriculums).group('programs.program_name').count.each do |key, value|
                       div do
                        span "#{key}: "
                        span "#{value} curriculum".pluralize(value)
                       end
                      end 
                   end
                 end
              end
             div class: 'right' do
               div class: 'icon' do
                  fa_icon('id-card')
                  # fa_icon ('fa-regular', 'calendar-days')
               end
                div class: '' do
                  link_to "See chart",'/admin/dashboard#curriculum_in_program', class: 'link'
                end
               end
             end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
          
                     
          end
    
          div class: 'main-chart-container' do
            div id: 'dept_in_faculity', class: 'left' do
              div class: 'main-chart1' do
                column_chart Department.all.joins(:faculty).group("faculties.faculty_name").count, dataset: {barThickness: 80, maxBarThickness: 100, borderColor: '#ccc',borderWidth: 6, clip: true, label: 'Number of departement', barPercentage: 10, backgroundColor: 'red'}, title: "All departement in each faculity", download: {filename: 'departements', background: '#fff'}, stacked: true, colors: ["#fff", "#f2f2f2"], empty: "There is no departement"
              end
            end 
            div class: 'right', id: 'course_in_program' do
              div do
              pie_chart  Course.all.joins(:program).group('programs.program_name').count, dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Course in each program", download: {filename: 'course', background: '#fff'}
              end
            end
          end if RoleFilter.allowed_for_common(current_admin_user)
         div class: 'main-chart-container' do
          div class: 'other-chart', id: 'program_in_dept' do
            pie_chart Program.all.joins(:department).group("departments.department_name").count, dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Programs in each department", download: {filename: 'department', background: '#fff'}
           end
    
           div class: 'other-chart', id: 'curriculum_in_program' do
            pie_chart Program.all.joins(:curriculums).group('programs.program_name').count, dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Curriculums in each Program", download: {filename: 'curriculum_in_program', background: '#fff'}
           end
          end
        end

        tab :invoice do
          div class: 'widget widgetContainer' do
            div class: 'left' do
             span "Invoice Report ", class: 'widget-title'
               div class: 'each' do
                Program.all.joins(:invoices).group('programs.program_name', :invoice_status).count.each do |key, value|
                    div do
                     span "#{key[0]}: #{key[1]}"
                     span "#{value} student".pluralize(value)
                    end
                   end
               end
            end
           div class: 'right' do
             div class: 'icon' do
                fa_icon('address-card')
             end
              div class: '' do
                link_to "See chart",'/admin/dashboard#invoive_report', class: 'link'
              end
             end
             div do
             # link_to truncate(page.body, length: 200) { link_to 'Read More', '#' }
             end
           end if RoleFilter.allowed_for_common(current_admin_user) || current_admin_user.role == "department head"
           div class: 'main-chart-container' do
            div class: 'other-chart', id: 'invoive_report' do
              pie_chart Program.all.joins(:invoices).group( :invoice_status).count, dataset: {borderRadius: 10, rotation: 10, borderJoinStyle: 'miter', borderColor: '#f2f2f2'}, title: "Invoice report in each program", download: {filename: 'invoice', background: '#fff'}
            end

          #  div class: 'main-chart-container' do
          #   div id: 'invoive_report', class: 'left' do
          #     div class: '' do
          #     end
          #   end 
          end
         end
        end


     # span class: "blank_slate" do
      #  div image_tag("leadstar.jpg", size: "250x150")
       # span "Welcome To Leadstar College"
       # small "This is Leadstar College's registrar and school management portal syst

     #end


 hr
     
  end 
  
end

end
