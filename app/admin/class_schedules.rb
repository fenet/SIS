ActiveAdmin.register ClassSchedule do
  permit_params :course_id, :program_id, :section_id, :day_of_week, :start_time, :end_time, :classroom, :class_type, :instructor_name

  index do
    selectable_column
    id_column
    column :course
    column :program
    column :section
    column :day_of_week
    column :start_time
    column :end_time
    column :classroom
    column :class_type
    column :instructor_name
    actions
  end

  filter :course
  filter :program
  filter :section
  filter :day_of_week

  form do |f|
    f.inputs do
      f.input :program
      f.input :course, collection: Course.all.map { |c| [c.course_title, c.id] }
      f.input :section
      f.input :day_of_week
      f.input :start_time, as: :time_picker
      f.input :end_time, as: :time_picker
      f.input :classroom
      f.input :class_type
      f.input :instructor_name
    end
    f.actions
  end
end
