/* Количество регистраций на  RT по годам */
SELECT is_active, COUNT(is_active) AS all,
    SUM(CASE WHEN created_ts like '2020%' THEN 1 ELSE 0 END) AS "2020",
    SUM(CASE WHEN created_ts like '2021%' THEN 1 ELSE 0 END) AS "2021",
    SUM(CASE WHEN created_ts like '2022%' THEN 1 ELSE 0 END) AS "2022",
    SUM(CASE WHEN created_ts like '2023%' THEN 1 ELSE 0 END) AS "2023",
    SUM(CASE WHEN created_ts like '2024%' THEN 1 ELSE 0 END) AS "2024"
FROM dict.squirrel_list_profile
GROUP BY is_active
--_______________________________________________________--
/* CH_PROXY_DWH*/
/* Список устройств с которых были просмотры за день */
    SELECT DISTINCT ua_device_type
    FROM dwh_core.GOYA_View_Events
    WHERE event_date = '2024-12-01'
    LIMIT 100;

/* Список устройств с которых были просмотры за неделю */
SELECT 
    viewer_user_id,
    SUM(CASE WHEN event_date IN ('2024-12-02', '2024-12-03', '2024-12-04', '2024-12-05', '2024-12-06', '2024-12-07', '2024-12-08') THEN 1 ELSE 0 END) AS total_events,
    SUM(CASE WHEN event_date = '2024-12-02' THEN 1 ELSE 0 END) AS monday,
    SUM(CASE WHEN event_date = '2024-12-03' THEN 1 ELSE 0 END) AS tuesday,
    SUM(CASE WHEN event_date = '2024-12-04' THEN 1 ELSE 0 END) AS wednesday,
    SUM(CASE WHEN event_date = '2024-12-05' THEN 1 ELSE 0 END) AS thursday,
    SUM(CASE WHEN event_date = '2024-12-06' THEN 1 ELSE 0 END) AS friday,
    SUM(CASE WHEN event_date = '2024-12-07' THEN 1 ELSE 0 END) AS saturday,
    SUM(CASE WHEN event_date = '2024-12-08' THEN 1 ELSE 0 END) AS sunday
FROM dwh_core.GOYA_View_Events
WHERE viewer_user_id != '0' and event_date IN ('2024-12-02', '2024-12-03', '2024-12-04', '2024-12-05', '2024-12-06', '2024-12-07', '2024-12-08')
GROUP BY viewer_user_id
ORDER BY total_events DESC
LIMIT 100;

/* Список ID пользователя и кол-во просмотров за день (PROD meowth)*/
SELECT viewer_user_id, COUNT(viewer_user_id) AS count
FROM dwh_core.GOYA_View_Events
WHERE event_date = '2024-11-01' and  viewer_user_id != '0'
group by viewer_user_id
order by COUNT(viewer_user_id) desc
LIMIT 100;

/* История всех комментов по user ID */
select * from comments
where user_id = '13870381'
limit 1000


/* Сумма подключений по регионам текущего пользователя за день */
SELECT viewer_user_id, video_id, count(video_id)
FROM dwh_core.GOYA_View_Events
WHERE event_date = '2024-11-01' and  viewer_user_id = '45297617'
group by viewer_user_id, video_id
order by count(video_id) desc
LIMIT 100;

/* Сумма просмотров по пользователю за день */
SELECT viewer_user_id, region, count(region)
FROM dwh_core.GOYA_View_Events
WHERE event_date = '2024-11-01' and  viewer_user_id = '45297617'
group by viewer_user_id, region
order by count(region) desc
LIMIT 100;

/* История просмотра пользователя за день */
SELECT event_timestamp, view_id, region, ua_client_type, apm_os, watchtime, video_position
FROM dwh_core.GOYA_View_Events
WHERE event_date = '2024-11-01' and  viewer_user_id = '45297617'
LIMIT 1000

