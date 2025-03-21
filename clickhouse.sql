-- time

ts(unix time stamp) - 'Seconds since Jan 01 1970'
  toDateTime64(ts, 3) AS Datetime

toStartOfDay(Datetime)             -- 1 day
toStartOfHour(Datetime)            -- 1 hour
timeSlot(Datetime)                 -- 30 min
toStartOfFifteenMinutes(Datetime)  -- 15 min
toStartOfTenMinutes(Datetime)      -- 10 min
toStartOfFiveMinutes(Datetime)     -- 5 min
toStartOfMinute(Datetime)          -- 1 min


-- select

uniq(user) as users -- for Exact count - count(distinct user) as users
countIf(status, status >= 200 AND status < 300) AS "2xx"
'|' AS sep,

____________________________________________
"""
1 Hour    - 3600 Seconds
1 Day	    - 86400 Seconds
1 Week    - 604800 Seconds
1 Month   - (30.44 days)	2629743 Seconds
1 Year    - (365.24 days)	31556926 Seconds
"""


