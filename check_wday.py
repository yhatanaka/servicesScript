#!/usr/bin/python3
import calendar
weekday_ary = ['月','火','水','木','金','土','日']
day_str = '2021/8/12'

day_ary = day_str.split('/')
if len(day_ary) == 2: # M/D
    day_y = 2021
    day_m = int(day_ary[0])
    day_d = int(day_ary[1])
else if len(day_ary) == 3: # Y/M/D
    day_y = int(day_ary[0])
    day_m = int(day_ary[1])
    day_d = int(day_ary[2])
else if len(day_ary) == 0 # 
    day_ary_1 = day_str.split('年')
    if len(day_ary_1) == 2: # Y年
        day_y = int(day_ary_1[0])
        day_md_ary = day_ary_1[1].split('月')
        day_m = day_md_ary[0]
    else if len(day_ary_1) == 1: # M月D日
        day_ary_2 = day_str.split('月')

day_wday_idx = calendar.weekday(day_y,day_m,day_d)
weekday_ary[day_wday_idx]
