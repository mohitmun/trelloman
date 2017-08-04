/* global TrelloPowerUp */

var t = TrelloPowerUp.iframe();

// you can access arguments passed to your iframe like so
var arg = t.arg('arg');

t.render(function(){
  // make sure your rendering logic lives here, since we will
  // recall this method as the user adds and removes attachments
  // from your section
  t.card('attachments')
  .get('attachments')
  .filter(function(attachment){
    return attachment.url.indexOf(gon.host) == 0;
  })
  .then(function(yellowstoneAttachments){
    var urls = yellowstoneAttachments.map(function(a){ return a.url; });
    document.getElementById('urls').textContent = urls.join(', ');
  })
  .then(function(){
    return t.sizeTo('#content');
  });
});
document.getElementById("INPUT_1").onclick = function() {
  to =  document.getElementsByName("to")[0].value
  sub =  document.getElementsByName("sub")[0].value
  body =  document.getElementsByName("body")[0].value
  getJSON("send_email?to=" + to + "&sub=" + sub + "&body=" + body, function(data){
    b = document.getElementById("main_mess")
    var aTag = document.createElement('a');
    aTag.setAttribute('href',data.url);
    aTag.setAttribute('target',"_blank");
    aTag.innerHTML = " Message sent! Click here to view";
    b.appendChild(aTag)
  })
}
var getJSON = function(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.responseType = 'json';
    xhr.onload = function() {
      var status = xhr.status;
      if (status == 200) {
        callback(xhr.response);
      } else {
        callback(status);
      }
    };
    xhr.send();
};