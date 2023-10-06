require "net/https"

module MoodleGrade
  class << self
    def moodle_grade(student_grade)
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
        student_grade.update(assesment_total: assesment_total, letter_grade: letter_grade)     
      end
      is_fetched
    end
  end
end