/* Количесво просмотров распределенные по устройствам за 1 день */
SELECT city,
    COUNT(ua_device_type) AS all,
    SUM(CASE WHEN ua_device_type = 'smartphone' THEN 1 ELSE 0 END) AS "smartphone",
    SUM(CASE WHEN ua_device_type = 'desktop' THEN 1 ELSE 0 END) AS "desktop",
    SUM(CASE WHEN ua_device_type = 'tv' THEN 1 ELSE 0 END) AS "tv",
    SUM(CASE WHEN ua_device_type = 'phablet' THEN 1 ELSE 0 END) AS "phablet",
    SUM(CASE WHEN ua_device_type = 'tablet' THEN 1 ELSE 0 END) AS "tablet",
    SUM(CASE WHEN ua_device_type = 'nan' THEN 1 ELSE 0 END) AS "nan",    
    SUM(CASE WHEN ua_device_type = 'console' THEN 1 ELSE 0 END) AS "PlayStation",
    SUM(CASE WHEN ua_device_type = 'peripheral' THEN 1 ELSE 0 END) AS "PROJECTOR",
    SUM(CASE WHEN ua_device_type = 'wearable' THEN 1 ELSE 0 END) AS "VR",
    SUM(CASE WHEN ua_device_type = '' THEN 1 ELSE 0 END) AS "null"
FROM dwh_core.GOYA_View_Events
WHERE event_date = '2024-11-01'
group by city
order by COUNT(ua_device_type) desc
LIMIT 100;

/* Количесво просмотров распределенные по пользователям и месяцам */
SELECT 
    event.viewer_user_id, 
    COUNT(event.viewer_user_id) AS count,
    profile.name,
    profile.email,
    SUM(CASE WHEN event_date >= '2024-01-01' AND event_date < '2024-02-01' THEN 1 ELSE 0 END) AS "1",
    SUM(CASE WHEN event_date >= '2024-02-01' AND event_date < '2024-03-01' THEN 1 ELSE 0 END) AS "2",
    SUM(CASE WHEN event_date >= '2024-03-01' AND event_date < '2024-04-01' THEN 1 ELSE 0 END) AS "3",
    SUM(CASE WHEN event_date >= '2024-04-01' AND event_date < '2024-05-01' THEN 1 ELSE 0 END) AS "4",
    SUM(CASE WHEN event_date >= '2024-05-01' AND event_date < '2024-06-01' THEN 1 ELSE 0 END) AS "5",
    SUM(CASE WHEN event_date >= '2024-06-01' AND event_date < '2024-07-01' THEN 1 ELSE 0 END) AS "6",
    SUM(CASE WHEN event_date >= '2024-07-01' AND event_date < '2024-08-01' THEN 1 ELSE 0 END) AS "7",
    SUM(CASE WHEN event_date >= '2024-08-01' AND event_date < '2024-09-01' THEN 1 ELSE 0 END) AS "8",
    SUM(CASE WHEN event_date >= '2024-09-01' AND event_date < '2024-10-01' THEN 1 ELSE 0 END) AS "9",
    SUM(CASE WHEN event_date >= '2024-10-01' AND event_date < '2024-11-01' THEN 1 ELSE 0 END) AS "10",
    SUM(CASE WHEN event_date >= '2024-11-01' AND event_date < '2024-12-01' THEN 1 ELSE 0 END) AS "11",
    SUM(CASE WHEN event_date >= '2024-12-01' AND event_date <= '2024-12-25' THEN 1 ELSE 0 END) AS "12"
FROM 
    dwh_core.GOYA_View_Events AS event
LEFT JOIN dict.squirrel_list_profile AS profile ON event.viewer_user_id = profile.user_id
WHERE 
    event_date >= '2024-01-01' AND event_date <= '2024-12-25' AND event.viewer_user_id != '0'
GROUP BY 
    event.viewer_user_id, profile.name, profile.email
ORDER BY 
    COUNT(event.viewer_user_id) DESC
LIMIT 100;

