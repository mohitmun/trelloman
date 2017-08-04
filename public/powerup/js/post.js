function save_token() {
  token = Trello.token()
  $.getJSON("/save_token?token="+ token, function(data){
    console.log("save token res")
    console.log(data)
  });
}
auto_due = function(enable){
  localStorage.setItem(auto_due, enable)
  $.getJSON("/auto_due?enable="+ enable, function(data){
    console.log("auto_due ")
    console.log(data)
  }); 
}