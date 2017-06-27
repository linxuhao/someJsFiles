
			
	<script type="text/javascript">
		var clientVersion = 0;
		
		$(document).ready(function(){
			getMessage(clientVersion);
			//bind enter to submit key since there is no form here
			 $('#input').keypress(function(e){
			      if(e.keyCode==13)
			      $('#sendMessage').click();
			    });
		})
		
		function updateScroll(){
		    var element = document.getElementById("chatBox");
		    element.scrollTop = element.scrollHeight;
		}
		
		function getMessage(){
            $.ajax({
                    'url': 'http://'+window.location.host+'${pageContext.request.contextPath}/liveChatLongPolling/get',
                    'type': 'post',
                   	'contentType': 'text/html;charset=utf-8',
                    'dataType': 'text',
                    'data':  ""+clientVersion,
                    'timeout': 60000,
                    'cache': false,
                    'success': function(result){
                    	var statusBar = document.getElementById("reconnect");
	    				statusBar.innerHTML = "Connected ";
                            if(result){
									var data = JSON.parse(result);
				    				var element1 = document.getElementById("chatRoom");
				    				element1.innerHTML = element1.innerHTML + data.message;
				    				clientVersion = data.version;
                                    updateScroll();
                            } 
                            getMessage();
                    },
                    'error': function(status){
	       				var statusBar = document.getElementById("reconnect");
	    				statusBar.innerHTML = "Disconnected from server, Connecting ";
	       				updateScroll();
	       				if (status=='timeout') {
	       	                getMessage();
	       	            }
	       	            else { 
	       	                setTimeout( getMessage, 60000 );
	       	            }
                    }
            });
		}
            
           function postMessage(){
            	var message = document.getElementById("input").value;
                $.ajax({
                        'url': 'http://'+window.location.host+'${pageContext.request.contextPath}/liveChatLongPolling/post',
                        'type': 'post',
                        'contentType': 'text/html;charset=utf-8',
                        'dataType': 'text',
                        'data': ""+message,
                        'success': function(result){
                        	var statusBar = document.getElementById("reconnect");
    	    				statusBar.innerHTML = "Connected ";
                        },
                        'error': function(e){
                        	var statusBar = document.getElementById("reconnect");
    	    				statusBar.innerHTML = "Disconnected from server, Connecting  ";
                        },
                        'complete': function(){
                        	document.getElementById("input").value ="";
                        }
                });
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

	</style>
	<div class="content-wrapper">
	
		<c:if test="${not empty errorMessage}">
			<div id="errorMessage" class="alert alert-error">${errorMessage}</div>
		</c:if>
		<section class="content-header">
			<h1>Welcome to Sg4p Tool Web Live Chat using Long Polling</h1>
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
				


				<br><br>
				<div>
					<input type="text" name="input" id="input" placeholder="Message" maxlength="80" style="width:60%" />
					<input type="submit" id="sendMessage" class="btn btn-warning" onclick="postMessage()" value="send" />
				</div>
				
				</div>
		
			
		    	</c:if>
		</section>
	</div>
