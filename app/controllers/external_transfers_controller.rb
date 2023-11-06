class ExternalTransfersController < ApplicationController
  before_action :set_external_transfer, only: [:show, :approved, :edit, :destroy, :update, :approval]

  def new
    @external_transfer = ExternalTransfer.new
    @departments = Department.select(:id, :department_name)
  end

  def show
  end

  def edit
  end

  def approval
    @disable_nav = true
    @approved_by = params[:approved_by]
  end

  def search
    search_result = ExternalTransfer.find_by(previous_student_id: params[:query])
    if search_result.present?
      redirect_to external_transfer_path(search_result.id)
    else
      redirect_to new_external_transfer_path, alert: "No applicant found for this ID, please remember your student ID or if you didn't apply yet please apply first "
    end
  end

  def create
    transfer = ExternalTransfer.new(external_transfer_params)
    if transfer.save
      redirect_to external_transfer_path(transfer.id), notice: "Application was successfully sent!"
    else
      render :new
    end
  end

  def approved
    respond_to do |format|
      if @external_transfer.update(external_transfer_params)
        format.html { redirect_to admin_externaltransfer_path, notice: "Your application was successfully updated." }
      else
        format.html { render :approval, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @external_transfer.update(external_transfer_params)
        format.html { redirect_to external_transfer_path(@external_transfer.id), notice: "Your application was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @external_transfer.destroy
    respond_to do |format|
      format.html { redirect_to admission_path, notice: "Your application was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def external_transfer_params
    params.require(:external_transfer).permit(:first_name, :approved_by, :email, :message, :transcript, :study_level, :admission_type, :last_name, :department_id, :previous_institution, :previous_student_id, :status)
  end

  def set_external_transfer
    @external_transfer = ExternalTransfer.find(params[:id])
  end
end
