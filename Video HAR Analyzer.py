import json
import os
import pandas as pd
from datetime import datetime
import re

HAR_DIR = "/Users//Documents/har"
current_time = datetime.now()
output_excel = current_time.strftime("%Y%m%d_%H-%M") + "_video_analysis.xlsx"

def parse_time(timestamp):
    return datetime.fromisoformat(timestamp.replace('Z', '+00:00'))

def detect_connection_type(filename):
    if 'lte' in filename.lower():
        return 'LTE'
    return 'Regular'

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
        'video_request': None,
        'manifest': None,
        'first_segment': None,
        'segments': [],
        'manifests': [] 
    }

    patterns = {                                                                   # Показатели условные - открыт к предложениям для корректировки
        'YouTube': {
            'click': r'\.youtube\.com/youtubei/v./player\?prettyPrint=false.*',
            'video_request': r'youtube\.com/api/timedtext',
            'manifest': r'\.youtube\.com/youtubei/v./player\?prettyPrint=false.*', # Не нашел использование такого значение как manifest - при подсчете выводится 0
            'segment': r'googlevideo\.com/videoplayback'
        },
        'RuTube': {
            'click': r'rutube.ru/api/play/options',
            'video_request': r'bl\.rutube\.ru/.*\.m3u8',
            'manifest': r'(?:river|salam)-.*\.rtbcdn\.ru/.*\.m3u8',
            'segment': r'segment-\d+-v\d+-a\d+\.ts'
        },
        'VK Video': {
            'click': r'vkvideo.ru/al_video.php$',
            'video_request': r'\.okcdn\.ru\/.*ct=6',
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
            
            if events['click'] and not events['video_request'] and re.search(patterns[platform]['video_request'], url, re.IGNORECASE):
                events['video_request'] = start_time
            
            if events['click'] and re.search(patterns[platform]['manifest'], url, re.IGNORECASE):
                events['manifests'].append({
                    'time': start_time,
                    'size': response_size,
                    'duration': time_ms
                })
                if not events['manifest']:
                    events['manifest'] = start_time

            if events['click'] and re.search(patterns[platform]['segment'], url, re.IGNORECASE):
                events['segments'].append({
                    'time': start_time,
                    'size': response_size,
                    'duration': time_ms
                })
                if not events['first_segment']:
                    events['first_segment'] = start_time
        except Exception as e:
            print(f"Ошибка обработки записи в файле {file_name}: {str(e)}")
            continue

    required_events = ['click', 'video_request', 'manifest', 'first_segment']
    if not all(events[event] for event in required_events):
        print(f"Не хватает данных для анализа в файле {file_name}")
        return None

    click_time = events['click']
    intervals = {
        'click_to_video_request': (events['video_request'] - click_time).total_seconds() * 1000,
        'click_to_manifest': (events['manifest'] - click_time).total_seconds() * 1000,
        'click_to_first_segment': (events['first_segment'] - click_time).total_seconds() * 1000
    }

    segment_stats = {
        'count': len(events['segments']),
        'total_size': sum(s['size'] for s in events['segments']),
        'total_time': sum(s['duration'] for s in events['segments']),
        'avg_time': sum(s['duration'] for s in events['segments']) / len(events['segments']) if events['segments'] else 0,
        'avg_speed': (sum(s['size'] for s in events['segments']) / (sum(s['duration'] for s in events['segments']) / 1000)) / 1_000_000 
                    if events['segments'] and sum(s['duration'] for s in events['segments']) > 0 else 0
    }
    
    return {
        'File Name': file_name,
        'Platform': platform,
        'Connection Type': detect_connection_type(file_name),

        'Click to Video Request (ms)': round(intervals['click_to_video_request'], 2),
        'Click to Manifest (ms)': round(intervals['click_to_manifest'], 2),
        'Click to First Segment (ms)': round(intervals['click_to_first_segment'], 2),

        'Segment Count': segment_stats['count'],
        'Total Segment Size (MB)': round(segment_stats['total_size'] / 1_000_000, 2),
        'Avg Segment Size (KB)': round((segment_stats['total_size'] / segment_stats['count']) / 1_000, 2) if segment_stats['count'] > 0 else 0,
        'Avg Segment Time (ms)': round(segment_stats['avg_time'], 2),
        'Avg Segment Speed (Mb/s)': round(segment_stats['avg_speed'], 2)
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
        print("Не найдено подходящих HAR-файлов")
        return

    df = pd.DataFrame(results)

    columns_order = [
        'File Name', 
        'Platform', 
        'Connection Type',
        'Click to Video Request (ms)', 
        'Click to Manifest (ms)', 
        'Click to First Segment (ms)',
        'Segment Count',
        'Total Segment Size (MB)', 
        'Avg Segment Size (KB)',
        'Avg Segment Time (ms)',
        'Avg Segment Speed (Mb/s)'
    ]
    df = df[columns_order]

    with pd.ExcelWriter(output_excel, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='All Data', index=False)
        for platform in df['Platform'].unique():
            platform_df = df[df['Platform'] == platform]
            platform_df.to_excel(writer, sheet_name=f'{platform} Data', index=False)
        pivot = df.pivot_table(
            index=['Platform', 'Connection Type'],
            values=[
                'Click to Video Request (ms)',
                'Click to Manifest (ms)',
                'Click to First Segment (ms)',
                'Avg Segment Speed (Mb/s)'
            ],
            aggfunc=['mean', 'median', 'min', 'max']
        )
        pivot.to_excel(writer, sheet_name='Platform Comparison')
      
    print(' ')
    print(f"Анализ завершен. Обработано файлов: {processed_files}")
    print(f"Результаты сохранены в {output_excel}")

if __name__ == '__main__':
    main()
