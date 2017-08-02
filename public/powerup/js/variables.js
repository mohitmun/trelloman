// before_auth_overlay_options = gon.before_auth_overlay_options.map(function(item) {
  
//   return {text: item.text, callback: function(t){

//   }}
// })
if (!Trello.authorized()){
  boardButtons = [
    {
      text: "Authorize Trello",
      callback: function(t) {
        opts = {
          name: "wow",
          type: "popup",
          expiration: "never",
          success: function() {
            save_token();
            console.log("success trelloman")
          },
          error: function(){ 
            console.log("error trelloman")
          }
        }
        Trello.authorize(opts) 
      }
    }
  ]
}else{
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
}