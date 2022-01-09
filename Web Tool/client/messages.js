
(function (global) {
    global.messages = {}
    // The function show a not found message when the user ask for a poi that not exist
    global.messages.showNotFoundMessage = function () {
        Swal.fire({
            icon: 'error',
            title: 'Oops...',
            text: 'The POI according to your request is not found',
        }).then((result) => {
        });
    }

    // The function show a not found message when the user ask for a poi that not exist
    global.messages.showServerNotAccissableMessage = function () {
        Swal.fire({
            icon: 'error',
            title: 'Oops...',
            text: 'Communication Problem',
        }).then((result) => {
        });
    }
    // The function show a general error
    global.messages.showServerNotAccissableMessage = function () {
        Swal.fire({
            icon: 'error',
            title: 'Oops...',
            text: 'Error Has Occurred',
        }).then((result) => {
        });
    }
    // The function show a Loading message.
    global.messages.showLoadingMessage = function () {
        Swal.fire({
            title: 'Please Wait !',
            html: 'data uploading',
            allowOutsideClick: false,
            onBeforeOpen: () => {
                Swal.showLoading()
            },
        });
    }
    // close messages
    global.messages.closeMessages = function () {
        swal.close()
    }

    // The function delete the data from the page
    global.messages.deleteEverything = function () {
        // localStorage.clear();
        location.reload();
    }
    global.messages.createPoiSeccess = function() {
        Swal.fire("Created!", "Your request to create new poi has been sent.", "success");
    }
    global.messages.editPoiSeccess = function() {
        Swal.fire("Poi was edited!",  "Your request to edit poi has been sent.", "success");
    }
    // The function show a not found message when the user not exist
    global.messages.showNotFoundUser = function () {
        Swal.fire({
            icon: 'error',
            title: 'Oops...',
            text: 'The user according to your request is not found',
        }).then((result) => {
        });
    }
    // The function show a not found message when the user not exist
    global.messages.changePermissionSuccess = function () {
        Swal.fire("Changed!", "Your request to change the permission has been sent.", "success");
    }
}(window))