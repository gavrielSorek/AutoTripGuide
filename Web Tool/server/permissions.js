const ROLE = {
    ADMIN: 'admin',
    USER: 'user'
}
const permissions = {
    'contributor' : 4,
    'approver' : 3,
    'admin' : 1
}
//INIT
var tokens = {}
initAccessTokens();

// init tokens 
function initAccessTokens () {
    tokens['contributor'] = gerRandomToken();
    tokens['approver'] = gerRandomToken();
    tokens['admin'] = gerRandomToken();
}
function gerRandomToken() {
    return Array(50).fill("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").map(function(x) { return x[Math.floor(Math.random() * x.length)] }).join('');
}
function generatTokensPeriodly() {
    initAccessTokens()
    setTimeout(generatTokensPeriodly, 5000);
}
//example
