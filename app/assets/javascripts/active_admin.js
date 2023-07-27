//= require jquery
//= require active_admin/base
//= require activeadmin_addons/all
//= require activestorage
//= require active_storage_drag_and_drop
//= require active_admin_scoped_collection_actions
//= require active_admin_sidebar

$(document).ready(function(){

  $("#student_photo").change(function(data){

    var imageFile = data.target.files[0];
    var reader = new FileReader();
    reader.readAsDataURL(imageFile);

    reader.onload = function(evt){
      $('#imagePreview').attr('src', evt.target.result);
      $('#imagePreview').hide();
      $('#imagePreview').fadeIn(650);
    }
    
  });
  $("#payment_method_bank_logo").change(function(data){

    var imageFile = data.target.files[0];
    var reader = new FileReader();
    reader.readAsDataURL(imageFile);

    reader.onload = function(evt){
      $('#imagePreview').attr('src', evt.target.result);
      $('#imagePreview').hide();
      $('#imagePreview').fadeIn(650);
    }
    
  });

  if ($('#purchase_type_of_supplier').val() == ""){
    $('.grp1').hide();
    $('.grp2').hide();
  }else if($('#purchase_type_of_supplier').val() == 'International Supplier'){
    $('.grp1').show();
    $('.grp2').hide();
  }else if($('#purchase_type_of_supplier').val() == 'Local Vender'){
    $('.grp1').hide();
    $('.grp2').show();
  }
  
  
  
  $('#purchase_type_of_supplier').change( function() {
    var value;
    
    value = $(this).val();
    if (value === 'International Supplier') {
      $('.grp1').show();
      $('.grp2').hide();
    } else if (value === 'Local Vender') {
      $('.grp1').hide();
      $('.grp2').show();
    }
  });

  $('#header').before("<div class='headline'><div class='banner-logo'></div> <h1 class='banner-title'>Leadstar College Registrar Portal</h1></div>");




});