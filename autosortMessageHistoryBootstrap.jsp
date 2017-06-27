<style>
#status{
	text-align: center;
}
table{
	max-width: none !important;
}
/* Message level Css classes, do no change names unless it is changed in java */
.low{
background-color: silver;

}
.normal{

}
.warning{
color: red;
}
.alert{
background-color: yellow;
color: red;
padding: 0px;
margin-bottom: 0px;
border: 0px;
}
</style>

<title>
Autosort Message History
</title>
<div class="content-wrapper">
	<section class="content-header">
		<h1>
			Autosort Message History
		</h1>
	</section>
	<html:form action="/autosortMessageHistoryBootstrap.do">
		<section class="content">
			<div class="box box-primary">
				<div class="box-header with-border">
					<h1 class="box-title"></h1>

					<div class="box-tools pull-right">
					</div>
				</div>
				<div class="box-body">
					<!-- filter row  -->
					<div class="row" id="filterRow">
						<div class="col-sm-4">
						<bean:define id="filter" name="autosortMessageHistoryForm" property="filter"></bean:define>
							<html:select name="filter" styleClass="form-control" errorStyleClass="validError form-control" property="selectedTypes" size="5" multiple="true">
								<html:optionsCollection name="autosortMessageHistoryForm" property="msgTypeList" label="key" value="value"/>
							</html:select>
						</div>
						<div class="col-sm-2">
							<div class="row">
								From : <input id="from_datetimepicker" name="fromDate" class="form-control" type="text" value='<bean:write name="filter" property="fromDateString"/>'/>
							</div>
							<div class="row">
								To : <input id="to_datetimepicker" name="toDate" class="form-control" type="text" value='<bean:write name="filter" property="toDateString"/>'/>
							</div>
						</div>
						
						<div class="col-sm-4">
							<div class="checkbox">
							  <label><html:checkbox name="filter"  property="wantMsgAck" />Display MSG-ACK</label>
							</div>
							<div class="checkbox">
							  <label><html:checkbox name="filter"  property="errMessageOnly" />Error Message Only</label>
							</div>
							<div class="input-group">
								<span class="input-group-addon">Message : </span>
								<input name="messageToSearch" type="text" class="form-control" placeholder="Search by message here" onkeypress='javascript: if(event.which == 13 || event.keyCode == 13) {doFilter();}'> 
								<div class="input-group-btn">
								     <button type="button" class="btn btn-primary" onclick='javascript:doFilter();' >
								        <i class="glyphicon glyphicon-search"></i>
								      </button>
						   		 </div>
							</div>
						</div>	
					</div>
					
					<p>
					<div class="row">
						<div class="col-sm-12">
							<div id="status"></div>
							<table class="table table-bordered table-striped dataTable"
								id="remoteSourceDataTable">
								<thead id="tableHead1">
									<tr>
<%-- 									<th><bean:message key="common.select" /></th> --%>
										<th>Number</th>
										<th>Date</th>
										<th>Type</th>
										<th>Message</th>
								</thead>
								<tbody id="tableBody1">
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</section>
	</html:form>
</div>
<script>
var changeFilterUrl = "${myContext}/autosortMessageHistoryBootstrap.do?method=changeFilter";
var getOlderUrl = "${myContext}/autosortMessageHistoryBootstrap.do?method=get&action=old";
var getNewtUrl = "${myContext}/autosortMessageHistoryBootstrap.do?method=get&action=new";
var dateFormat = 'YYYY-MM-DD HH:mm:ss';
var loadingData = false;
var changingFilter = false;
var scrollPositionBeforeDraw = 0;
//count actuall row number in data table
var rowCount = 0;
//contain data table, initialized in document.ready
var dataTableId = "remoteSourceDataTable";
var table; 
var tableBody = document.getElementById("tableBody1");
var tableScrollBody;

$( document ).ready(function() {
	jQuery('#from_datetimepicker').datetimepicker({
		timepicker: true,
		format: dateFormat
	});
	jQuery('#to_datetimepicker').datetimepicker({
		timepicker: true,
		format: dateFormat
	});
	//init data table -----------------------------------------------------------------------------------------------------------------------------------------------------
	table = $('#'+ dataTableId).DataTable({
		scrollY: '50vh',
        paging: false,
        orderFixed: [ 1, 'desc' ]
        
	}); 
	tableScrollBody = document.getElementsByClassName("dataTables_scrollBody")[0];
	// add mouse wheel listener -------------------------------------------------------------------------------------------------------------------------------------------
	if (tableBody.addEventListener)
	{
	    // IE9, Chrome, Safari, Opera
	    tableBody.addEventListener("mousewheel", MouseWheelHandler, false);
	    // Firefox
	    tableBody.addEventListener("DOMMouseScroll", MouseWheelHandler, false);
	}
	// IE 6/7/8
	else
	{
	    tableBody.attachEvent("onmousewheel", MouseWheelHandler);
	}
});

