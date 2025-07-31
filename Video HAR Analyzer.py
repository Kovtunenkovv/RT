import json
import os
import pandas as pd
from datetime import datetime
import re

HAR_DIR = "/Users/user/Documents/har"
current_time = datetime.now()
output_excel = current_time.strftime("%Y%m%d_%H-%M") + "_video_analysis.xlsx"

def parse_time(timestamp):
    return datetime.fromisoformat(timestamp.replace('Z', '+00:00'))

def analyze_har_file(file_path, file_name):
    with open(file_path, 'r', encoding='utf-8') as f:
        try:
            har_data = json.load(f)
        except json.JSONDecodeError:
            print(f"Ошибка чтения файла {file_name}")
            return None

    platform = None
    for entry in har_data['log']['entries']:
        url = entry['request']['url']
        if 'rutube.ru' in url:
            platform = 'RuTube'
            break
        elif 'okcdn.ru' in url or 'vkvideo.ru' in url:
            platform = 'VK Video'
            break
        elif 'googlevideo.com' in url or 'youtube.com' in url:
            platform = 'YouTube'
            break
    
    if not platform:
        print(f"Не удалось определить платформу для файла {file_name}")
        return None

    events = {
        'click': None,
        'manifest': None,
        'first_segment': None,
        'segments': [],
        'unique_segment_urls': set(),
        'manifests': [] 
    }

    patterns = {
        'YouTube': {
            'click': r'\.youtube\.com/youtubei/v./player\?prettyPrint=false.*',
            'manifest': r'\.youtube\.com/youtubei/v./player\?prettyPrint=false.*',
            'segment': r'googlevideo\.com/videoplayback'
        },
        'RuTube': {
            'click': r'rutube.ru/api/play/options',
            'manifest': r'(?:river|salam)-.*\.rtbcdn\.ru/.*\.m3u8',
            'segment': r'segment-\d+-v\d+-a\d+\.ts'
        },
        'VK Video': {
            'click': r'vkvideo.ru/al_video.php$',
            'manifest': r'act=video_view_started',
            'segment': r'\.okcdn\.ru\/.*ct=(11|21|32)' 
        }
    }

    for entry in har_data['log']['entries']:
        try:
            url = entry['request']['url']
            start_time = parse_time(entry['startedDateTime'])
            response_size = entry.get('response', {}).get('content', {}).get('size', 0)
            time_ms = entry.get('time', 0)

            if not events['click'] and re.search(patterns[platform]['click'], url, re.IGNORECASE):
                events['click'] = start_time

            if events['click'] and re.search(patterns[platform]['manifest'], url, re.IGNORECASE):
                events['manifests'].append({
                    'time': start_time,
                    'size': response_size,
                    'duration': time_ms
                })
                if not events['manifest']:
                    events['manifest'] = start_time

            if events['click'] and re.search(patterns[platform]['segment'], url, re.IGNORECASE):
                segment_size_kb = response_size / 1024 if response_size > 0 else 0
                if segment_size_kb > 1:
                    events['unique_segment_urls'].add(url)
                    segment_speed = (response_size / (time_ms / 1000)) / 1_000_000 if time_ms > 0 else 0
                    events['segments'].append({
                        'time': start_time,
                        'size': response_size,
                        'size_kb': segment_size_kb,
                        'duration': time_ms,
                        'speed': segment_speed
                    })
                    if not events['first_segment']:
                        events['first_segment'] = start_time
        except Exception as e:
            print(f"Ошибка обработки записи в файле {file_name}: {str(e)}")
            continue

    required_events = ['click', 'manifest', 'first_segment']
    if not all(events[event] for event in required_events):
        print(f"Не хватает данных для анализа в файле {file_name}")
        if not events['click']:
            print(f"В файле {file_name} не найден клик")
        if not events['manifest']:
            print(f"В файле {file_name} не найден манифест")
        if not events['first_segment']:
            print(f"В файле {file_name} не найден первый сегмент")
        return None

    click_time = events['click']
    intervals = {
        'click_to_manifest': (events['manifest'] - click_time).total_seconds() * 1000,
        'click_to_first_segment': (events['first_segment'] - click_time).total_seconds() * 1000
    }

    watch_duration = 0
    if events['segments']:
        last_segment_time = max(s['time'] for s in events['segments'])
        watch_duration = (last_segment_time - click_time).total_seconds()

    if events['segments']:
        segment_sizes = [s['size_kb'] for s in events['segments']]
        segment_times = [s['duration'] for s in events['segments']]
        segment_speeds = [s['speed'] for s in events['segments']]
        
        segment_stats = {
            'count': len(events['segments']),
            'unique_count': len(events['unique_segment_urls']),
            'total_size': sum(s['size'] for s in events['segments']),
            'total_time': sum(segment_times),
            'avg_time': sum(segment_times) / len(segment_times),
            'avg_speed': sum(segment_speeds) / len(segment_speeds),
            'min_size': min(segment_sizes),
            'max_size': max(segment_sizes),
            'min_time': min(segment_times),
            'max_time': max(segment_times),
            'min_speed': min(segment_speeds),
            'max_speed': max(segment_speeds)
        }
    else:
        segment_stats = {
            'count': 0,
            'unique_count': 0,
            'total_size': 0,
            'total_time': 0,
            'avg_time': 0,
            'avg_speed': 0,
            'min_size': 0,
            'max_size': 0,
            'min_time': 0,
            'max_time': 0,
            'min_speed': 0,
            'max_speed': 0
        }
    
    return {
        'File Name': file_name,
        'Platform': platform,
        'Click to Manifest (ms)': round(intervals['click_to_manifest'], 2),
        'Click to First Segment (ms)': round(intervals['click_to_first_segment'], 2),
        'Duration (s)': round(watch_duration, 2),
        'Segment Count': segment_stats['count'],
        'Unique Segment Count': segment_stats['unique_count'],
        'Total Segment Size (MB)': round(segment_stats['total_size'] / 1_000_000, 2),
        'Avg Segment Size (KB)': round(segment_stats['total_size'] / segment_stats['count'] / 1_000, 2) if segment_stats['count'] > 0 else 0,
        'Min Segment Size (KB)': round(segment_stats['min_size'], 2),
        'Max Segment Size (KB)': round(segment_stats['max_size'], 2),
        'Avg Segment Time (ms)': round(segment_stats['avg_time'], 2),
        'Min Segment Time (ms)': round(segment_stats['min_time'], 2),
        'Max Segment Time (ms)': round(segment_stats['max_time'], 2),
        'Avg Segment Speed (Mb/s)': round(segment_stats['avg_speed'], 2),
        'Min Segment Speed (Mb/s)': round(segment_stats['min_speed'], 2),
        'Max Segment Speed (Mb/s)': round(segment_stats['max_speed'], 2)
    }

