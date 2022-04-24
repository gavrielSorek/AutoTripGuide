module.exports = { getToken };
// serverUrl = 'https://autotripguide.loca.lt'
var XMLHttpRequest = require('xhr2');

async function getToken(mail, password, serverUrl) {

    var userInfo = {
        userName  : mail,
        emailAddr : mail, 
        password  : password
    }
    var userInfoJson= JSON.stringify(userInfo);
    const Http = new XMLHttpRequest();
    Http.HTTPS=true

    const url= serverUrl + '/login';
    Http.open("POST",  url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(userInfoJson);
    const tokenPromise = new Promise((resolve, reject) => {
        Http.onreadystatechange = (e) => {  
            if (Http.readyState == 4 && Http.status == 200) { //if the operation is complete. 
                var response = Http.responseText
                if(response.length > 0) {
                    // console.log("response from the server is recieved")
                    // console.log(response)
                    var jsonResponse = JSON.parse(Http.responseText);
                    if (jsonResponse['loginStatus'] == 0) {
                        console.log("The username you entered doesn't belong to an account. Please check your username and try again.");
                    } else if (jsonResponse['loginStatus'] == 1) {
                        console.log("Sorry, your password was incorrect. Please double-check your password.");
                    } else {
                        console.log("The user exist :) :) :).");
                        resolve(jsonResponse)
                    }
                }
            } 
        }
      });

    var res = await tokenPromise;
    // console.log(res);
    return res;

}


// function packServerInfo(serverRes){
//     pack = {}
//     pack['permissionStatus'] = serverRes['permissionStatus'];
//     pack['PermissionToken'] = serverRes['PermissionToken'];
//     // pack['userName'] = serverRes['userName']
//     console.log(pack)
// }
// getToken('crawler@gmail.com', '1234')