/* Кол-во ошибок на саламе */
SELECT 
    toDate(ts) AS dt,
    geoip_country,
    geoip_region,
    edge,
    COUNT(dive) AS c,
    SUM(CASE WHEN e = 'start' THEN 1 ELSE 0 END) AS "start",
    SUM(CASE WHEN e = 'play_start' THEN 1 ELSE 0 END) AS "play_start",
    SUM(CASE WHEN e = 'buffering_start' THEN 1 ELSE 0 END) AS "buf",
    SUM(CASE WHEN e = '10sec' THEN 1 ELSE 0 END) AS "10sec",
    SUM(CASE WHEN e = 'error' THEN 1 ELSE 0 END) AS "error",    
    SUM(CASE WHEN e = 'end' THEN 1 ELSE 0 END) AS "end"
FROM 
    player.events
WHERE 
    edge = 'salam-kem-88.rutube.ru' 
    AND ts >= '1737752400' 
    AND ts < '1738011600'
GROUP BY 
    dt, geoip_country, geoip_region, edge
ORDER BY 
    c desc

/* Кол-во ошибок и процентов относительно общего кол-ва по городам */
SELECT 
    toDate(ts) AS dt,
    video_id,
    uniq(did) AS cnt,ё
    geoip_country, 
    geoip_region, 
    geoip_city,
    edge, 
    count() AS c,
    sum(e = 'start') AS "Open URL",
    sum(e = 'play_start') AS "Start watching",
    sum(e = 'buffering_start') AS "buffering",
    sum(e = 'buffering_end') AS "buffering_end",    
    sum(e = '10sec') AS "10sec",
    sum(e = 'error') AS "error",    
    sum(e = 'first_fragment') AS "first_fragment",
    sum(e = 'change_qm') AS "change_qm",    
    sum(e = 'change_sm') AS "change_sm",
    sum(e = 'pause') AS "pause",
    sum(e = 'unpause') AS "unpause",
    sum(e = 'options_request') AS "options_request",
    sum(e = 'rewind') AS "rewind",
    sum(e = 'change_q') AS "change_q",
    sum(e = 'a_request') AS "a_request",
    sum(e = 'a_start') AS "a_start",
    sum(e = 'a_end') AS "a_end",
    sum(e = 'bl_request') AS "bl_request",
    sum(e = 'change_v') AS "change_v",
    sum(e = 'end') AS "end",

    (sum(e = 'start') * 100.0) / count() AS "Open URL pr",
    (sum(e = 'play_start') * 100.0) / count() AS "Start watching pr",
    (sum(e = 'buffering_start') * 100.0) / count() AS "buffering pr",
    (sum(e = 'buffering_end') * 100.0) / count() AS "buffering_end pr",    
    (sum(e = '10sec') * 100.0) / count() AS "10sec pr",
    (sum(e = 'error') * 100.0) / count() AS "error pr",    
    (sum(e = 'first_fragment') * 100.0) / count() AS "first_fragment pr",
    (sum(e = 'change_qm') * 100.0) / count() AS "change_qm pr",    
    (sum(e = 'change_sm') * 100.0) / count() AS "change_sm pr",
    (sum(e = 'pause') * 100.0) / count() AS "pause pr",
    (sum(e = 'unpause') * 100.0) / count() AS "unpause pr",
    (sum(e = 'options_request') * 100.0) / count() AS "options_request pr",
    (sum(e = 'rewind') * 100.0) / count() AS "rewind pr",
    (sum(e = 'change_q') * 100.0) / count() AS "change_q pr",
    (sum(e = 'a_request') * 100.0) / count() AS "a_request pr",
    (sum(e = 'a_start') * 100.0) / count() AS "a_start pr",
    (sum(e = 'a_end') * 100.0) / count() AS "a_end pr",
    (sum(e = 'bl_request') * 100.0) / count() AS "bl_request pr",
    (sum(e = 'change_v') * 100.0) / count() AS "change_v pr",    
    (sum(e = 'end') * 100.0) / count() AS "end pr"
FROM 
    player.events
WHERE 
    event_date = '2025-01-31' 
    and qw > 0 and qh > 0 and v >=1
GROUP BY 
    dt, video_id, geoip_country, geoip_region, geoip_city, edge
ORDER BY 
    c DESC
LIMIT 100;

