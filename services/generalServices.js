module.exports = { getTodayDate, getNumOfDaysBetweenDates};

// The function returns the date of today
function getTodayDate(){
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();

    today = dd + '/' + mm + '/' + yyyy;
    return today
}

// The function returns the date of today
function getNumOfDaysBetweenDates(date1, date2){
    // Convert the strings to Date objects
    var date1Object = new Date(date1.split("/").reverse().join("-"));
    var date2Object = new Date(date2.split("/").reverse().join("-"));

    // Calculate the difference in milliseconds
    var diffInMs = Math.abs(date1Object - date2Object);

    // Convert the difference to days
    var diffInDays = diffInMs / (1000 * 60 * 60 * 24);
    return diffInDays;
}
