class PagesController < ApplicationController
	# before_action :authenticate_student!
  # layout false, only: [:home] 
  def home
    # authenticate_student!
  end

  def admission
  end
  def documents
    authenticate_student!
  end
  def digital_iteracy_quiz
  end
  def requirement
    
  end

  def profile
    authenticate_student!
  	@address = current_student.student_address
  	@emergency_contact = current_student.emergency_contact
  end

  def dashboard
    authenticate_student!
  	@address = current_student.student_address
  	@emergency_contact = current_student.emergency_contact
  end
end
