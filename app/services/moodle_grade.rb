require "net/https"

module MoodleGrade
  class << self
    def moodle_grade(student_grade, credit_hour)
      is_fetched = false
      url = URI("https://lms.leadstar.edu.et/webservice/rest/server.php")
      moodle = MoodleRb.new("57f6f6934c33bffef1edbef2559c523c", "https://lms.leadstar.edu.et/webservice/rest/server.php")
      lms_student = moodle.users.search(email: "#{student_grade.student.email}")
      courses = moodle.courses
      lms_course = courses.search("#{student_grade.course.course_code}")
      if lms_student.any? || lms_course["courses"].any?
        is_fetched = true
        course_id = lms_course["courses"].last["id"]
        user_id = lms_student.last["id"]
        grade = courses.grade_items(course_id, user_id).last
        result = grade["gradeitems"].last
        letter_grade = result["gradeformatted"]
        assesment_total = result["graderaw"]
        grade_point = get_grade_point(letter_grade, credit_hour)
        student_grade.update(assesment_total: assesment_total, letter_grade: letter_grade, grade_point: grade_point)
      end
      is_fetched
    end

    private

    def get_grade_point(grade_letter, credit_hour)
      grade_letter = grade_letter.upcase
      if grade_letter == "A" || grade_letter == "A+"
        4 * credit_hour
      elsif grade_letter == "A-"
        3.75 * credit_hour
      elsif grade_letter == "B+"
        3.5 * credit_hour
      elsif grade_letter == "B"
        3 * credit_hour
      elsif grade_letter == "B-"
        2.75 * credit_hour
      elsif grade_letter == "C+"
        2.5 * credit_hour
      elsif grade_letter == "C"
        2 * credit_hour
      elsif grade_letter == "C-"
        1.75 * credit_hour
      elsif grade_letter == "D"
        1 * credit_hour
      elsif grade_letter == "F"
        0
      end
    end
  end
end
