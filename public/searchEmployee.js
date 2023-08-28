function searchEmployeeByFirstName() {
    //get the first name
    var first_name_searcg_string = document.getElementById('first_name_search_string')
    //construct the url and redirect to it
    if (first_name_search_string !== '' ){
        window.location = '/employee/search/' + encodeURI(first_name_search_string);
    } else {
        window.location = '/employee;'
    }
}