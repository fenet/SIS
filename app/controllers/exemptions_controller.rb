class ExemptionsController < ApplicationController
  before_action :set_applicant_id, only: [:new, :create, :index, :edit, :update]

  before_action :get_approver, only: [:index, :edit, :new]
  before_action { @disable_nav = true }

  def index
    @exemption = Exemption.where(external_transfer: @applicant)
    # @approved_by = params[:approved_by]
  end

  def edit
    @exemption = Exemption.where(id: params[:id]).where(external_transfer: @applicant).last
    # @approved_by = params[:approved_by]
  end

  def new
    @exemption = Exemption.new
    # @approved_by = "#{params[:approved_by]}"
  end

  def create
    exemption = Exemption.new(exemption_params)
    exemption.external_transfer = @applicant
    if exemption.save
      redirect_to new_exemptions_path(@applicant, exemption.department_approval), notice: "Course exemptions was successfully created!"
    else
      render :new
    end
  end

  def update
    @exemption = Exemption.where(id: params[:id]).where(external_transfer: @applicant).last

    respond_to do |format|
      if @exception.update(external_transfer_params)
        format.html { redirect_to index_exemptions_path(@applicant, @approved), notice: "Your application was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    applicant = params[:applicant_id]

    @exemption = Exemption.where(id: params[:id]).where(external_transfer: applicant).last
    @approved_by = params[:approved_by]

    @exemption.destroy
    respond_to do |format|
      format.html { redirect_to index_exemptions_path(applicant, @approved_by), notice: "Course exemption was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def exemption_params
    params.require(:exemption).permit(:course_title, :department_approval, :letter_grade, :course_code, :credit_hour)
  end

  def set_applicant_id
    @applicant = ExternalTransfer.find(params[:applicant_id])
  end

  def get_approver
    @approved_by = params[:approved_by]
  end
end