--Макс Волков - колво подключений по саламам с выбранного региона 

select 
    geoip_country, 
    geoip_region, 
    count(geoip_region) as c,
    count(distinct sid) as dsid
from 
    player.events
where 
    view_id is not null 
    and event_date = '2025-01-01' 
    and geoip_country = 'RU'
    and qw >= 1 
    and qh >= 1
group by 
    geoip_country, 
    geoip_region,
    video_id
order by 
    c desc
limit 100

-- поиск кол-ва пользователей
select 
    geoip_country,
    count() as event_of_user,
    count(distinct geoip_region) as region,
    count(distinct sid) as user_id_from_cookie,
    count(distinct pid) as session_player_id,
    count(distinct did) as fingerprint,
    count(distinct http_user_agent) as user_agent,
    count(distinct uid) as user_id,
    uniq(if(uid='', concat(remote_addr, '-', http_user_agent, '-', did), uid)) as uniq_users,
    count(distinct remote_addr) as user_ip,    
    count(distinct real_ip) as curator_ip,
    count(distinct sid) as user_id_from_cookie,
    count(distinct video_id) as video_id,
    count(distinct view_id) as view_id
from 
    player.events
where 
    event_date = '2025-02-09'
    and qw >= 1
    and qh >= 1 
    
group by geoip_country
order by event_of_user desc
limit 100

--ошибки за сутки

SELECT 
    toStartOfFifteenMinutes(dt) AS ddd,
    sumIf(st, st >= 200 AND st < 300) AS "200",
    sumIf(st, st >= 300 AND st < 400) AS "300",
    sumIf(st, st >= 400 AND st < 500) AS "400",
    sumIf(st, st >= 500 AND st < 600) AS "500"    
FROM logcollect.edge_event
WHERE event_date = '2025-02-15'
GROUP BY ddd
LIMIT 1000

--поиск накрутки

SELECT 
    event.viewer_user_id,
    profile.name, 
    profile.email,
    COUNT(event.viewer_user_id) AS cnt,
      (event_date = '2025-02-15') AS "15",
    COUNTIf(event_date = '2025-02-16') AS "16",
    COUNTIf(event_date = '2025-02-17') AS "17"
FROM 
    dwh_core.GOYA_View_Events AS event
LEFT JOIN 
    dict.squirrel_list_profile AS profile ON event.viewer_user_id = profile.user_id
WHERE 
    event_date >= '2025-02-15' 
    AND event_date < '2025-02-18'
    AND viewer_user_id != '0'
    AND video_id = '207196799db16ea85bd0f32a6b7eb052'
GROUP BY 
    event.viewer_user_id, profile.name, profile.email
ORDER BY 
    event.viewer_user_id;


-- Трафик CDN
select event_date,host, (sum(mb_sent)/1000) as traffic_Gb from cdn.traffic_day
where event_date = '2025-01-28' and mb_sent >0 and host = 'salam-smr-41.rutube.ru'
group by event_date, host 
limit 100

-- кол-во просмотров в секунду 
select event_timestamp, count(event_timestamp) from dwh_core.GOYA_View_Events
where event_timestamp >='2025-02-17 20:40:00'
    and event_timestamp < '2025-02-17 21:10:00'
    and watchtime >1
    and video_position >1
group by event_timestamp
order by event_timestamp

SELECT 
    toDateTime64(ts, 3) AS ttt,  -- Преобразуем ts в DateTime64 с точностью 3 (миллисекунды)
    geoip_city,
    count(geoip_city) AS geoip_city_count,
    e,
    count(e) AS e_count,
    em,
    count(em) AS em_count,
    edge,
    count(edge) AS edge_count,
    ps,
    count(ps) AS ps_count,
    video_id,
    count(video_id) AS video_id_count
FROM 
    player.events
WHERE 
    event_date = today()  -- Фильтр по сегодняшней дате
    AND edge = 'river-1.rutube.ru'
    AND toDate(toDateTime64(ts, 3)) = today()  -- Дополнительный фильтр по дате из ts
