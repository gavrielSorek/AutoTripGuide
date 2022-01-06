//variables definition
var loginForm = document.querySelector("#login");
var createAccountForm = document.querySelector("#createAccount");
var signupUsername = document.getElementById("signupUsername");
var signupEmailAddr = document.getElementById("signupEmailAddr");
var signupPassword = document.getElementById("signupPassword");
var signupConfirmPassword = document.getElementById("signupConfirmPassword");
var signinUserNameOrEmail = document.getElementById("signinUsername");
var signinPassword = document.getElementById("signinPassword");
var continueButton = document.getElementById("continueButton");
var loginButton = document.getElementById("loginButton");
continueButton.disabled = true;
loginButton.disabled = true

var defaultPermission = 4   //Viewer 

// The function enable to continue in the signUp process - means all the info is valid
function enableContinue() {
    continueButton.style.background = '#2a7099';
    continueButton.disabled = false
}

// The function disable to continue in the signUp process - means not all the info is valid
function disableContinue() {
    continueButton.style.background = '#4e88aa';
    continueButton.disabled = true;
}

// The function enable to login in the login process - means all the info is valid
function enableLogin() {
    loginButton.style.background = '#2a7099';
    loginButton.disabled = false
}

// The function disable to continue in the login process - means not all the info is valid
function disableLogin() {
    loginButton.style.background = '#4e88aa';
    loginButton.disabled = true;
}

//query selector
document.querySelectorAll(".form__input").forEach(inputElement => {
    inputElement.addEventListener("blur", e => {
        // Integrity check for signUp user name
        if (e.target.id === "signupUsername" && e.target.value.length > 0 && e.target.value.length < 10) {
            setInputError(inputElement, "Username must be at least 10 characters in length");
            disableContinue();
        } 
        // Integrity check for signUp password
        if (e.target.id === "signupConfirmPassword" && e.target.value != signupPassword.value) {
            setInputError(inputElement, "The passwords do not match");
            disableContinue();
        }
        if(signupUsername.value.length > 9 && signupPassword.value.length !=0 && signupPassword.value == signupConfirmPassword.value) {
            enableContinue();
        }
        if(signinUserNameOrEmail.value.length == 0 || signinPassword.value.length == 0) {
            disableLogin();
        }
        if(signinUserNameOrEmail.value.length > 0 && signinPassword.value.length > 0) {
            enableLogin();
        }
    });
    inputElement.addEventListener("input", e => {
        clearInputError(inputElement);
        disableContinue();
        disableLogin();
    });
});

function onGoogleSignIn(googleUser) {
    var auth2 = gapi.auth2.getAuthInstance();
    auth2.disconnect();
    var profile = googleUser.getBasicProfile();
    // console.log('ID: ' + profile.getId()); // Do not send to your backend! Use an ID token instead.
    // console.log('Name: ' + profile.getName());
    // console.log('Image URL: ' + profile.getImageUrl());
    // console.log('Email: ' + profile.getEmail()); // This is null if the 'email' scope is not present.
    var id_token = googleUser.getAuthResponse().id_token;

    const Http = new XMLHttpRequest();
    const url='http://localhost:5500/googlelogin';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(JSON.stringify({token : id_token}));

    Http.onreadystatechange = (e) => {  
        if (Http.readyState == 4) { //if the operation is complete.
            var response = Http.responseText
            if(response.length > 0) {
                if (response == "success") {
                    console.log("the user login with google auth");
                    window.location.href = "search.html";
                } else {
                    console.log("the user not login with google auth");
                }
            }
        }
    }
}



