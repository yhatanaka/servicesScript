function run(input, parameters) {
	
function datetostr(date, format, is12hours) {
    var weekday = ["日", "月", "火", "水", "木", "金", "土"];
    if (!format) {
        format = 'YYYY/MM/DD(WW) hh:mm:dd'
    }
    var year = date.getFullYear();
    var month = (date.getMonth() + 1);
    var day = date.getDate();
    var weekday = weekday[date.getDay()];
    var hours = date.getHours();
    var minutes = date.getMinutes();
    var secounds = date.getSeconds();
    var ampm = hours < 12 ? 'AM' : 'PM';
    if (is12hours) {
        hours = hours % 12;
        hours = (hours != 0) ? hours : 12; // 0時は12時と表示する
    }
    var replaceStrArray =
        {
            'YYYY': year,
            'Y': year,
            'MM': ('0' + (month)).slice(-2),
            'M': month,
            'DD': ('0' + (day)).slice(-2),
            'D': day,
            'WW': weekday,
            'hh': ('0' + hours).slice(-2),
            'h': hours,
            'mm': ('0' + minutes).slice(-2),
            'm': minutes,
            'ss': ('0' + secounds).slice(-2),
            's': secounds,
            'AP': ampm,
        };
    var replaceStr = '(' + Object.keys(replaceStrArray).join('|') + ')';
    var regex = new RegExp(replaceStr, 'g');
    ret = format.replace(regex, function (str) {
        return replaceStrArray[str];
    });
    return ret;
}

	console.log( datetostr(new Date(), 'YYYY-MM-DDThh_mm_ss@JST', false));
}