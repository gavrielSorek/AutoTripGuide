
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
}(window))