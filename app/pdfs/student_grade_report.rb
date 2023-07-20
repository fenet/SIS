class StudentGradeReport < Prawn::Document
    def initialize(students)
        super(:page_size => 'A4')
        @students = students
        @students.each_with_index do |stud, index|
        text "Generated at #{Time.zone.now.strftime('%v-%R')}"
         move_down 200
         text "Full Name: <u>#{stud.student.name.full.capitalize}</u>         Sex: <u>#{stud.student.gender.capitalize}</u>           Year: <u>#{stud.student.year}</u> ",:inline_format => true, size: 12, font_style: :bold
         move_down 10
         text "Faculty: <u>#{stud.department.faculty.faculty_name.capitalize}</u>          Department: <u> #{stud.department.department_name.capitalize} </u>", :inline_format => true, size: 12, font_style: :bold
         move_down 10
         text "Program: <u>#{stud.program.admission_type.capitalize}</u>          Academic Year: <u>#{"stud.academic_calendar.calender_year"}</u>        Semester: <u>#{"stud.semester"}</u>   ", inline_format: true, size: 12, font_style: :bold
         move_down 10
        
         stroke_horizontal_rule
         move_down 20
         table each_data_in_table(stud, index) do 
            row(0).font_style = :bold
            self.header = true
         end
        end
        start_new_page
        header_footer


        
    end

    def header_footer
        repeat :all do
            bounding_box [bounds.left, bounds.top], :width  => bounds.width do
                font "Helvetica"
            image open("app/assets/images/logo.png"), fit: [120, 100], position: :center
                text "Hope Enterprise University College Registrar Portal", :align => :center, :size => 25
                text "Student grade report", size: 30, align: :center  
                stroke_horizontal_rule
            end
        
            bounding_box [bounds.left, bounds.bottom + 40], :width  => bounds.width do
                font "Helvetica"
                stroke_horizontal_rule
                move_down(5)
                text "Hope Enterprise University College Registrar Portal", :size => 16, align: :center
                text "+251-9804523154", :size => 16, align: :center

            end
          end
      
    end

    def each_data_in_table(data, index)
       [
        [ "No", "Course title","Course Code", "Cr.Hrs", "Letter Grade", "Grade Point", "Remark"],
        [ index+1, data.course.course_title, "00", "55", data.letter_grade, data.grade_point, ""]
       ]
    end


end