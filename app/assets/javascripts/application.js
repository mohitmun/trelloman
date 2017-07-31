// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap.min
//= require owl.carousel.min
//= require jquery.stellar.min
//= require wow.min
//= require waypoints.min
//= require isotope.pkgd.min
//= require classie
//= require jquery.easing.min
//= require jquery.counterup.min
//= require smoothscroll
//= require bootstrap-datepicker.min
//= require theme
//= require blocksit
//= require jquery.steps.min
$("#wizard").steps({
  onFinished: function (event, currentIndex) { 
    console.log("FINESHED")
    $('.attempts_forms form').submit();
  },
  onStepChanged: function (event, currentIndex, priorIndex) { 
    // console.log("hellow " + currentIndex)
    // $("[href='#next']").text("Next")
    // $("[href='#previous']").text("Previous")
    // $("[href='#previous']").text("Previous").removeClass("hidden");
    // if(currentIndex == 0){
    //   $(".module_list").removeClass("hidden");
    //   $("[href='#previous']").text("Previous").addClass("hidden");
    //   $("[href='#next']").text("Begin Activity")
      
    // }
    // if(currentIndex == 1){
    //   $(".module_des").removeClass("hidden")  
    //   $(".module_list").addClass("hidden");
    //   $("[href='#next']").text("Begin Test")
    //   $("[href='#previous']").text("Previous").addClass("hidden");
    // }else{
    //   $(".module_des").addClass("hidden")
    // }
  }
});

$(document).on("click", "#begin-test", function(argument) {
  $("#video_brief_section").addClass("hidden");
  $("#module_des").addClass("hidden");
  $("#wizard.f20").removeClass("hidden");
});


$(document).on("click", "#begin_activity", function(argument) {
  $("#module_brief").addClass("hidden");
  $("#module_list").addClass("hidden");
  $("#module_des").removeClass("hidden");
  $("#video_brief_section").removeClass("hidden")
});

if(window.direct_ques){
  $("#module_brief").addClass("hidden");
  $("#module_list").addClass("hidden");
  $("#module_des").removeClass("hidden");
  $("#video_brief_section").removeClass("hidden")
  $("#video_brief_section").addClass("hidden");
  $("#module_des").addClass("hidden");
  $("#wizard.f20").removeClass("hidden");
}


$("#wizard .steps").hide()
$("[href='#']").on("click", function(e){
                e.preventDefault();
            });

          $(document).on("click", ".fa.fa-search", function(e) { 
              e.preventDefault();
              console.log("chacha")
              $("#DIV_1").toggle();
          });


  // $(document).ready(function () {
  //       $(document).bind("contextmenu", function (e) {
  //           alert("Right Click not Avaibalbe !!!");
  //           e.preventDefault();
  //       }) });

  $(document).ready(function(){ 
    document.oncontextmenu = function() {return false;};

    $(document).mousedown(function(e){ 
      if( e.button == 2 ) { 
        return false; 
      } 
      return true; 
    }); 
  });
$(window).load(function(){

    $('#container_block').BlocksIt({
      numOfCol: 3,
      offsetX: 8,
      offsetY: 8,
      blockElement: '.grid'
    });
    $('#post_published_at').datepicker({ format: "yyyy/mm/dd",
    todayHighlight: true});
    $("object").oncontextmenu = function() {console.log("object click"); return false;};
})

  if(window.grey_back){
    window.grey_back = false
    $("body").css("background", "#e6e6e6");
  }

  $(document).on("click", ".search_button", function(){
    v = $(".search_value").val();
    window.open("/blog?search=" + v, "_self");
  })
