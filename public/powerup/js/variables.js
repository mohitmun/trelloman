authorize_opts = function(interactive){
  return {
    name: gon.application_name,
    type: "popup",
    expiration: "never",
    interactive: interactive,
    scope: { read: true, write: true, account: true},
    success: function() {
      save_token();
    },
    error: function(){ 
      localStorage.clear()
    }
  }
}
var boardButtonCallback = function(t){
  return t.popup({
    title: 'Options',
    items: boardButtons()
  });
};
topBoardButtons =  function(){
  if(Trello.authorized()){
    return []
  }else{
    // return [{
    //   icon: WHITE_ICON,
    //   text: "Authorize " + gon.application_name,
    //   callback: function(){
    //     Trello.authorize(authorize_opts(true))
    //   }
    // }]
    return []
  }
}
boardButtons = function() {
  result_if_not_enabled = [
    {
      text: 'Enable Auto Due Date',
      callback: function(t){
        enable = true
        localStorage.setItem("auto_due", enable)
        $.getJSON("/auto_due?enable="+ enable, function(data){
          console.log("auto_due ")
          console.log(data)
        });
        t.closePopup()
        // return t.overlay({
        //   url: './overlay.html',
        //   args: { rand: (Math.random() * 100).toFixed(0) }
        // })
        // .then(function(){
        //   return t.closePopup();
        // });
      }
    }
    // ,
    // {
    //   text: 'Open Board Bar',
    //   callback: function(t){
    //     return t.boardBar({
    //       url: './board-bar.html',
    //       height: 200
    //     })
    //     .then(function(){
    //       return t.closePopup();
    //     });
    //   }
    // }
  ]
  result_if_enabled = [
    {
      text: 'Disable Auto Due Date',
      callback: function(t){
        enable = false
        localStorage.setItem("auto_due", enable)
        $.getJSON("/auto_due?enable="+ enable, function(data){
          console.log("auto_due ")
          console.log(data)
        }); 
        t.closePopup()
      }
    }
  ]
  auto_due = localStorage.getItem("auto_due")
  console.log("auto_due:" + auto_due)
  if (auto_due == "true"){
    return result_if_enabled
  }else{
    return result_if_not_enabled
  }

}