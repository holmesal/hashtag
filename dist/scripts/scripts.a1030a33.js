(function(){"use strict";angular.module("shortwaveApp",["ngAnimate","ngCookies","ngResource","ngRoute","ngSanitize","ngTouch","firebase","luegg.directives","angularFileUpload","emoji","monospaced.elastic","angularMoment","ngClipboard"]).config(["$routeProvider","$locationProvider","ngClipProvider",function(a,b,c){return a.when("/",{templateUrl:"views/main.html",controller:"MainCtrl"}).when("/dashboard",{templateUrl:"views/dashboard.html",controller:"DashboardCtrl",resolve:{user:["User",function(a){return a.get()}],authUser:["User",function(a){return a.auth()}]}}).when("/:channel",{templateUrl:"views/invite.html",controller:"InviteCtrl",resolve:{user:["User",function(a){return a.get()}]}}).otherwise({redirectTo:"/dashboard"}),b.html5Mode(("undefined"!=typeof process&&null!==process?process.versions["node-webkit"]:void 0)?!1:!0),c.setPath("bower_components/zeroclipboard/dist/ZeroClipboard.swf")}]).run(["$rootScope","$location","$firebase","$firebaseSimpleLogin","NodeWebkit",function(a,b){return a.notAllowed=["discover","login"],a.firebaseURL="http://shortwave-dev.firebaseio.com",a.rootRef=new Firebase(a.firebaseURL),a.auth=new FirebaseSimpleLogin(a.rootRef,function(a){return a?console.error(a):void 0}),a.$on("$routeChangeError",function(){return console.log("failed to change route!!!")}),a.$on("$firebaseSimpleLogin:login",function(){return"/"===b.$$path?b.path("/dashboard"):void 0}),a.$on("$firebaseSimpleLogin:logout",function(){return console.log("logout event from app.coffee")}),a.$on("$firebaseSimpleLogin:error",function(a,b){return console.error("error logging in with firebase"),console.error(b)})}]).constant("amTimeAgoConfig",{withoutSuffix:!0})}).call(this),function(){"use strict";angular.module("shortwaveApp").controller("MainCtrl",["$scope","$rootScope","$location","$firebase","$firebaseSimpleLogin","$interval",function(a,b,c,d,e,f){var g,h;return a.$auth=e(b.rootRef),h=b.rootRef.child("static/useWithSuggestions"),g=d(h),a.useWith=g.$asArray(),a.idx=0,a.useWith.$loaded().then(function(){return console.log("loaded useWith"),console.log(a.useWith),a.flipper=f(function(){return a.idx===a.useWith.length-1?a.idx=0:a.idx++},5e3)}),a.login=function(){return a.$auth.$login("facebook")},a.$on("$destroy",function(){return a.flipper?(console.log("destroyed flipper"),f.cancel(a.flipper)):void 0})}])}.call(this),function(){"use strict";angular.module("shortwaveApp").controller("AboutCtrl",["$scope",function(a){return a.awesomeThings=["HTML5 Boilerplate","AngularJS","Karma"]}])}.call(this),function(){"use strict";angular.module("shortwaveApp").service("ChannelUtils",["$firebase","$q","$rootScope","$timeout","User",function(a,b,c,d,e){var f;return new(f=function(){function a(){c.$on("userLoaded",function(a){return function(b,c){return c.channels?void 0:a.autoJoin()}}(this)),c.$on("bumpTime",function(a){return function(b,c){return a.bumpTime(c)}}(this))}return a.prototype.getChannel=function(a){var d,e;return e=b.defer(),d=new Firebase(""+c.firebaseURL+"/channels/"+a),d.once("value",function(b){var c;return c=b.val(),c?e.resolve({data:c,name:a,snap:b}):e.reject("no channel exists")},function(a){return e.reject(a)}),e.promise},a.prototype.addChannel=function(a){var d,e;return e=b.defer(),d=c.rootRef.child("channels/"+a+"/meta"),d.once("value",function(b){return function(c){var d;return d=c.val(),d?(console.info("channel "+a+" exists, joining"),b.joinChannel(a).then(function(){return e.resolve()})["catch"](function(a){return e.reject(a)})):(console.info("channel "+a+" does not exist, creating"),b.createChannel(a).then(function(){return e.resolve()})["catch"](function(a){return e.reject(a)}))}}(this)),e.promise},a.prototype.createChannel=function(a){var d,f,g;return a=String(a),d=b.defer(),f={members:{},moderators:{},meta:{"public":!0}},f.members[""+e.user.$id]=!0,f.moderators[""+e.user.$id]=!0,g=c.rootRef.child("channels/"+a),g.set(f,function(b){var f;return b?d.reject(b):(console.log("setting channel on self"),f=c.rootRef.child("users/"+e.user.$id+"/channels/"+a),f.setWithPriority({lastSeen:0,muted:!1},Firebase.ServerValue.TIMESTAMP,function(a){return a?d.reject(a):d.resolve()}))}),d.promise},a.prototype.joinChannel=function(a){var f,g,h;return g=b.defer(),(null!=(h=e.user.channels)?h[a]:void 0)?(console.warn("faking join for a channel you are already in"),d(g.resolve,0)):(f=c.rootRef.child("channels/"+a+"/members/"+e.user.$id),f.set(!0,function(b){var d;return b?g.reject(b):(console.log("joined ok!"),d=c.rootRef.child("users/"+e.user.$id+"/channels/"+a),d.setWithPriority({lastSeen:0,muted:!1},Firebase.ServerValue.TIMESTAMP,function(b){return b?g.reject(b):g.resolve(a)}))})),g.promise},a.prototype.checkChannel=function(a){var d,e;return console.log("checking channel "+a),d=b.defer(),e=c.rootRef.child("channels/"+a+"/meta"),e.once("value",function(b){var c;return console.log("Channel public value is "+(null!=(c=b.val())?c["public"]:void 0)),d.resolve(b.val()?{channelName:a,exists:!0,meta:b.val()}:{channelName:a,exists:!1,meta:null})},function(b){return d.reject({error:b,channelName:a})}),d.promise},a.prototype.setMute=function(a,d){var f,g;return g=b.defer(),f=c.rootRef.child("users/"+e.user.$id+"/channels/"+a+"/muted"),f.set(d,function(a){return a?g.reject(a):g.resolve()}),g.promise},a.prototype.leaveChannel=function(a){var d,f;return d=b.defer(),f=c.rootRef.child("/channels/"+a+"/members/"+e.user.$id),f.set(null,function(b){var f;return b?d.reject():(f=c.rootRef.child("users/"+e.user.$id+"/channels/"+a),f.set(null,function(a){return a?d.reject():d.resolve()}))}),d.promise},a.prototype.setViewing=function(a){var d,f;return d=b.defer(),f=c.rootRef.child("users/"+e.user.$id+"/viewing"),f.set(a,function(a){return a?d.reject(a):d.resolve()}),d.promise},a.prototype.bumpTime=function(a){var b;return b=c.rootRef.child("users/"+e.user.$id+"/channels/"+a+"/lastSeen"),b.set(Firebase.ServerValue.TIMESTAMP,function(a){return a?console.error(a):void 0})},a.prototype.autoJoin=function(){var a;return a=c.rootRef.child("static/defaultChannels"),a.once("value",function(a){return function(b){var c,d,e,f,g;for(d=b.val(),console.log(d),g=[],e=0,f=d.length;f>e;e++)c=d[e],g.push(a.joinChannel(c).then(function(a){return console.log("autoJoiner successfully joined channel "+a)},function(a){return console.error(a)}));return g}}(this))},a}())}])}.call(this),function(){"use strict";angular.module("shortwaveApp").controller("DashboardCtrl",["$scope","$rootScope","$timeout","$filter","$firebase","$firebaseSimpleLogin","$location","user","Channels","ChannelUtils","Message","FileUploader",function(a,b,c,d,e,f,g,h,i,j,k,l){var m;return b.$on("updateChannel",function(){return function(b,c){return j.setViewing(c),a.currentChannel=c,a.focusInput()}}(this)),a.showCreate=function(){return a.createVisible=!0},a.hideCreate=function(){return a.createVisible=!1},a.logout=function(){var a;return a=new FirebaseSimpleLogin(b.rootRef,function(){return alert("logged out")}),a.logout(),g.path("/")},a.focusInput=function(){return c(function(){return b.$broadcast("focusOn","compose")})},a.focusInput(),m="5ee37787905afcd",a.uploader=new l({url:"https://api.imgur.com/3/image",headers:{Authorization:"Client-ID "+m},autoUpload:!0,alias:"image"}),a.uploader.filters.push({name:"imageFilter",fn:function(a){var b;return b=a.type.slice(a.type.lastIndexOf("/")+1),"jpg"===b||"png"===b||"jpg"===b||"jpeg"===b||"bmp"===b||"gif"===b}}),a.uploader.onWhenAddingFileFailed=function(a,b,c){return console.error("error adding file",a,b,c)},a.uploader.onAfterAddingFile=function(){return a.uploader.uploadAll()},a.uploader.onProgressAll=function(a){return console.info("upload progress: "+a)},a.uploader.onSuccessItem=function(b,c){return console.info("successfully uploaded item - sending message"),k.text(c.data.link,a.currentChannel)},a.uploader.onErrorItem=function(a,b,c,d){return console.error("error uploading item",a,b,c,d)},a.uploader.onCompleteAll=function(){return console.info("all uploads done")},a.paste=function(b){var c,d,e,f,g,h,i;for(e=b.clipboardData||b.originalEvent.clipboardData.items,console.info("user pasted something",JSON.stringify(e)),i=[],f=0,g=e.length;g>f;f++)d=e[f],"image/png"===(h=d.type)||"image/jpeg"===h||"image/gif"===h?(console.info("uploading user-pasted image"),c=e[0].getAsFile(),i.push(a.uploader.addToQueue(c))):i.push(void 0);return i}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("channelListItem",["$rootScope","$firebase","$timeout","User","Channels","ChannelUtils",function(a,b,c,d,e,f){return{templateUrl:"views/partials/channellistitem.html",restrict:"E",scope:{channel:"=",currentChannel:"="},link:function(c){var d,g;return c.latency=1e3,d=a.rootRef.child("channels/"+c.channel.$id+"/meta/description"),g=b(d),c.description=g.$asObject(),c.changeChannel=function(){return a.$broadcast("updateChannel",c.channel.$id),a.$broadcast("bumpTime",c.channel.$id)},c.toggleMute=function(a){return c.channel.muted||(c.channel.muted=!1),c.channel.muted=!c.channel.muted,a.stopPropagation(),f.setMute(c.channel.$id,c.channel.muted).then(function(){return console.info("channel muted successfully")})["catch"](function(a){return console.error(a)})},c.leave=function(b){return f.leaveChannel(c.channel.$id).then(function(){var b,d;return console.info("left channel successfully"),d=function(){var a,d,f,g;for(f=e.channelList,g=[],a=0,d=f.length;d>a;a++)b=f[a],b.$id!==c.channel.$id&&g.push(b.$id);return g}(),console.info("joining "+d[0]),a.$broadcast("updateChannel",d[0])})["catch"](function(a){return console.error(a)}),b.stopPropagation()}}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("createChannel",["$filter","$rootScope","$timeout","$firebase","ChannelUtils",function(a,b,c,d,e){return{templateUrl:"views/partials/createChannel.html",restrict:"E",scope:{cancel:"&"},link:function(a){var d;return c(function(){return b.$broadcast("focusOn","newchannelname")}),a.checkChannel=function(){return a.name?a.channelChecker=e.checkChannel(a.name).then(function(b){return console.log("DOES CHANNEL "+b.channelName+" EXIST? "+b.exists),b.channelName===a.name?(a.exists=b.exists,a.meta=b.meta):void 0},function(b){return console.error("error checking existance of channel "+a.name),console.error(b)}):a.existing=null},a.addChannel=function(){return a.exists?(console.log("joining channel"),e.joinChannel(a.name).then(function(){return console.log("joined ok!"),b.$broadcast("updateChannel",a.name),d()})["catch"](function(b){return console.error("channel "+a.name+" could not be joined!"),console.error(b)})):(console.log("creating channel"),e.createChannel(a.name,a.description).then(function(){return console.log("created ok!"),b.$broadcast("updateChannel",a.name),d()})["catch"](function(b){return console.error("channel "+a.name+" could not be created!"),console.error(b)}))},d=function(){return a.name="",a.description="",a.meta=null,a.cancel()},a.keydown=function(b){return 13===b.keyCode?a.addChannel():void 0}}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").service("User",["$rootScope","$firebase","$firebaseSimpleLogin","$q",function(a,b,c,d){var e;return new(e=function(){function e(){this.rootRef=a.rootRef,this.firebaseAuth=c(this.rootRef),this.init()}return e.prototype.init=function(){return this.deferredUser=d.defer(),this.deferredAuth=d.defer()},e.prototype.get=function(){return this.load(),this.deferredUser.promise},e.prototype.auth=function(){return this.load(),this.deferredAuth.promise},e.prototype.load=function(){return this.firebaseAuth.$getCurrentUser().then(function(a){return function(b){return a.authUser=b,a.authUser?(a.deferredAuth.resolve(a.authUser),a.fetch()):(a.loggedIn=!1,a.deferredUser.resolve(null),a.deferredAuth.reject())}}(this))["catch"](function(a){return console.error("err getting current user"),console.error(a)})},e.prototype.fetch=function(){var c,d;return d=a.rootRef.child("users/"+this.authUser.uid),c=b(d),this.user=c.$asObject(),this.user.$loaded().then(function(b){return function(c){return b.loggedIn=!0,b.deferredUser.resolve(c),a.$broadcast("userLoaded",c)}}(this))},e.prototype.login=function(){return this.init(),this.firebaseAuth.$login("facebook").then(function(a){return function(){return a.get()}}(this),function(a){return console.error("error logging in",a),this.deferredUser.reject()}),this.deferredUser.promise},e}())}])}.call(this),function(){"use strict";angular.module("shortwaveApp").service("Channels",["$rootScope","$firebase","$timeout","$interval","$filter","Focus","User",function(a,b,c,d,e,f,g){var h;return new(h=function(){function c(){g.get().then(function(c){return function(d){var e,f,g;return c.user=d,e=a.rootRef.child("users/"+c.user.$id+"/channels"),f=b(e),c.channels=f.$asArray(),c.loaded=c.channels.$loaded(),c.channels.$watch(c.channelListChanged,c),g=a.rootRef.child("users/"+c.user.$id+"/viewing"),g.on("value",function(b){return b.val()?a.$broadcast("updateChannel",b.val()):void 0})}}(this))}return c.prototype.channelListChanged=function(c){var d,e;return"child_added"===c.event?(d=a.rootRef.child("channels/"+c.key+"/meta/latestMessagePriority"),d.on("value",function(b){return function(d){var e,f;return f=d.val(),e=a.rootRef.child("users/"+b.user.$id+"/channels/"+c.key),e.setPriority(f)}}(this)),d=a.rootRef.child("messages/"+c.key).limit(1),e=b(d).$asArray(),e.$loaded().then(function(a){return function(){return e.$watch(function(b){return"child_added"===b.event?a.notify(c.key,e[0]):void 0})}}(this))):"child_removed"===c.event?(console.info("deleting channel: "+name),d=a.rootRef.child("channels/"+c.key+"/meta/latestMessagePriority"),d.off()):void 0},c.prototype.notify=function(a,b){var c,d,e;if(b.mentions){if(d=function(){var a,d,e,f;for(e=b.mentions,f=[],a=0,d=e.length;d>a;a++)c=e[a],c.uuid===this.user.$id&&f.push(c);return f}.call(this),console.log("computed mentions"),console.log(d),d.length>0)return this.showNotification(a,b)}else if(!(null!=(e=this.user.channels[a])?e.muted:void 0)&&this.user.$id!==b.owner&&!(b.parsedFrom||a===this.user.viewing&&f.focus))return this.showNotification(a,b)},c.prototype.showNotification=function(b,c){var d;return d=a.rootRef.child("users/"+c.owner+"/profile/firstName"),d.once("value",function(a){var d,e;return d=a.val(),console.log("sending notification"),Notification.requestPermission(),e=new Notification(""+d+" (#"+b+")",{icon:"images/icon.png",body:c.content.text,tag:c.$id})})},c}())}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("composebar",["$firebaseSimpleLogin","$rootScope","$window","$timeout","$firebase","Message",function(a,b,c,d,e,f){return{templateUrl:"views/partials/composebar.html",restrict:"E",scope:{channelName:"=",uploader:"=",composeHeight:"="},link:function(a,g){var h;return a.$watch(function(){return g.height()},function(c){return a.composeHeight=""+c+"px",b.$broadcast("heightUpdate")}),a.send=function(){var c,e,g,h,i;if(a.messageText){e=[],i=a.mentions;for(h in i)c=i[h],e.push({uuid:h,substring:"@"+c});return g=a.messageText.replace("\n","</br>"),f.text(g,a.channelName,e).then(function(){return b.$broadcast("bumpTime",a.channelName)})["catch"](function(b){return console.error("error sending message"),console.error(b),a.messageText=a.lastText}),a.lastText=a.messageText,d(function(){return a.messageText=null})}},a.keydown=function(b){var c,d;return 13===b.keyCode&&(a.query?(a.$broadcast("autocomplete:select"),b.preventDefault()):b.shiftKey||a.send()),38!==(d=b.keyCode)&&40!==d||!a.query||(c=38===b.keyCode?"up":"down",a.$broadcast("autocomplete:move",c),b.preventDefault()),27===b.keyCode?a.query=null:void 0},h=angular.element(c),h.on("focus",function(){return b.$broadcast("focusOn","compose")}),a.$watch("messageText",function(b){var c,d,e,f,g,h,i,j,k,l;if(a.query=null,a.mentions={},b){for(c=b.lastIndexOf("@"),-1!==c&&(d=b.lastIndexOf(" "),d>c||(a.query={atPosition:c,text:b.substring(c,b.length)})),h=b.match(/\B\@([\w\-]+)/gim),k=h||[],l=[],i=0,j=k.length;j>i;i++)g=k[i],g=g.replace("@",""),l.push(function(){var b,c,d,h;for(d=a.members,h=[],b=0,c=d.length;c>b;b++)e=d[b],f=""+e.profile.firstName+e.profile.lastName,h.push(g.toLowerCase()===f.toLowerCase()?a.mentions[e.$id]=g:void 0);return h}());return l}}),a.$watch("channelName",function(c){var d,f;return c?(a.members&&a.members.$destroy(),d=b.rootRef.child("channels/"+a.channelName+"/members"),f=e(d),a.members=f.$asArray(),a.members.$watch(function(c){var d,g;return"child_added"===c.event?(g=b.rootRef.child("users/"+c.key+"/profile"),f=e(g),d=a.members.$getRecord(c.key),d.profile=f.$asObject()):void 0})):void 0}),a.completeMention=function(b){return a.messageText=a.messageText.substring(0,a.query.atPosition+1),a.messageText+=""+b+" "}}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("message",["$rootScope","$firebase","$sce","$window","$http","NodeWebkit",function(a,b,c,d,e,f){return{templateUrl:"views/partials/message.html",restrict:"E",scope:{message:"=",rolling:"=",last:"=",preurl:"="},link:function(e){var g,h;return g=a.rootRef.child("users/"+e.message.owner+"/profile"),h=b(g),e.owner=h.$asObject(),e.$watch("message.content.gfycat",function(a){return a?e.vidurls={mp4:c.trustAsResourceUrl(a.mp4),webm:c.trustAsResourceUrl(a.webm)}:void 0}),e.navigate=function(a){return f.isDesktop?f.open(a):d.open(a),console.log("got navigate request for "+a)}}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").service("Message",["$q","$rootScope","User",function(a,b,c){var d;return d={text:function(a,b,c){var d;return null==c&&(c=[]),d={type:"text",content:{text:a},mentions:c},this.send(d,b)},image:function(a,b){var c;return c={type:"image",content:{src:a}},this.send(c,b)},send:function(d,e){var f,g,h,i;return i=a.defer(),d.owner=c.user.$id,g=Firebase.ServerValue.TIMESTAMP,f=b.rootRef.child("channels/"+e+"/meta/latestMessagePriority"),f.set(g,function(a){return a?console.error(a):void 0}),h=b.rootRef.child("messages/"+e).push(),h.setWithPriority(d,g,function(a){var c,d;return a?i.reject(a):(i.resolve(),d={channel:e,message:h.ref().name()},c=b.rootRef.child("parseQueue").push(),c.set(d,function(a){return a?console.error(a):void 0}),h=b.rootRef.child("pushQueue").push(),h.set(d,function(a){return a?console.error(a):void 0}))}),i.promise}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").controller("StreamCtrl",["$scope","$rootScope","$firebase","channel",function(a,b,c,d){var e,f;return e=new Firebase(""+b.firebaseURL+"/messages/"+d.name),f=c(e),a.messages=f.$asArray(),a.messages.$loaded().then(function(){return console.log("messages all loaded!"),console.log(a.messages)})}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("stream",["$rootScope","$firebase","$timeout","Channels",function(a,b,c){return{templateUrl:"views/partials/stream.html",restrict:"E",scope:{channelName:"="},link:function(d,e){var f,g;return d.loaded=!1,d.$watch("channelName",function(){return d.loaded=!1,d.channelName?(console.info("channel changed to "+d.channelName),g()):void 0}),g=function(){var e,g;return e=a.rootRef.child("messages/"+d.channelName),g=b(e.limit(100)),d.messages=g.$asArray(),d.messages.$loaded().then(function(){return c(function(){return f(),d.loaded=!0},500),d.messages.$watch(function(b){return"child_added"===b.event?a.$broadcast("bumpTime",d.channelName):void 0})})},d.$watch("messages",function(){return f()},!0),f=function(){return function(){var a;return a=e.children()[1],$(".messages").stop().animate({scrollTop:a.scrollHeight},{queue:!1,duration:300})}}(this),d.$on("heightUpdate",f)}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("actionbar",["$timeout","$rootScope","$firebase","ChannelUtils","Channels","User",function(a,b,c,d,e,f){return{templateUrl:"views/partials/actionbar.html",restrict:"E",scope:{channelName:"="},link:function(a){return a.$watch("channelName",function(d){var e;return d?(a.channel&&a.channel.$destroy(),e=new c(b.rootRef.child("users/"+f.user.$id+"/channels/"+d)),a.channel=e.$asObject()):void 0}),a.toggleMute=function(){return a.channel.muted=!a.channel.muted,a.channel.$save()},a.leave=function(){var c;return c=window.confirm("Are you sure you want to leave this hashtag?"),c?d.leaveChannel(a.channel.$id).then(function(){var c,d;return console.log("left channel successfully"),d=function(){var b,d,f,g;for(f=e.channelList,g=[],b=0,d=f.length;d>b;b++)c=f[b],c.$id!==a.channel.$id&&g.push(c.$id);return g}(),console.log("leaving "+a.channel.$id),console.log("joining "+d[0]),b.$broadcast("updateChannel",d[0])})["catch"](function(a){return console.error(a)}):void 0}}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("channelList",["$firebase","$rootScope","$timeout","$firebaseSimpleLogin","$window","$location","User","Channels","ChannelUtils","NodeWebkit",function(a,b,c,d,e,f,g,h,i,j){return{templateUrl:"views/partials/channellist.html",restrict:"E",scope:{currentChannel:"="},link:function(d){var f,k,l,m;return k=b.rootRef.child("searchQueue"),d.resultRef=null,d.createVisible=!1,b.$on("updateChannel",function(){return function(){return d.createVisible=!1}}(this)),d.uid=g.user.$id,m=b.rootRef.child("users/"+d.uid),f=m.child("channels"),l=a(f),d.channels=h.channels,d.channels.$loaded().then(function(){var a,b;return b=g.user,a=b.viewing?b.viewing:d.channels.length>0?d.channels[0].$id:null,a?d.currentChannel=a:void 0}),d.search=function(){var a;return d.resultRef&&(d.resultRef.off(),d.suggestions=[]),a=k.child("query").push(),a.set({query:d.addName}),d.resultRef=k.child("result/"+a.name()),d.resultRef.on("value",function(a){var b;return b=a.val(),(null!=b?b.results:void 0)?(d.suggestions=b.results,d.resultRef.off()):d.suggestions=[],d.$apply(function(){})})},d.reset=function(){return d.addName="",d.addMode=!1,d.resultRef&&d.resultRef.off(),d.suggestions=[]},d.addChannel=function(a){return i.addChannel(a).then(function(){return b.$broadcast("updateChannel",a),d.reset()})["catch"](function(a){return console.error("channel "+d.name+" could not be added!"),console.error(a)})},d.toggleMode=function(){return d.addMode=!0,c(function(){return b.$broadcast("focusOn","add")})},d.cancel=function(){return d.actionState=null},d.logout=function(){return b.auth.logout(),j.clearCache(),c(function(){return e.location.reload()},2e3)}}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("loadchirp",function(){return{restrict:"A",link:function(a,b){return b.bind("load loadeddata",function(){return a.$emit("heightUpdate")})}}})}.call(this),function(){"use strict";angular.module("shortwaveApp").filter("parseUrl",function(){return function(a){var b,c,d;return b=/(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim,c=/(^|[^\/])(www\.[\S]+(\b|$))/gim,d=/(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/gim,a&&(angular.forEach(a.match(b),function(){return a=a.replace(b,"<a ng-click='navigate(\"$1\")'>$1</a>")}),angular.forEach(a.match(c),function(){return a=a.replace(c,"$1<a ng-click='navigate(\"$2\")'>$2</a>")}),angular.forEach(a.match(d),function(){return a=a.replace(d,"<a ng-click='navigate(\"mailto:$1\")'>$1</a>")})),a}})}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("create",function(){return{templateUrl:"views/partials/create.html",restrict:"E",scope:{cancel:"&"},link:function(){}}})}.call(this),function(){"use strict";angular.module("shortwaveApp").service("NodeWebkit",function(){var a;return new(a=function(){function a(){var a,b;("undefined"!=typeof process&&null!==process?process.versions["node-webkit"]:void 0)&&(this.isDesktop=!0,this.gui=require("nw.gui"),b=this.gui.Window.get(),a=new this.gui.Menu({type:"menubar"}),a.createMacBuiltin("ShortwaveApp"),b.menu=a)}return a.prototype.open=function(a){return this.isDesktop?this.gui.Shell.openExternal(a):void 0},a.prototype.clearCache=function(){return this.isDesktop?this.gui.App.clearCache():void 0},a}())})}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("compile",["$compile",function(a){return{restrict:"A",link:function(b,c,d){return b.$watch(function(a){return a.$eval(d.compile)},function(d){return c.html(d),a(c.contents())(b)})}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("focusOn",function(){return{restrict:"A",link:function(a,b,c){return a.$on("focusOn",function(a,d){return d===c.focusOn?b[0].focus():void 0})}}})}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("safeChannelName",function(){return{require:"ngModel",link:function(a,b,c,d){return d.$parsers.push(function(a){var b;return b=a.toLowerCase(),b=b.replace(/\ /g,"-"),b=b.replace(/[\x00-\x1F\x7F]/g,""),b=b.replace(/[\/,$,\[,\]]/g,""),b!==a&&(d.$setViewValue(b),d.$render()),b})}}})}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("maxLength",function(){return{require:"ngModel",scope:{maxLength:"="},link:function(a,b,c,d){var e;return Number(e=a.maxLength),d.$parsers.push(function(a){var b;return b=a,b.length>e&&(b=b.substring(0,e)),b!==a&&(d.$setViewValue(b),d.$render()),b})}}})}.call(this),function(){"use strict";angular.module("shortwaveApp").controller("InviteCtrl",["$scope","$rootScope","$routeParams","$location","$firebase","ChannelUtils","User",function(a,b,c,d,e,f,g){var h,i;return a.channelName=c.channel,a.ref=c.ref,a.user=g.user,a.loaded=!1,h=b.rootRef.child("users/facebook:"+a.ref+"/profile"),i=e(h),a.profile=i.$asObject(),a.profile.$loaded().then(function(){return console.log("loaded profile!"),a.loaded=!0}),a.join=function(){return f.joinChannel(a.channelName).then(function(){return console.log("joined channel successfully!"),f.setViewing(a.channelName),d.path("/dashboard")},function(a){return console.error("error joining channel"),console.error(a)})},a.loginAndJoin=function(){return g.login().then(function(){return console.info("logged in!"),f.joinChannel(a.channelName).then(function(a){return console.info("successfully joined channel "+a),d.path("/dashboard")})["catch"](function(a){return console.error("error joining channel",a)})})}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("inviteLink",["$timeout","User","Url",function(a,b){return{templateUrl:"views/partials/inviteLink.html",restrict:"E",scope:{channel:"=",cancel:"&"},link:function(c){return c.link="hello there",c.uid=b.user.$id,c.$watch("channel",function(){var a;return a=c.uid.replace("facebook:",""),c.link="http://sw.mtnlab.io/"+c.channel+"?ref="+a}),c.didCopy=function(){return c.copied=!0,a(function(){return console.log("will cancel!"),c.cancel()},1e3)}}}}])}.call(this),function(){"use strict";angular.module("shortwaveApp").constant("Url","http://sw.mtnlab.io")}.call(this),function(){"use strict";angular.module("shortwaveApp").service("Focus",["$window",function(a){var b;return new(b=function(){function b(){var b,c,d;this.focus=document.hasFocus(),d=angular.element(a),d.on("focus",function(a){return function(){return a.focus=!0}}(this)),d.on("blur",function(a){return function(){return a.focus=!1}}(this)),("undefined"!=typeof process&&null!==process?process.versions["node-webkit"]:void 0)&&(b=require("nw.gui"),c=b.Window.get(),c.on("blur",function(a){return function(){return a.focus=!1}}(this)),c.on("focus",function(a){return function(){return a.focus=!0}}(this)))}return b}())}])}.call(this),function(){"use strict";angular.module("shortwaveApp").directive("autocomplete",["$rootScope",function(a){return{templateUrl:"views/partials/autocomplete.html",restrict:"E",scope:{channelName:"=",query:"=",members:"=",completeMention:"&"},link:function(b){return b.$watch("query",function(a){var c,d,e,f,g,h,i,j;if(b.results=[],b.idx=0,null!=a?a.text:void 0){for(e=a.text.replace("@",""),e=e.toLowerCase(),i=b.members,j=[],g=0,h=i.length;h>g;g++)d=i[g],d.profile.firstName&&d.profile.lastName&&d.profile.photo&&(f=(""+d.profile.firstName+d.profile.lastName).toLowerCase(),c=f.indexOf(e),-1!==c?(d.matchPosition=c,j.push(b.results.push(d))):j.push(void 0));return j}}),b.resultClicked=function(c){return b.completeMention({mentionString:""+c.profile.firstName+c.profile.lastName}),a.$broadcast("focusOn","compose")},b.hover=function(a){return b.idx=a},b.$on("autocomplete:move",function(a,c){return"up"===c?b.idx--:b.idx++,b.idx<0&&(b.idx=0),b.idx>b.results.length-1?b.idx=b.results.length-1:void 0}),b.$on("autocomplete:select",function(){var a;return b.results.length>0?(a=b.results[b.idx],b.resultClicked(a)):void 0})}}}])}.call(this);