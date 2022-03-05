
(function (global) {
    permissions = {}

    permissions.PERMISSIONS_TO_NUMBER = {
        'contributor': 4,
        'approver': 3,
        'all': 1
    }
    permissions.isPermitted = function(neededPermission){
        if (permissions.PERMISSIONS_TO_NUMBER[localStorage['permissionStatus']] <= permissions.PERMISSIONS_TO_NUMBER[neededPermission]) {
            return true;
        }
        return false;
    }


    // adjust buttons according to permissions
    NavigationBar = global.document.getElementById("NavigationBar")
    if (NavigationBar && localStorage['permissionStatus'] == 'all') {
        NavigationBar.innerHTML += '<a onclick="communication.permissionsManagement()" class="w3-bar-item w3-button w3-hide-small"><i class="fa fa-tasks"></i> PERMISSIONS-MANAGEMENT</a>';
    }
}(window))