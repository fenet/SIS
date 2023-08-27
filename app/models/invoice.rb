class Invoice < ApplicationRecord
  after_create :add_invoice_item
  # after_update :update_total_price
  after_save :update_status
  ##validations
  validates :invoice_number, :presence => true
  validates :semester, :presence => true
  validates :year, :presence => true
  ##associations
  belongs_to :semester_registration
  belongs_to :student
  belongs_to :academic_calendar
  belongs_to :program
  belongs_to :department
  has_one :payment_transaction, as: :invoiceable, dependent: :destroy
  accepts_nested_attributes_for :payment_transaction, reject_if: :all_blank, allow_destroy: true
  has_many :invoice_items, as: :itemable, dependent: :destroy
  ##scope
  scope :recently_added, lambda { where("created_at >= ?", 1.week.ago) }
  # scope :undergraduate, lambda { self.registration.where(study_level: "undergraduate")}
  # scope :graduate, lambda { self.registration.where(study_level: "graduate")}
  # scope :online, lambda { self.registration.where(admission_type: "online")}
  # scope :regular, lambda { self.registration.where(admission_type: "regular")}
  # scope :extention, lambda { self.registration.where(admission_type: "extention")}
  # scope :distance, lambda { self.registration.where(admission_type: "distance")}
  scope :unpaid, lambda { where(invoice_status: "unpaid") }
  scope :pending, lambda { where(invoice_status: "pending") }
  scope :approved, lambda { where(invoice_status: "approved") }
  scope :denied, lambda { where(invoice_status: "denied") }
  scope :incomplete, lambda { where(invoice_status: "incomplete") }
  scope :due_date_passed, lambda { where("due_date < ?", Time.now) }

  # def total_price
  #    self.invoice_items.collect { |oi| oi.valid? ? (CollegePayment.where(study_level: self.semester_registration.study_level,admission_type: self.semester_registration.admission_type).first.tution_per_credit_hr * oi.course_registration.curriculum.credit_hour) : 0 }.sum + self.registration_fee
  #  end

  private

  def add_invoice_item
    self.semester_registration.course_registrations.each do |course|
      InvoiceItem.create do |invoice_item|
        invoice_item.itemable_id = self.id
        invoice_item.itemable_type = "Invoice"
        invoice_item.course_registration_id = course.id
        invoice_item.course_id = course.course.id
        invoice_item.created_by = self.created_by
        if self.semester_registration.mode_of_payment == "Monthly Payment"
          course_price = CollegePayment.where(study_level: self.semester_registration.study_level.strip, admission_type: self.semester_registration.admission_type.strip).first.tution_per_credit_hr * course.course.credit_hour / 4
          invoice_item.price = course_price
        elsif self.semester_registration.mode_of_payment == "Full Semester Payment"
          course_price = CollegePayment.where(study_level: self.semester_registration.study_level, admission_type: self.semester_registration.admission_type).first.tution_per_credit_hr * course.course.credit_hour
          invoice_item.price = course_price
        elsif self.semester_registration.mode_of_payment == "Half Semester Payment"
          course_price = CollegePayment.where(study_level: self.semester_registration.study_level, admission_type: self.semester_registration.admission_type).first.tution_per_credit_hr * course.course.credit_hour / 2
          invoice_item.price = course_price
        end
      end
    end
  end

  def update_status
    if (self.payment_transaction.present?) && (self.payment_transaction.finance_approval_status == "approved") && (self.invoice_status == "approved")
      # self.semester_registration.update_columns(registrar_approval_status: "approved")
      self.semester_registration.update_columns(finance_approval_status: "approved")
      if self.semester_registration.total_price == 0
        tution_price = (self.semester_registration.course_registrations.collect { |oi| oi.valid? ? (CollegePayment.where(study_level: self.semester_registration.study_level.strip, admission_type: self.semester_registration.admission_type.strip).first.tution_per_credit_hr * oi.course.credit_hour) : 0 }.sum) + self.registration_fee + self.late_registration_fee
        self.semester_registration.update_columns(total_price: tution_price)
        self.semester_registration.update_columns(registration_fee: self.registration_fee)
        self.semester_registration.update_columns(late_registration_fee: self.late_registration_fee)
        remaining_amount = (tution_price - self.total_price).abs
        self.semester_registration.update_columns(remaining_amount: remaining_amount)
        total_enrolled_course = self.semester_registration.course_registrations.count
        self.semester_registration.update_columns(total_enrolled_course: total_enrolled_course)
      end
    end
  end

  # def update_semester_registration
  #   self[:total_price] = total_price
  # end
end
