/**
 * 
 * Author : xuhao
 */

function showEditSelect(spanId,selectId){
	var spanToHide = document.getElementById(spanId);
	var select = document.getElementById(selectId);
	spanToHide.style.display = "none";
	select.style.display = "block";
	select.focus();
}

function hideEditSelect(spanId,selectId,saveButtonId){
	var span = document.getElementById(spanId);
	var select = document.getElementById(selectId);
	var selectedValue = $('#' + selectId).children(':selected').map(function () {
        return $(this).text();
    }).get().join(',');
	var oldValue = span.innerHTML;
	//if the new value != old value, change the value and enable save button
	if(oldValue.localeCompare(selectedValue) != 0){
		span.innerHTML = selectedValue;
		if(saveButtonId){
			var saveButton = document.getElementById(saveButtonId);
			saveButton.disabled = false;
		}
	}
	span.style.display = "block";
	select.style.display = "none";
}

function showEditInput(spanId,inputId){
	var spanToHide = document.getElementById(spanId);
	var inputToShow = document.getElementById(inputId);
	spanToHide.style.display = "none";
	inputToShow.style.display = "block";
	inputToShow.select();
}

function hideEditInput(spanId,inputId,password,saveButtonId){
	var span = document.getElementById(spanId);
	var input = document.getElementById(inputId);
	var inputValue = input.value;
	var oldValue = span.innerHTML;
	//if the new value != old value, change the value and enable save button
	if(!password && oldValue.localeCompare(inputValue) != 0){
		span.innerHTML = inputValue;
		if(saveButtonId){
			var saveButton = document.getElementById(saveButtonId);
			saveButton.disabled = false;
		}
	}
	span.style.display = "block";
	input.style.display = "none";
}


function submitSave(saveUrl,formId,saveButtonIdPrototype,index){
	hideModalMessages();
	var outJson = convertRowIntoJson(formId,index);
	sendWithAjax(saveUrl,outJson,saveButtonIdPrototype+index);
}			
function sendWithAjax(url,outJson,saveButtonId){
	$.ajax({
	    'url': url,
	    'type': 'post',
	    'contentType': 'application/json;charset=utf-8',
	    'data': JSON.stringify(outJson),
	    'success': function(result){
	    	var statusBar = document.getElementById("status");
			statusBar.innerHTML = "<font color='green'> saved </font>";
			var saveButton = document.getElementById(saveButtonId);
			saveButton.disabled = true;
	    },
	    'error': function(e){
	    	var statusBar = document.getElementById("status");
			if(e.status == 200){
				statusBar.innerHTML = "<font color='red'> error: you have been disconnected from serveur, please reconnect </font>";
			}else{
				if(e.responseText){
					statusBar.innerHTML = "<font color='red'> error: " + e.statusText +" <br>" + e.responseText + "</font>";
				}else{
					statusBar.innerHTML = "<font color='red'> error: " + e.statusText +"</font>";
				}
			}
	    }
	});
}
/**
 * requires a name tag like: text1.anotherText to read anotherText = "x" as a attribute in this row
 * @param formId
 * @param index
 * @returns
 */
function convertRowIntoJson(formId,index){
	var formArray = $('#'+formId).serializeArray();
	var key = "[" + index + "]";
	var outJson = {};
	 for (var i = 0; i < formArray.length; i++){
		 if(!formArray[i].name.startsWith("_") && formArray[i].name.includes(key)){
			 var name = formArray[i].name.split(".")[1];
			 //using Jquery instead of .val in native JavaScript to not deal with different cases such as multiSelect
			 outJson[name] =  $("[name='" + formArray[i].name + "']").val();
		 } 
	 }
	 return outJson;
}


function addSelectedIndex(formId,index){
	$('<input />').attr('type', 'hidden')
	.attr('name', 'selectedIndex')
	.attr('value', index)
	.appendTo('#'+formId);
}	 

// using form
function submitDelete(formId,index){
	addSelectedIndex(formId,index);
	document.getElementsByName("delete")[0].click();
	indexToDelete =-1;
	
}

//using form
function deleteRow(index){
	indexToDelete = index;
	$("#deleteWarning").modal("show");
	
}

function hideModalMessages(){
	var errorMessage = document.getElementById("errorMessage");
	if(errorMessage){
		errorMessage.style.display = "none";
	}
	var sucessMessage = document.getElementById("sucessMessage");
	if(sucessMessage){
		sucessMessage.style.display = "none";
	}
}