function login(){
    console.log("signinUserNameOrEmail: " + signinUserNameOrEmail.value + "signinPassword: " + signinPassword.value)
    signinUserNameOrEmailVal = signinUserNameOrEmail.value
    signinPasswordVal = signinPassword.value
    if(signinUserNameOrEmailVal.length == 0 || signinPasswordVal == 0) {
        setFormMessage(loginForm, "error", "Invalid username/password combination");
        return
    }
    var userInfo = {
        userName  : signinUserNameOrEmailVal,
        emailAddr : signinUserNameOrEmailVal, 
        password  : signinPasswordVal
    }
    var userInfoJson= JSON.stringify(userInfo);
    const Http = new XMLHttpRequest();
    const url='http://localhost:5500/login';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(userInfoJson);
    Http.onreadystatechange = (e) => {  
        if (Http.readyState == 4) { //if the operation is complete. 
            var response = Http.responseText
            if(response.length > 0) {
                console.log("response from the server is recieved")
                console.log(response)
                var jsonResponse = JSON.parse(Http.responseText);
                if (jsonResponse == 0) {
                    setFormMessage(loginForm, "error", "The username you entered doesn't belong to an account. Please check your username and try again.");
                    console.log("The username you entered doesn't belong to an account. Please check your username and try again.");
                } else if (jsonResponse == 1) {
                    setFormMessage(loginForm, "error", "Sorry, your password was incorrect. Please double-check your password.");
                    console.log("Sorry, your password was incorrect. Please double-check your password.");
                } else {
                    console.log("The user exist :) :) :).");
                    window.location.href = "search.html";
                }
            }
        }
    }
}


function createAccount() {
    console.log("inside createAccount function")
    signupUsernameVal = signupUsername.value
    signupEmailAddrVal = signupEmailAddr.value
    signupPasswordVal = signupPassword.value
    signupConfirmPasswordVal = signupConfirmPassword.value
    if(signupUsernameVal.length == 0 || signupEmailAddrVal == 0 || signupPasswordVal == 0 || signupConfirmPasswordVal == 0) {
        setFormMessage(createAccountForm, "error", "check again your details");
        return
    }
    var userInfo = {
        userName  : signupUsernameVal,
        emailAddr : signupEmailAddrVal,
        password  : signupPasswordVal,
        permission : defaultPermission
    }
    var userInfoJson= JSON.stringify(userInfo);
    const Http = new XMLHttpRequest();
    const url='http://localhost:5500/createNewUser';
    Http.open("POST", url);
    Http.withCredentials = false;
    Http.setRequestHeader("Content-Type", "application/json");
    Http.send(userInfoJson);
    Http.onreadystatechange = (e) => {  
        if (Http.readyState == 4) { //if the operation is complete. 
            var response = Http.responseText
            if(response.length > 0) {
                console.log("response from the server is recieved")
                var jsonResponse = JSON.parse(Http.responseText);
                if (jsonResponse == 0) {
                    console.log("The user created");
                } else if (jsonResponse == 1) {
                    console.log("The user name and the email address exist in the system");
                    setFormMessage(createAccountForm, "error", "The user name and the email address exist in the system");
                } else if (jsonResponse == 2) {
                    console.log("The user name exist in the system");
                    setFormMessage(createAccountForm, "error", "The user name exist in the system");
                } else {
                    console.log("The email address exist in the system");
                    setFormMessage(createAccountForm, "error", "The email address exist in the system");
                }
            }
        }
    }
}

function setFormMessage(formElement, type, message) {
    const messageElement = formElement.querySelector(".form__message");

    messageElement.textContent = message;
    messageElement.classList.remove("form__message--success", "form__message--error");
    messageElement.classList.add(`form__message--${type}`);
}

function setInputError(inputElement, message) {
    inputElement.classList.add("form__input--error");
    inputElement.parentElement.querySelector(".form__input-error-message").textContent = message;
}

function clearInputError(inputElement) {
    inputElement.classList.remove("form__input--error");
    inputElement.parentElement.querySelector(".form__input-error-message").textContent = "";
}

document.addEventListener("DOMContentLoaded", () => {
    // const loginForm = document.querySelector("#login");
    // const createAccountForm = document.querySelector("#createAccount");

    document.querySelector("#linkCreateAccount").addEventListener("click", e => {
        e.preventDefault();
        loginForm.classList.add("form--hidden");
        createAccountForm.classList.remove("form--hidden");
    });

    document.querySelector("#linkLogin").addEventListener("click", e => {
        e.preventDefault();
        loginForm.classList.remove("form--hidden");
        createAccountForm.classList.add("form--hidden");
    });

    // loginForm.addEventListener("submit", e => {
    //     e.preventDefault();

    //     // Perform your AJAX/Fetch login

    //     setFormMessage(loginForm, "error", "Invalid username/password combination");
    // });


    
});