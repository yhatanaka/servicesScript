function run(input, parameters) {
	
	// Your script goes here
var safari = Application("Safari");
var window = safari.windows[0];
var thisTab = window.currentTab();
var pageTitle = thisTab.name();



var TextEdit = Application("TextEdit");
TextEdit.includeStandardAdditions = true;

TextEdit.setTheClipboardTo(pageTitle);
TextEdit.activate();	// アクティブにする

	return pageTitle;
}