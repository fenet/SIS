$(function () {
  // Handle change on year and semester to populate course list
  $("#year, #semester").on("change", function () {
    const year = $("#year").val();
    const semester = $("#semester").val();
    const current_admin_user = $("#current_admin_user").val();

    if (year && semester) {
      $.ajax({
        type: "GET",
        url: "/assessmens/find_course",
        dataType: "json",
        data: {
          year: year,
          semester: semester,
          current_admin_user: current_admin_user,
        },
        success: function (result) {
          console.log("Fetched result:", result);

          const $courseList = $("#course-list");
          const $sectionList = $("#section");

          $courseList.empty();
          $courseList.append(`<option value="" selected>Select Courses</option>`);

          $sectionList.empty();
          $sectionList.append(`<option value="" selected>Select Section</option>`);

          result.forEach(item => {
            if (item.course && item.course.id) {
              $courseList.append(
                $(`<option value="${item.course.id}">${item.course.course_title}</option>`)
              );
            }
            if (item.sections) {
              item.sections.forEach(section => {
                if (section.id) {
                  $sectionList.append(
                    $(`<option value="${section.id}">${section.name}</option>`)
                  );
                }
              });
            }
          });

          console.log("Courses and sections populated.");
        },
        error: function (error) {
          console.error("Error fetching courses and sections:", error);
        }
      });
    }
  });

  // Handle change on course and section to fetch students and assessment plans
  $("#course-list, #section").on("change", function () {
    const course_id = $("#course-list").val();
    const section_id = $("#section").val();
    const current_admin_user = $("#current_admin_user").val();

    if (course_id && section_id) {
      const $tbody = $("#student-list");
      const $thead = $("#thead>tr");

      $.ajax({
        url: '/assessmens',
        method: 'GET',
        data: {
          course_id: course_id,
          section: section_id,
          current_admin_user: current_admin_user
        },
        success: function(response) {
          try {
            console.log('Raw response:', response);

            if (!response.student || !response.assessment_plan) {
              console.error('Unexpected response structure:', response);
              return;
            }

            let students = JSON.parse(response.student);
            let assessmentPlans = JSON.parse(response.assessment_plan);

            console.log('Parsed students:', students);
            console.log('Parsed assessment plans:', assessmentPlans);

            $tbody.empty();
            $thead.empty();

            if (students.length > 0) {
              $thead.append(`<th>ID</th><th>Name</th><th>Year</th><th>Semester</th>`);

              assessmentPlans.forEach(plan => {
                $thead.append(`<th>${plan.assessment_title}</th>`);
              });

              students.forEach(student => {
                console.log('Student data:', student);
                let studentRow = `
                  <tr>
                    <td>${student.student_id}</td>
                    <td>${student.first_name} ${student.middle_name} ${student.last_name}</td>
                    <td>${student.year}</td>
                    <td>${student.semester}</td>`;

                assessmentPlans.forEach(plan => {
                  const courseRegistration = student.course_registrations.find(cr => cr.course_id == course_id);
                  const courseRegistrationId = courseRegistration ? courseRegistration.id : '';
                  console.log('Course Registration ID:', courseRegistrationId);

                  studentRow += `
                    <td>
                      <input type="number" data-cr="${courseRegistrationId}" data-student="${student.id}" data-course="${course_id}" data-admin="${current_admin_user}" data-assessment="${plan.assessment_title}" class="assessment-input" />
                    </td>`;
                });

                studentRow += `</tr>`;
                $tbody.append(studentRow);
              });
            } else {
              $tbody.append('<tr><td colspan="4">No students found</td></tr>');
            }

            console.log('Final results:', { students, assessmentPlans });
          } catch (error) {
            console.error('Error parsing response:', error);
          }
        },
        error: function(jqXHR, textStatus, errorThrown) {
          console.error('Error fetching data:', textStatus, errorThrown);
        }
      });
    }
  });

  // Handle change event on assessment inputs
  $(document).on('change', '.assessment-input', function (e) {
    const target = e.target;
    const course_registration = target.dataset.cr;
    const student_id = target.dataset.student;
    const course_id = target.dataset.course;
    const admin = target.dataset.admin;
    const assessment_title = target.dataset.assessment;
    const result = target.value;

    if (result > 100 || result < 0) {
      alert("Your input is greater than 100, please fill below 101 and above -1");
    } else {
      $.ajax({
        type: "post",
        url: "/assessmens",
        dataType: "json",
        data: {
          course_id: course_id,
          result: result,
          admin_user_id: admin,
          student_id: student_id,
          assessment_title: assessment_title,
          course_registration_id: course_registration,
        },
        success: function (results) {
          if (results.status == "created") {
            $(target).css({ "border": "2px solid green" });
          } else {
            $(target).css({ "border": "2px solid red" });
            alert(results.result);
          }
        },
        error: function (error) {
          console.error("Error saving assessment:", error);
        }
      });
    }
  });
});
