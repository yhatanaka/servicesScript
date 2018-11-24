function run(input, parameters) {
	
var today = new Date();
var year = today.getFullYear();
var month = today.getMonth()+1;
var date = today.getDate();
var options = {
	year: "numeric", month: "2-digit", day: "2-digit"
};
function to2Digit(someNumber) {
	if (someNumber < 10) {
		someNumber = '0' + someNumber
	}
	return someNumber
//	return ('0' + someNumber).slice(-2)
}

	result = year.toString() + '-' + to2Digit(month.toString()) + '-' + to2Digit(date.toString());
	return result
//	console.log( result);
}