GROUP BY 
    ttt,  -- Группируем по преобразованному времени
    geoip_city,
    e,
    em,
    edge,
    ps,
    video_id
ORDER BY 
    ttt DESC  -- Сортировка по времени в порядке убывания
LIMIT 250;

-- Просмотры видео по аккаунтам - накрутка 
SELECT 
    event.viewer_user_id,
    profile.name, 
    profile.email,
    COUNT(event.viewer_user_id) AS cnt,
    COUNTIf(event_date = '2025-02-15') AS "15",
    COUNTIf(event_date = '2025-02-16') AS "16",
    COUNTIf(event_date = '2025-02-17') AS "17",
    COUNTIf(event_date = '2025-02-18') AS "18"
FROM 
    dwh_core.GOYA_View_Events AS event
LEFT JOIN 
    dict.squirrel_list_profile AS profile ON event.viewer_user_id = profile.user_id
WHERE 
    event_date >= '2025-02-15' 
    AND event_date < '2025-02-19'
    AND viewer_user_id != '0'
    AND video_id = '207196799db16ea85bd0f32a6b7eb052'
GROUP BY 
    event.viewer_user_id, profile.name, profile.email
ORDER BY 
    event.viewer_user_id
LIMIT 1000;



SELECT 
    toStartOfFifteenMinutes(toDateTime64(ts, 3)) AS ttt, --toStartOfHour
    host,
    st,
    count(st)
FROM 
    logcollect.edge_events
WHERE 
    event_date BETWEEN '{{date1}}' AND '{{date2}}'
    AND host = '{{edge}}'
GROUP BY 
    ttt, st, host
ORDER BY 
    ttt
LIMIT 1000;

501	2	
401	4	
505	10	
413	231	
0	350	
412	622	
301	2225	
444	5004	
414	7861	
416	448812	
204	495295	
500	919985	
415	951703	
408	1297563	
405	3445731	
403	12882912	
504	28554394	
502	87713917	
410	123766999	
499	364283280	
400	516557924	
404	658534469	
304	1196467336	
206	7849965206	
200	234946438403

select 
    st, count(st)
 from logcollect.edge_events
where event_date BETWEEN '{{date1}}' AND '{{date2}}'
    AND host = '{{edge}}'
group by
    st
order by 
    st

200	75511068	
206	1860125	
304	435594	
400	12916	
403	68	
404	58680	
410	43084	
499	29898	
502	32	
504	5	

---------------------
select 
    video_id, 
    count(geoip_city), 
    count(edge), 
    count(dive), 
    count(e), 
    count(em), 
    count(ps),
    uniq(if(uid = '', concat(remote_addr, '-', http_user_agent, '-', did), uid)) AS uniq_users
from 
    player.events
where 
    event_date = today()
    and em != ''
group by video_id
order by video_id desc
limit 250

---------------------

SELECT 
    edge, 
    uniq(if(uid = '', concat(remote_addr, '-', http_user_agent, '-', did), uid)) AS uniq_users,
    uniq(video_id) AS uniq_videos,
    sum(geoip_region = 'Yerevan') AS "Yerevan",
    sum(geoip_region = 'Shirak') AS "Shirak",
    sum(geoip_region = 'Kotayk') AS "Kotayk",
    sum(geoip_region = 'Armavir') AS "Armavir",
    sum(geoip_region = '') AS "Null",
    sum(geoip_region = 'Lori') AS "Lori",
    sum(geoip_region = 'Ararat') AS "Ararat",
    sum(geoip_region = 'Gegharkunik') AS "Gegharkunik",
    sum(geoip_region = 'Syunik') AS "Syunik",
    sum(geoip_region = 'Aragatsotn') AS "Aragatsotn",
    sum(geoip_region = 'Tavush') AS "Tavush",
    sum(geoip_region = 'Vayots Dzor') AS "Vayots Dzor"
FROM 
    player.events
WHERE 
    event_date >= '2025-02-17'
    AND event_date < '2025-02-24'
    AND geoip_country = 'AM'
    AND qw >= 1 
    AND qh >= 1
    AND e = 'play_start'