def main():
    results = []
    processed_files = 0
    
    for file_name in os.listdir(HAR_DIR):
        if file_name.endswith('.har'):
            print(f"Обработка файла: {file_name}")
            file_path = os.path.join(HAR_DIR, file_name)
            result = analyze_har_file(file_path, file_name)
            if result:
                results.append(result)
                processed_files += 1
    
    if not results:
        print("Не найдено подходящих HAR-файлов для анализа")
        return

    df = pd.DataFrame(results)
    columns_order = [
        'File Name', 
        'Platform', 
        'Click to Manifest (ms)', 
        'Click to First Segment (ms)',
        'Duration (s)',
        'Segment Count',
        'Unique Segment Count',
        'Total Segment Size (MB)', 
        'Avg Segment Size (KB)',
        'Min Segment Size (KB)',
        'Max Segment Size (KB)',
        'Avg Segment Time (ms)',
        'Min Segment Time (ms)',
        'Max Segment Time (ms)',
        'Avg Segment Speed (Mb/s)',
        'Min Segment Speed (Mb/s)',
        'Max Segment Speed (Mb/s)'
    ]
    df = df[columns_order]
    
    with pd.ExcelWriter(output_excel, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='All Data', index=False)
   
    print(f"\nАнализ завершен. Обработано файлов: {processed_files}")
    print(f"Результаты сохранены в {output_excel}")

if __name__ == '__main__':
    main()
