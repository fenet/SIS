class StudentGradeReport < Prawn::Document
  def initialize(students)
    super(:page_size => "A4")
    @students = students
    @students.each_with_index do |stud, index|
      move_down 200
      text "Full Name: <u>#{stud.student.name.full.capitalize}</u>         Sex: <u>#{stud.student.gender.capitalize}</u>           Year: <u>#{stud.student.year}</u> ", :inline_format => true, size: 12, font_style: :bold
      move_down 10
      text "Faculty: <u>#{stud.department.faculty.faculty_name.capitalize}</u>          Department: <u> #{stud.department.department_name.capitalize} </u>", :inline_format => true, size: 12, font_style: :bold
      move_down 10
      text "Program: <u>#{stud.program.admission_type.capitalize}</u>          Academic Year: <u>#{stud.academic_calendar.calender_year}</u>        Semester: <u>#{stud.semester}</u>   ", inline_format: true, size: 12, font_style: :bold
      move_down 10

      stroke_horizontal_rule
      move_down 20
      table each_data_in_table(stud, index) do
        row(0).font_style = :bold
        row(0).size = 12
      end
      move_down 10
      table preview_table(stud) do
        column(1..3).style :align => :center
        row(0).font_style = :bold
        row(0).size = 12
      end
    end
    start_new_page
    header_footer
  end

  def header_footer
    repeat :all do
      bounding_box [bounds.left, bounds.top], :width => bounds.width do
        font "Helvetica"
        image open("app/assets/images/leadstar.png"), fit: [120, 100], position: :center
        text "Leadstar College Registrar Portal", :align => :center, :size => 25
        text "Student grade report", size: 30, align: :center
        stroke_horizontal_rule
      end

      bounding_box [bounds.left, bounds.bottom + 40], :width => bounds.width do
        font "Helvetica"
        stroke_horizontal_rule
        move_down(5)
        text "Leadstar College Registrar Portal", :size => 16, align: :center
        text "+251-9804523154", :size => 16, align: :center
      end
    end
  end

  def each_data_in_table(data, index)
    [
         ["No", "Course title", "Course Code", "Cr.Hrs", "Letter Grade", "Grade Point", "Remark"],
       ] + data.semester_registration.course_registrations.where(enrollment_status: "enrolled").includes(:student_grade).map.with_index do |course, index|
      [index + 1, course.course.course_title, course.course.course_code, course.course.credit_hour, StudentGrade.find_by(course: course.course).letter_grade, StudentGrade.find_by(course: course.course).grade_point, ""]
    end
  end

  def preview_table(data)
    [
          ["", "Cr.Hrs", "Grade Point", "Cumlative Grade Point\nAverage(CGPA)"],
          ["Current Semester Total", data.total_credit_hour, data.total_grade_point, data.cgpa],
          ["Previous Total"] + get_previous_total(data.student, data.semester),
          ["Cumulative"] + get_cumulative(get_previous_total(data.student, data.semester), data.total_credit_hour, data.total_grade_point, data.cgpa),
    
        ]
  end

  def get_previous_total(student, current_semester)
    record = GradeReport.select(:total_credit_hour, :total_grade_point, :cgpa).where("semester<#{current_semester}").where(student: student)
    ch = 0.0
    rgp = 0.0
    cgpa = 0.0
    record.each do |grade|
      ch += grade.total_credit_hour
      rgp += grade.total_grade_point
      cgpa += grade.cgpa
    end
    [ch, rgp, cgpa]
  end

  def get_cumulative(previous, *current)
    [previous[0] + current[0], previous[1] + current[1], previous[2] + current[2]]
  end
end
