'use strict';
function run(input, parameters) {
  
  //var app = Application.currentApplication()
  //app.includeStandardAdditions = true;
  
  //mySelection;
  
  // My Code from here
  //var sys = Application("System Events");
  
  var safari = Application("Safari");
  var window = safari.windows[0];
  var thisTab = window.currentTab();
  var pageTitle = thisTab.name();
  var pageURL = thisTab.url();
  
  var TextEdit = Application("TextEdit");
  var doc = TextEdit.Document();	// 新規にドキュメントを作成
  TextEdit.activate();	// アクティブにする
  TextEdit.documents.push(doc);	//　画面に表示する
  doc.text = pageURL + "\n\n" + pageTitle + "\n\n";	// 文字を出力する
  
  //var mySelection = copySelection("Safari", 1)
  
  //delay(1);	// アクティブになり切り替わるのを少し待つ
  //sys.keyCode(36);	// returnを入力
  //sys.keyCode(36);	// returnを入力
  //sys.keystroke("v", {using:"command down"});
  //delay(200);	// アクティブになり切り替わるのを少し待つ
  
  return pageTitle;
  
  //TextEdit.includeStandardAdditions = true;
  
  //TextEdit.setTheClipboardTo(pageTitle);
  //sys.keystroke("s", {using:"command down"});
  
  /*
  */
  // My Code til here
  
  
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function copySelection(pAppName, pTimeLimitSec) {
    //---------------------------------------------------------------------------------
    /*  VER: 1.1.1     DATE: 2016-06-18
    PARAMETERS:
  •  pAppName  : Name of App in which to copy selection
      • IF pAppName is invalid, script will stop with error msg
  • pTimeLimitSec    :  Max number of seconds to wait for App Copy to complete
                        • usually 2-3 sec is adequate
                        • If you are expecting a short text selection and
                          possibly no selection, then 1 sec should work
  
  RETURNS:
  •  Items that were selected in the App (text, rich text, images, etc)
  • IF no selection was made, an empty string is returned
  
  PURPOSE:    Copy Selection to Clipboard, & Return Value
  AUTHOR:  JMichaelTX (in most forums)
           Find any bugs/issues or have suggestions for improvement?
           Contact me via PM or at blog.jmichaeltx.com/contact/
           
           CHANGE LOG:
  1.1.1  2016-06-18    ADD Parameter for pTimeLimitSec
  1.1    2016-06-17    ADD timeout loop to wait for App to complete copy
  1.0    2016-06-17    First Release
  
  REF:     https://github.com/dtinth/JXA-Cookbook/wiki/System-Events
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
    'use strict';
    
    
    //--- GET A REF TO CURRENT APP WITH STD ADDITONS ---
    var app = Application.currentApplication()
    app.includeStandardAdditions = true
    var seApp = Application('System Events')
    
    //--- Set the Clipboard so we can test for no selection ---
    app.setTheClipboardTo("[NONE]")
    
    //--- Activate the App to COPY the Selection ---
    try {
      var activeApp = Application(pAppName)
    }
    catch (e) {
      throw(new Error("Invalid Application Name: " + pAppName));
    }
    activeApp.activate()
    delay(0.2)  // adjust the delay as needed
    
    //--- Issue the COPY Command ---
    seApp.keystroke('c', { using: 'command down' }) // Press ⌘C 
    
    //--- LOOP UNTIL TIMEOUT TO PROVIDE TIME FOR APP TO COMPLETE COPY ---
    
    var startTime = new Date().getTime()  // number of milliseconds since 1970/01/01
    var timeLimitMs = pTimeLimitSec * 1000.0
    var clipContents = ""
    
    while ((new Date().getTime() - startTime) < timeLimitMs) {
      
      delay(0.2)  // adjust the delay as needed
      
      //--- Get the content on the Clipboard ---
      clipContents = app.theClipboard()
      //console.log(clipContents)
      
      if (clipContents !== "[NONE]") break;
      
    } // END WHILE waiting for copy to complete
    
    //--- Display Alert if NO Selection was Made ---
    if (clipContents === "[NONE]") {
      clipContents = ""
      var msgStr = "App: " + pAppName
      //  console.log(msgStr)
      app.displayNotification(
        msgStr, 
        {
          withTitle: ("Copy Selection"),
          subtitle:  "NO SELECTION was made!",
          soundName: "Glass.aiff"
      })
    }  // END IF (clipContents === "[NONE]")
    
    return clipContents
    
  } // END function copySelection()
}