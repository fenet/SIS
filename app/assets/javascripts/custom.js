$(function () {
  $("#year").on("change", (e) => {
    const year = e.target.value;
    const semester = $("#semester").val();
    const current_admin_user = $("#current_admin_user").val();

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
        $courseList = $("#course-list");
        $courseList.text("");
        $courseList.append(`<option value="" selected>Select Courses</option>`);

        for (let i = 0; i < result.length; i++) {
          $courseList.append(
            $(
              `<option value=${result[i].course.id}>Semester ${result[i].course.course_title}</option>`
            )
          );
        }
      },
    });
  });

  $("#semester").on("change", (e) => {
    const semester = e.target.value;
    const year = $("#year").val();
    const current_admin_user = $("#current_admin_user").val();

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
        $courseList = $("#course-list");
        $courseList.text("");

        for (let i = 0; i < result.length; i++) {
          $courseList.append(
            $(
              `<option value=${result[i].course.id}>Semester ${result[i].course.course_title}</option>`
            )
          );
        }
        $courseList.append(`<option value="" selected>Select Courses</option>`);
      },
    });
  });

  const show = (e) => {
    const target = e.target;
    const course_registration = target.dataset.cr;
    const student_id = target.dataset.student;
    const course_id = target.dataset.course;
    const admin = target.dataset.admin;
    const assessment_title = target.dataset.assessment;
    const result = target.value;
    const weight = target.dataset.weight;
    if (result > 100 || result < 0) {
      alert(`Your input is greater than 100, please fill below 101 and above -1`)
    } else {
      $.ajax({
        type: "post",
        url: "/assessmens",
        dataType: "json",
        data: { course_id: course_id, result: result, admin_user_id: admin, student_id: student_id, assessment_title: assessment_title, course_registration_id: course_registration },
        success: function (results) {
          if (results.status == "created") {
            $(target).css({ "border": "2px solid green" })

          } else {
            $(target).css({ "border": "2px solid red" })
            alert(results.result)
          }

        }
      })
    }

  };

  $("#course-list").on("change", (e) => {
    course_id = e.target.value;
    const current_admin_user = $("#current_admin_user").val();
    $tbody = $("#student-list");
    $thead = $("#thead>tr");
    $.ajax({
      type: "GET",
      url: "/assessmens",
      dataType: "json",
      data: { course_id: course_id, current_admin_user: current_admin_user },
      success: function (results) {
        // console.log(results);
        let students = JSON.parse(results.student);
        let assessment_plans = JSON.parse(results.assessment_plan);
        // results = students.map((result) => result.student);

        if (results == []) {
          $tbody.text("We didn't find a student");
        } else {
          $tbody.text("");
          students.forEach((result) => {
            $tr = $("<tr> </tr>");
            let inputs = assessment_plans.map((assessment_plan) => {
              const input = document.createElement("input");
              input.setAttribute("type", "number");
              input.setAttribute("max", assessment_plan.assessment_weight);
              input.setAttribute("style", "width: 100px");
              input.setAttribute("data-cr", result.id);
              input.setAttribute("data-student", result.student.id);
              input.setAttribute("data-course", result.course.id);
              input.setAttribute("data-admin", current_admin_user);
              input.setAttribute("data-assessment", assessment_plan.assessment_title);
              input.setAttribute("data-weight", assessment_plan.assessment_weight);


              input.addEventListener("change", show);
              const td = document.createElement("td");
              td.append(input);
              return td;
            });
            $td = $("<td>  </td>");
            $tr.append(`<td>${result.student.first_name + " " + result.student.last_name
              }</td>
                        <td>${result.student.semester}</td>+
                        <td>${result.student.year}</td>`);
            $tr.append(inputs);
            $tbody.append($tr);
          });
          if (assessment_plans) {
            assessment_plans.forEach((assessment_plan) => {
              $thead.append(`
              <th>${assessment_plan.assessment_title} (${assessment_plan.assessment_weight})</th>
              `);
            });
          }
        }
      },
    });
  });
});