group by edge
order by uniq_users desc



SELECT
    toStartOfHour(toDateTime(ts)) AS hour, 
    count() AS total_requests,
    countIf(status, status >= 200 AND status < 300) AS "2xx",
    countIf(status, status >= 300 AND status < 400) AS "3xx",
    countIf(status, status >= 400 AND status < 500) AS "4xx",
    countIf(status, status >= 500 AND status < 600) AS "5xx",
    '|' AS sep,
    countIf(method, method = 'GET') AS "GET",    
    countIf(method, method = 'HEAD') AS "HEAD",    
    countIf(method, method = 'POST') AS "POST",
    countIf(method, method = 'OPTIONS') AS "OPTIONS",   
    countIf(method, method = 'PATCH') AS "PATCH",     
    countIf(method, method = 'PUT') AS "PUT",     
    countIf(method, method = 'DELETE') AS "DELETE",
    countIf(method, method = 'DEBUG') AS "DEBUG",
    countIf(method, method = 'PURGE') AS "PURGE",    
    countIf(method, method = 'AAAA') AS "AAAA",    
    countIf(method, method = '') AS "NULL_method",
    '|' AS sep2,
    countIf(cst, cst = 'HIT') AS "HIT",
    countIf(cst, cst = 'MISS') AS "MISS",
    countIf(cst, cst = 'STALE') AS "STALE",
    countIf(cst, cst = 'EXPIRED') AS "EXPIRED",
    countIf(cst, cst = 'UPDATING') AS "UPDATING",
    countIf(cst, cst = '') AS "NULL_cst"
FROM logcollect.frontend_events
WHERE event_date = '2025-02-20'
GROUP BY hour
ORDER BY hour


Alarms: 

select 
    em, 
    count(*) as c, 
    countIf(em = '%D0%9F%D0%BE%D1%82%D0%B5%D1%80%D1%8F%D0%BD%D0%B0+%D1%81%D0%B2%D1%8F%D0%B7%D1%8C+%D1%81+%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D0%BD%D0%B5%D1%82%D0%BE%D0%BC') as "Internet_connection_lost",
    '|' AS "MediaError",
    countIf(em = 'mediaError+-+bufferStalledError') as "bufferStalledError",
    countIf(em = 'mediaError+-+bufferNudgeOnStall') as "bufferNudgeOnStall",
    countIf(em = 'mediaError+-+bufferFullError') as "bufferFullError",
    countIf(em = 'mediaError+-+bufferSeekOverHole') as "bufferSeekOverHole",
    countIf(em = 'mediaError+-+bufferAppendError') as "bufferAppendError",
    '|' AS "MetworkError",
    countIf(em = 'networkError+-+fragLoadTimeOut') as "fragLoadTimeOut",
    countIf(em = 'networkError+-+fragLoadError') as "fragLoadError",
    countIf(em = 'networkError+-+levelLoadError') as "levelLoadError",
    countIf(em = 'networkError+-+levelLoadTimeOut') as "levelLoadTimeOut",
    countIf(em = 'networkError+-+manifestLoadError') as "manifestLoadError",
    '|' AS "otherError",
    countIf(em = 'otherError+-+internalException') as "internalException",
    countIf(em = 'playOptions+return+stub%3A+default_does_not_exists_video') as "does_not_exists_video",
    countIf(em = 'playOptions+return+stub%3A+user_deleted_video') as "user_deleted_video",
    countIf(em = 'VastInvalidResponseCodeException') as "VAST_Invalid_Response",
    countIf(em = 'playOptions+return+stub%3A+undefined') as "undefined",
    '|' AS "different error",
    countIf(em ilike 'playOptions+return+stub%3A+blocking_rule_%') as "blocking_rule",
    countIf(em ilike '%player_error%' or em ilike '%error_event_from_player%') as "player_error",
    countIf(em ilike 'networkError+-+frag%' or em ilike 'networkError%2520-%2520frag%') as "Network_Error_Fragments",
    countIf(em ilike 'networkError+-+level%' or em ilike 'networkError%2520-%2520level%') as "Network_Error_Quality",
    countIf(em ilike 'networkError+-+manifest%' or em ilike 'networkError%20-%20manifest%') as "Network_Error_Manifest",
    countIf(em ilike 'playOptions+return+stub%3A+blocking_rule_%') as "blocking_rule",
    countIf(em ilike 'mediaError+-+buffer%') as "Media_error_buffer"

