authorize_opts = {
  name: "Trelloman",
  type: "popup",
  expiration: "never",
  scope: { read: true, write: true, account: true},
  success: function() {
    save_token();
    console.log("success trelloman")
  },
  error: function(a){ 
    console.log("error trelloman")
    console.log(a)
  }
}

boardButtons = [
    {
      text: 'Open Overlay',
      callback: function(t){
        return t.overlay({
          url: './overlay.html',
          args: { rand: (Math.random() * 100).toFixed(0) }
        })
        .then(function(){
          return t.closePopup();
        });
      }
    },
    {
      text: 'Open Board Bar',
      callback: function(t){
        return t.boardBar({
          url: './board-bar.html',
          height: 200
        })
        .then(function(){
          return t.closePopup();
        });
      }
    }
  ]
