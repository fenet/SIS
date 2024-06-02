require 'prawn'

class AttendancePdfGenerator
  def initialize(attendance)
    @attendance = attendance
    @month = Date.today.strftime("%B")
  end

  def render
    Prawn::Document.new do |pdf|
      pdf.text "HEUC Portal Attendance Sheet", align: :center, size: 30
      pdf.move_down 20
      pdf.text "Course: #{@attendance.course.course_title}", size: 14
      pdf.text "Section: #{@attendance.section.section_full_name}", size: 14
      pdf.text "Year: #{@attendance.year}", size: 14
      pdf.text "Semester: #{@attendance.semester}", size: 14
      pdf.text "Month: #{@month}", size: 14
      pdf.move_down 10
      pdf.text "Date: ____________________", size: 14 # Place for the date
      pdf.move_down 10

      attendance_table(pdf)
    end.render
  end

  private

  def attendance_table(pdf)
    # Define the header with days of the week
    table_data = [["Student Name", "Student ID", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]]
    
    # Add a row for each student
    @attendance.section.students.each do |student|
      student_data = ["#{student.first_name} #{student.last_name}", student.student_id, "P / A", "P / A", "P / A", "P / A", "P / A", "P / A"]
      table_data << student_data
    end

    # Generate the table in the PDF
    pdf.table(table_data, header: true) do |table|
      table.row(0).font_style = :bold
      table.header = true
      table.row_colors = ['DDDDDD', 'FFFFFF']
      table.cell_style = { border_width: 1, padding: [8, 12] }
    end
  end
end