//FILTER + ajax PART------------------------------------------------------------------------------------------------------------------------------------------------------------
function doFilter(){
	if(!changingFilter){
		changingFilter = true;
		var filterJson = convertRowIntoJson("filterRow");
		filterJson["pageSize"] = 100;
		var url = changeFilterUrl + "&filterSet=" + JSON.stringify(filterJson);
		sendWithAjax(url, "", function(){sendWithAjax(getOlderUrl, "", onFilterSuccess);});
	}
}

function get(urlToGet, scrollPosition){
	if(!loadingData){
		loadingData = true;
		scrollPositionBeforeDraw = scrollPosition;
		sendWithAjax(urlToGet, "", onGetSuccess)
	}
}

function sendWithAjax(url,outJson, onSuccess){
	$.ajax({
	    'url': url,
	    'type': 'post',
	    'contentType': 'application/json;charset=utf-8',
	    'data': JSON.stringify(outJson),
	    'success': function(result){
			if(onSuccess){
				if(result){
					var data = JSON.parse(result);
					onSuccess(data);
				}else{
					onSuccess();
				}
			}
	    },
	    'error': function(e){
	    	var statusBar = document.getElementById("status");
			statusBar.innerHTML = "<font color='red'> error: " + e.statusText +"</font>";
	    }
	});
}
/**
 * @param Id
 * @returns
 */
function convertRowIntoJson(Id){
	var elementArray = $('#'+Id + " :input").not(":button");
	var outJson = {};
	 for (var i = 0; i < elementArray.length; i++){
		 if(!elementArray[i].name.startsWith("_")){
			 var name = elementArray[i].name;
			 //using Jquery instead of .val in native JavaScript to not deal with different cases such as multiSelect
			 if(elementArray[i].type == "checkbox"){
				 outJson[name] =  $("[name='" + elementArray[i].name + "']").is(":checked");
			 }else{
				 var value;
				 if(name.includes("Date")){
					 value = new Date($("[name='" + elementArray[i].name + "']").val()).getTime();
				 }else{
					 value = $("[name='" + elementArray[i].name + "']").val();
				 }
				 outJson[name] =  value;
			 }
			
		 } 
	 }
	 return outJson;
}

//DRAW DATA TABLE (or re-draw) -------------------------------------------------------------------------------------------------------------------------------------------------

function onGetSuccess(data){
	
	for(var i = 0; i < data.length; i++){
		addNewRow(data[i]);
	}
	drawTable();
	setTimeout(function(){loadingData = false;}, 1000)
	tableScrollBody.scrollTop = scrollPositionBeforeDraw;
}

function onFilterSuccess(data){
	
	clearTable();
	onGetSuccess(data);
	setTimeout(function(){changingFilter = false;}, 1000)
}

function clearTable(){
	table.clear(); 
	rowCount = 0;
}
function drawTable(){
	table.draw();
}
function addNewRow(rowData){
	var localHistory = rowData.history;
	var rowNode = table.row.add([
		"<span class=" + rowData.messageLevel + ">" + localHistory.messageNumber + "</span>",
		"<span class=" + rowData.messageLevel + ">" + rowData.creationDateString + "</span>",
		"<span class=" + rowData.messageLevel + ">" + localHistory.type + "</span>",
		"<span class=" + rowData.messageLevel + " id='span" + rowCount + "' >" + localHistory.content + "</span> <textarea id=input" + rowCount + " class='form-control' onblur='javascript:toSpan(this, span" + rowCount + ");' style='display:none;'>" + localHistory.content,
	]).node();
	
	var span = "span"+rowCount;
	var input = "input"+rowCount;
	$(rowNode).find('td').eq(3)[0].ondblclick = function(){
		toInput(span,input);
	}
	rowCount++;
}

function toInput(spanId, inputId){
	var span = document.getElementById(spanId);
	var input = document.getElementById(inputId);

	span.style.display = "none";
	input.style.display = "table-row";
	input.select();
}

function toSpan(input, span){
	span.style.display = "table-row";
	input.style.display = "none";
}
//ON WHEEL FUNCTION PART (triggers when to get new data for data table)---------------------------------------------------------------------------------------------------------

function MouseWheelHandler(e)
{
    // cross-browser wheel delta
    var e = window.event || e; // old IE support
    var delta = Math.max(-1, Math.min(1, (e.wheelDelta || -e.detail)));
    var scrollPosition = tableScrollBody.scrollTop;
    var scrollHeight = tableScrollBody.scrollHeight - tableScrollBody.offsetHeight;
//     console.log("delta: " + delta);
//     console.log("position: " + scrollPosition);
//     console.log("scrollHeight :" + scrollHeight);
    if(delta > 0 && scrollPosition == 0){
//     	console.log("Up");
    	get(getNewtUrl, scrollPosition);
    }else if(delta<0 && scrollPosition >= scrollHeight){
//     	console.log("Down");
    	get(getOlderUrl, scrollPosition);
    }
    return false;
}

</script>