from player.events
where event_date >= '2025-01-01'

group by em
order by c desc 
limit 100000


select 
    edge, 
    count(edge) as c, 
    --event_date,
    COUNTIf(event_date = '2025-03-17') AS "17",
    COUNTIf(event_date = '2025-03-18') AS "18",
    COUNTIf(event_date = '2025-03-19') AS "19",
    COUNTIf(event_date = '2025-03-20') AS "20",
    COUNTIf(event_date = '2025-03-21') AS "21",
    COUNTIf(event_date = '2025-03-22') AS "22",
    COUNTIf(event_date = '2025-03-23') AS "23",
    COUNTIf(event_date = '2025-03-24') AS "24",
    COUNTIf(event_date = '2025-03-25') AS "25",
    COUNTIf(event_date = '2025-03-26') AS "26",
    COUNTIf(event_date = '2025-03-27') AS "27"
from player.events
where 
    geoip_asn = '39087'
    --geoip_asn = '39927'
    --geoip_asn = '50923'
    and event_date >= '2025-03-17'
    and edge != ''
    and (edge ilike 'salam%' or edge ilike 'river%')
group by edge--, event_date
order by c desc
limit 100000

--вывод сессий пользователя со временем
SELECT 
    min(toDateTime64(ts, 0)) as dt, 
    uid as user_id,
    pid as player_id
FROM player.events
WHERE 
    event_date >= '2025-03-30'
    AND uid = '13870385'
GROUP BY pid, uid
ORDER BY dt
limit 1000


SELECT 
    min(toDateTime64(ts, 0)) as first_event_time,
    uid as user_id,
    pid as player_id
FROM player.events
WHERE 
    event_date = '2025-03-18'
    AND uid IN (
        SELECT DISTINCT uid
        FROM player.events
        WHERE 
            toDateTime64(ts, 0) >= '2025-03-18 03:40:00'
            AND toDateTime64(ts, 0) <= '2025-03-18 04:50:00'
            AND (edge = 'river-3-327.rutube.ru' OR dive = 'river-3-327.rutube.ru')
            AND uid != ''
    )
GROUP BY uid, pid
ORDER BY first_event_time
LIMIT 100000

select timeSlot(toDateTime64(ts, 3)) AS ttt, count(*) as Total, geoip_asn
FROM logcollect.static_events
WHERE toDateTime(ts)>='2025-04-01 00:00:00' and toDateTime(ts)<'2025-04-01 15:40:00'
GROUP BY geoip_asn, ttt
ORDER BY Total desc

--кол-во аварий за неделю
select
toStartOfFifteenMinutes(toDateTime64(ts, 3)) AS ttt, 
em, count(em) as c 
from player.events
where 
    event_date >= '2025-02-28'
    and event_date < '2025-03-03'
    and em != ''
    and em in (
        'mediaError+-+bufferStalledError', 
        'networkError+-+fragLoadTimeOut', 
        'mediaError+-+bufferNudgeOnStall', 
        'networkError+-+levelLoadError', 
        'VastInvalidResponseCodeException', 
        'mediaError+-+bufferFullError', 
        'networkError+-+manifestLoadError',
        'networkError+-+fragLoadError',
        'networkError+-+levelLoadTimeOut', 
        'mediaError+-+bufferSeekOverHole')
group by em, ttt
order by c desc
limit 100000


-----------------------------------

