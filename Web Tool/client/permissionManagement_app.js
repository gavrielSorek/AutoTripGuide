
//variables definition
var userEmailAddr = document.getElementById("userEmailAddr");
var permission = document.getElementById("permission");

document.getElementById("submit_button").addEventListener("click",changePermission);

async function changePermission() {
    console.log("Inside changePermission function")
    var userEmailAddrVal = userEmailAddr.value
    var permissionVal =  permission.options[permission.selectedIndex].value
    console.log("userEmailAddrVal: " + userEmailAddrVal + "  permissionVal: " + permissionVal)

    var userInfo = {
        emailAddr : userEmailAddrVal, 
        newPermission : permissionVal
    }
    communication.addTokensToObject(userInfo)
    var userInfoJson= JSON.stringify(userInfo);
    const Http = new XMLHttpRequest();
    const url=communication.uriBeginning + 'changePermission';
    Http.open("POST", url, true);
    Http.onerror = function(e){
        messages.showServerNotAccissableMessage();
    };
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(userInfoJson);
    Http.onreadystatechange = (e) => {  
        if (Http.readyState == 4 && Http.status == 200) {
            console.log("response from the server is recieved")
            var response = Http.responseText;
            if(response.length > 0) {
                console.log("response from the server is recieved")
                console.log(jsonResponse)
                var jsonResponse = JSON.parse(Http.responseText);
                console.log(jsonResponse);
                if (jsonResponse == 0){
                    messages.showNotFoundUser()
                } else {
                    messages.changePermissionSuccess()
                }
            }
        }
    }
}
