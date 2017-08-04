function save_token() {
  token = Trello.token()
  tz = new Date().getTimezoneOffset();
  $.getJSON("/save_token?token="+ token + "&tz=" + tz, function(data){
    
    if(data.success){
      $.getJSON("/save_token?wh=true&token="+token, function(data){})
      console.log("if sve token data: " + data)
    }else{
      localStorage.clear()
      Trello.setToken()
      console.log("else clearing localstorage sve token data: " + data)
    }
  });
}
auto_due = function(enable){
  localStorage.setItem(auto_due, enable)
  $.getJSON("/auto_due?enable="+ enable, function(data){
  }); 
}