select 
    event_date as date, 
    geoip_region, 
    geoip_asn,
    count() as event,
    uniq(view_id) as view, 
    uniqIf(view_id, edge = 'salam-nsk-70.rutube.ru') as "salam-nsk-70",
    uniqIf(view_id, edge = 'salam-nsk-42.rutube.ru') as "salam-nsk-42",
    uniqIf(view_id, edge = 'salam-nsk-1042.rutube.ru') as "salam-nsk-1042",
    uniqIf(view_id, edge = 'salam-nsk-23.rutube.ru') as "salam-nsk-23",
    uniqIf(view_id, edge = 'salam-nsk-1023.rutube.ru') as "salam-nsk-1023"
from player.events 
where 
    event_date between '2025-03-06' - INTERVAL 13 DAY and '2025-03-06' + INTERVAL 13 DAY 
    and (edge = 'salam-nsk-70.rutube.ru' or edge = 'salam-nsk-42.rutube.ru' or edge = 'salam-nsk-1042.rutube.ru' or edge = 'salam-nsk-23.rutube.ru' or edge = 'salam-nsk-1023.rutube.ru') 
    and qw >= 1 and qh >= 1 and v >= 1 
    and geoip_region = 'Moscow'
group by 
    geoip_region, 
    event_date,
    geoip_asn
order by event desc 
limit 100000

SELECT 
    geoip_asn, 
    uniq(view_id) AS view 
FROM player.events
WHERE 
    IPv4NumToString(remote_addr) ILIKE '213.151.%' 
GROUP BY geoip_asn
ORDER BY view
LIMIT 100

        SELECT 
    CASE 
        -- Стандартные форматы
        WHEN (qw = 3840 AND qh = 2160) THEN '4K (3840x2160)'
        WHEN (qw = 2560 AND qh = 1440) THEN '2K (2560x1440)'
        WHEN (qw = 1920 AND qh = 1080) THEN 'Full HD (1920x1080)'
        WHEN (qw = 1280 AND qh = 720) THEN 'HD (1280x720)'
        WHEN (qw = 640 AND qh = 360) THEN 'nHD (640x360)'
        WHEN (qw = 480 AND qh = 360) THEN '480p (848x480)'
        
        -- Близкие к стандартным (±10%)
        WHEN (qw BETWEEN 3456 AND 4224 AND qh BETWEEN 1944 AND 2376) THEN '~4K'
        WHEN (qw BETWEEN 2304 AND 2816 AND qh BETWEEN 1296 AND 1584) THEN '~2K'
        WHEN (qw BETWEEN 1728 AND 2112 AND qh BETWEEN 972 AND 1188) THEN '~Full HD'
        WHEN (qw BETWEEN 1152 AND 1408 AND qh BETWEEN 648 AND 792) THEN '~HD'
        
        -- Специальные форматы
        WHEN (qw/qh BETWEEN 2.3 AND 2.5) THEN 'Ультраширокий (21:9)'
        WHEN (qw = qh) THEN 'Квадратные'
        WHEN (qh = 1080 AND qw BETWEEN 1800 AND 2100) THEN 'Full HD+ (широкие)'
        WHEN (qh = 720 AND qw BETWEEN 1200 AND 1400) THEN 'HD+ (широкие)'
        
        -- Группы по соотношению сторон
        WHEN (qw/qh BETWEEN 1.7 AND 1.8) THEN '16:9 вариации'
        WHEN (qw/qh BETWEEN 1.3 AND 1.4) THEN '4:3 вариации'
        WHEN (qw/qh BETWEEN 2.0 AND 2.2) THEN '18:9 вариации'
        
        -- Разрешения с нечетными размерами
        WHEN (qw % 8 = 0 AND qh % 8 = 0) THEN 'Оптимизированные (кратные 8)'
        WHEN (qw % 4 = 0 AND qh % 4 = 0) THEN 'Оптимизированные (кратные 4)'
        
        -- Остальные случаи
        ELSE CONCAT('Другое (', toString(qw), 'x', toString(qh), ')')
    END AS resolution_group,
    
    count() AS view_count,
    round(count() * 100.0 / sum(count()) OVER (), 2) AS percentage,
    groupArray(DISTINCT concat(toString(qw), 'x', toString(qh))) AS examples
FROM player.events
WHERE event_date = today() 
GROUP BY resolution_group
ORDER BY view_count DESC
