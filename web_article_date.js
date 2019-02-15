function run(input, parameters) {
	
	// Your script goes here
// var safari = Application("Safari");
// var window = safari.windows[0];
// var thisTab = window.currentTab();
var thisTab = Application("Safari").windows[0].currentTab();
// var thisSource = thisTab.source();
//	return thisTab.url();
	return [thisTab.url(), thisTab.source()];
}