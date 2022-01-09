const path = require('path');


module.exports = {initAccessTokens, generatTokensPeriodly, getUserTokens, authContributor, authApprover}
const ROLE = {
    ADMIN: 'admin',
    USER: 'user'
}
const PERMISSIONS = {
    '4': 'contributor',
    '3' : 'approver',
    '1' : 'all'
}
const PERMISSIONS_TO_NUMBER = {
    'contributor' : 4,
    'approver' : 3,
    'all' : 1

}
//INIT
var tokens = {}
var oldTokens = {}

// init tokens 
function initAccessTokens () {
    oldTokens = Object.assign({}, tokens);
    tokens['contributor'] = gerRandomToken();
    tokens['approver'] = gerRandomToken();
    tokens['all'] = gerRandomToken();
    if (!oldTokens['contributor']) { //if old tokens are empty
        oldTokens = Object.assign({}, tokens);
    }
}
// generate token
function gerRandomToken() {
    return Array(50).fill("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").map(function(x) { return x[Math.floor(Math.random() * x.length)] }).join('');
}
function generatTokensPeriodly() {
    initAccessTokens()
    setTimeout(generatTokensPeriodly, 1000 * 60 * 60 * 24);
}

function getUserTokens(user, result) {
    result['permissionStatus'] = PERMISSIONS[user[0].permission.toString()] //result[permissionStatus] = contributor for example
    result['PermissionToken'] = tokens[result['permissionStatus']]; //get permission token
}
function authPermission(req, res, next , requirePermission) {
    var permissionStatus = undefined;
    var permissionToken = undefined;
    //init parameters
    if (req.body.permissionStatus && req.body.PermissionToken) {
        permissionStatus = req.body.permissionStatus;
        permissionToken = req.body.PermissionToken;
    } else {
        if(req.query.permissionStatus && req.query.PermissionToken) {
            permissionStatus = req.query.permissionStatus;
            permissionToken = req.query.PermissionToken;
        } else {
            res.status(553);
            res.send('you dont have permission to this page')
            res.end();
        }
    }

    if ((tokens[permissionStatus] == permissionToken ||  oldTokens[permissionStatus] == permissionToken) && PERMISSIONS_TO_NUMBER[permissionStatus] != undefined) {
        if(PERMISSIONS_TO_NUMBER[permissionStatus] <= requirePermission) {next()} //all good
        else {
            res.status(553);
            res.send('you dont have permission to this page')
            res.end();
        }
    } else {
        sendLoginPage(req, res, next)
    }
}

function authContributor(req, res, next) {
    requirePermission = PERMISSIONS_TO_NUMBER['contributor']
    authPermission(req, res, next, requirePermission)
}

function authApprover(req, res, next) {
    requirePermission = PERMISSIONS_TO_NUMBER['approver']
    authPermission(req, res, next, requirePermission)
}
// send login page
function sendLoginPage(req, res, next) {
    res.writeHead(301, {
        Location: `http://localhost:5500`
      }).end();
}
// newUrl.searchParams.append('PermissionToken', localStorage['PermissionToken'])
// newUrl.searchParams.append('emailAddr', localStorage['emailAddr'])
// newUrl.searchParams.append('password', localStorage['password'])
// newUrl.searchParams.append('permissionStatus', localStorage['permissionStatus'])
// newUrl.searchParams.append('userName', localStorage['userName'])

//example
