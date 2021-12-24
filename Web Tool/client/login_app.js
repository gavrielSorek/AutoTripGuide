//variables definition
var loginForm = document.querySelector("#login");
var createAccountForm = document.querySelector("#createAccount");
var signupUsername = document.getElementById("signupUsername");
var signupEmailAddr = document.getElementById("signupEmailAddr");
var signupPassword = document.getElementById("signupPassword");
var signupConfirmPassword = document.getElementById("signupConfirmPassword");
var signinUsername = document.getElementById("signinUsername");
var signinPassword = document.getElementById("signinPassword");

//query selector
document.querySelectorAll(".form__input").forEach(inputElement => {
    inputElement.addEventListener("blur", e => {
        if (e.target.id === "signupUsername" && e.target.value.length > 0 && e.target.value.length < 10) {
            setInputError(inputElement, "Username must be at least 10 characters in length");
        }
        if (e.target.id === "signupConfirmPassword" && e.target.value != signupPassword.value) {
            setInputError(inputElement, "The passwords do not match");
        }
    });
    inputElement.addEventListener("input", e => {
        clearInputError(inputElement);
    });
});


function login(){
    console.log("signinUsername: " + signinUsername.value + "signinPassword: " + signinPassword.value)
    signinUsernameVal = signinUsername.value
    signinPasswordVal = signinPassword.value
    if(signinUsernameVal.length == 0 || signinPasswordVal == 0) {
        setFormMessage(loginForm, "error", "Invalid username/password combination");
        return
    }
    var userInfo = {
        userName  : signinUsernameVal,
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
                var jsonResponse = JSON.parse(Http.responseText);
                if (jsonResponse.localeCompare("success") == 0) {
                console.log("The user exist - login success");
            } else {
                console.log("The user not exist - login failed");
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
        password  : signupPasswordVal
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
                console.log(jsonResponse);
            } else {
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