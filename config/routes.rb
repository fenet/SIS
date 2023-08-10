Rails.application.routes.draw do
  get 'student_temporary/index', as: "student_temporary"
  post 'student/tempo/generate', to: 'student_temporary#generate_pdf', as: 'generate_student_tempo'
  get 'pdf_grade_reports/index', as: "pdf_gread_report"
  get 'prepare_pdf.pdf', to: "pdf_grade_reports#prepare_pdf"
  get 'student/tempo/generate.pdf', to: 'student_temporary#generate_pdf'
  get 'graduation/approval', to: 'student_temporary#graduation_approval', as: 'graduation_approval'
  get 'graduation/approval/form', to: 'student_temporary#graduation_approval_form', as: 'graduation_approval_form'
  get 'approved', to: "student_temporary#approved", as: 'approved'
  get 'student/generate/copy', to: 'student_copy#index', as: 'student_copy'
post 'student_copy/generate_student_copy', as: 'generate_student_copy'
  resources :grade_reports
  resources :academic_calendars, only: [:show, :index]
  # devise_for :students
  
  devise_for :students, controllers: {
    registrations: 'registrations'
  }
  authenticated :student do
    root 'pages#dashboard', as: 'authenticated_user_root'
  end
  
  post 'prepare_pdf', to: "pdf_grade_reports#prepare_pdf", as: 'prepare_pdf'
  get 'admission' => 'pages#admission'
  get 'documents' => 'pages#documents'
  get 'profile' => 'pages#profile'
  get 'grade_report' => 'pages#grade_report'
  get 'digital-iteracy-quiz' => 'pages#digital_iteracy_quiz'
  get 'requirements' => 'pages#requirement'
  get 'home' => 'pages#home'
  resources :almunis
  resources :semester_registrations
  resources :invoices
  resources :profiles

  resources :payment_methods
  resources :payment_transactions
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # root to: 'application#home'
end
