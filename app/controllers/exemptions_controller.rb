class ExemptionsController < ApplicationController
  before_action :set_applicant_id, only: [:new, :create, :index, :edit]

  def index
    @exemption = Exemption.where(external_transfer: @applicant)
  end

  def edit
    @exemption = Exemption.where(id: params[:id]).where(external_transfer: @applicant).last
  end

  def new
    @exemption = Exemption.new
  end

  def create
    exemption = Exemption.new(exemption_params)
    exemption.external_transfer = @applicant
    if exemption.save
      redirect_to new_exemptions_path(@applicant), notice: "Course exemptions was successfully created!"
    else
      render :new
    end
    # console
  end

  private

  def exemption_params
    params.require(:exemption).permit(:course_title, :letter_grade, :course_code, :credit_hour)
  end

  def set_applicant_id
    @applicant = ExternalTransfer.find(params[:applicant_id])
  end
end
