
			
	<script type="text/javascript">
		
		var ws = null;
		var timmer;
		var currentRetryTimes;
		var retryLimit = 10;
		var reconnectWaitTime = 10000; // milliseconds
	
		$(document).ready(function(){
			openWebSocketConnectionAndListen();
			//bind enter to submit key since there is no form here
			 $('#input').keypress(function(e){
			      if(e.keyCode==13)
			      $('#sendMessage').click();
			    });
		})
		
		function openWebSocketConnectionAndListen()
		{
			 ws= new WebSocket('ws://'+window.location.host+'${pageContext.request.contextPath}/websocket');
			 
			 ws.onopen = function(e) {
				 var element = document.getElementById("reconnect");
				 element.innerHTML = " Connected";
				 currentRetryTimes = 0;
			 }
			 ws.onmessage = function(e) {
				 var data = JSON.parse(e.data);
				 var element = document.getElementById("chatRoom");
				 element.innerHTML = element.innerHTML + data.message;
				 var element = document.getElementById("userList");
				 element.innerHTML = "<span style='float:left;'> Online Users : </span><br>" + data.users;
				 updateScroll();
				}
			 ws.onerror = function(e) {
				 var element = document.getElementById("chatRoom");
				 element.innerHTML = element.innerHTML + "<br>" + "<span class=\"system\"> System : Connection Error </span>";
				 var element = document.getElementById("reconnect");
				 element.innerHTML = " Connection Error";
				 updateScroll();
				 }
			 ws.onclose = function(e) {
				 var element = document.getElementById("chatRoom");
				 element.innerHTML = element.innerHTML + "<br>" + "<span class=\"system\"> System : Connection Closed </span>";
				 var element = document.getElementById("reconnect");
				 element.innerHTML = " Connection Closed";
				 if(currentRetryTimes < retryLimit){
					 setTimeout(reconnect, reconnectWaitTime);
				 }else{
					 var reconnect = document.getElementById("reconnect");
					 reconnect.innerHTML = " Stopped trying";
						element.innerHTML = element.innerHTML + "<br>" + "<span class=\"system\"> System : Connection Lost for too Long time, please refresh the page </span>";
				 }
				 updateScroll();
				}
		}

		function reconnect(){
			if(!ws || ws.readyState === WebSocket.CLOSED){ 
				var element = document.getElementById("reconnect");
				element.innerHTML = " Trying hard to reconnect";
				currentRetryTimes++;
				openWebSocketConnectionAndListen();	
				}
		}
		
		
		function updateScroll(){
		    var element = document.getElementById("chatBox");
		    element.scrollTop = element.scrollHeight;
		}
         
		function sendMessage(){
			var input = document.getElementById("input");

			if(input.value == ""){ //emtpy message?
				alert("Enter Some message Please!");
				return;
			}
 
			ws.send(input.value);
        	
			input.value = "";
		}
		
		
	</script>
	<style>
	
		.system{
		text-align:left;
		color:grey;
		font-size:90%;
		}
		.userName{
		font-weight: bold;
		font-size:110%;
		}
		.userPrincipal{
		margin-left:50px;
		}
		.userOthers{
		text-align:right;
		margin-right:50px;
		}
		#chatBox{
		width:800px;
		height:400px;
		overflow:auto;
		float:left;
		}
		#userList{
		width:200px;
		height:400px;
		overflow:auto;
		text-align:right;
		}

	</style>
	<div class="content-wrapper">
	
		<c:if test="${not empty errorMessage}">
			<div id="errorMessage" class="alert alert-error">${errorMessage}</div>
		</c:if>
		<section class="content-header">
			<h1>Welcome to Sg4p Tool Web Live Chat</h1>
		</section>
		<section class="content">	
				<c:if test="${pageContext.request.userPrincipal.name != null}">
				
				<div class="content-wrapper">
				<div class="box-header">
					
					Live Chat: 
					<span id="reconnect" class="system">Connecting</span>
				</div>

				<div class="box" id="chatBox">
					<div class="box-body" id="chatRoom"></div>
					
				</div>
				
				<div>
					<div class="box" id="userList"></div>
				</div>
				


				<br><br>
				<div>
					<input type="text" name="input" id="input" placeholder="Message" maxlength="80" style="width:60%" />
					<input type="submit" id="sendMessage" class="btn btn-warning" onclick="sendMessage()" value="send" />
				</div>
				
				</div>
		
			
		    	</c:if>
		</section>
	</div>
