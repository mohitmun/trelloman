function save_token() {
  token = Trello.token()
  $.getJSON("/save_token?token="+ token, function(data){
    console.log("save token res")
    console.log(data)
  });
}
function auto_due(enable){
  localStorage.setItem(auto_due, enable)
  $.getJSON("/auto_due?enable="+ enable, function(data){
    console.log("auto_due ")
    console.log(data)
  }); 
}