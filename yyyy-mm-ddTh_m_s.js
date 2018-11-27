function run(input, parameters) {

    function to_2digit(str) {
        return ('0' + str).slice(-2);
    }

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
                'MM': to_2digit(month),
                'M': month,
                'DD': to_2digit(day),
                'D': day,
                'WW': weekday,
                'hh': to_2digit(hours),
                'h': hours,
                'mm': to_2digit(minutes),
                'm': minutes,
                'ss': to_2digit(secounds),
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

	return datetostr(new Date(), 'YYYY-MM-DDThh_mm_ss@JST', false);
}