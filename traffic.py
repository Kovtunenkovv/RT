import pandas as pd
import os
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from datetime import datetime
from pathlib import Path

link = '/Users/vkovtunenko/Documents/DB percent/excel/'

def load_combined_files(pattern):
    all_files = []
    files = list(Path(link).glob(pattern))
    for file in files:
        try:
            if file.suffix == '.xlsx':
                df = pd.read_excel(file)
            else:
                df = pd.read_csv(file, sep=',', encoding='utf-8-sig')
            df['source_file'] = file.name
            all_files.append(df)
        except Exception as e:
            print(f"Ошибка при загрузке {file.name}: {str(e)}")
    return pd.concat(all_files, ignore_index=True) if all_files else pd.DataFrame()

df_views = load_combined_files('*player.events.xlsx')
df_traffic = load_combined_files('*grafana.csv')
df_cities = load_combined_files('*city.xlsx')

df_views = df_views[df_views.iloc[:, 1].notna() & (df_views.iloc[:, 1] != '')]
df_views.iloc[:, 0] = pd.to_datetime(df_views.iloc[:, 0])
df_traffic.iloc[:, 0] = pd.to_datetime(df_traffic.iloc[:, 0])

if not df_cities.empty:
    df_cities.iloc[:, 0] = pd.to_datetime(df_cities.iloc[:, 0])
    df_cities = df_cities.rename(columns={
        df_cities.columns[0]: 'ttt',
        df_cities.columns[1]: 'city',
        df_cities.columns[2]: 'city_view'
    })

merged = pd.merge(
    df_views,
    df_traffic,
    left_on=df_views.columns[0],
    right_on=df_traffic.columns[0],
    how='inner'
).drop(columns=[df_traffic.columns[0]])

merged["sum_view"] = merged.groupby(df_views.columns[0])[df_views.columns[2]].transform("sum")
merged["persent"] = (merged[df_views.columns[2]] / merged["sum_view"]) * 100
traffic_col = df_traffic.columns[1]
merged[traffic_col] = merged[traffic_col].str.replace(" Tb/s", "", regex=False).astype(float) * 1000  # Gb/s
merged["country_traff"] = (merged["persent"] / 100) * merged[traffic_col]

if not df_cities.empty:
    ru_data = merged[merged['geoip_country'] == 'RU']
    cities_merged = pd.merge(
        df_cities,
        ru_data[[df_views.columns[0], 'view', 'country_traff']],
        left_on='ttt',
        right_on=df_views.columns[0],
        how='left'
    )
    
    cities_merged = cities_merged.drop_duplicates(subset=['ttt', 'city'])
    
    cities_merged['view_percent'] = (cities_merged['city_view'] / cities_merged['view']) * 100
    cities_merged['city_traffic'] = (cities_merged['view_percent'] / 100) * cities_merged['country_traff']
    
    cities_merged['view_percent'] = cities_merged['view_percent'].round(2)
    cities_merged['city_traffic'] = cities_merged['city_traffic'].round(2)

    cities_output = cities_merged[['ttt', 'city', 'city_view', 'view_percent', 'city_traffic']]
    cities_output = cities_output.sort_values('ttt')   

output_excel = os.path.join(link, 'combined_results.xlsx')
with pd.ExcelWriter(output_excel, engine='openpyxl') as writer:
    merged.to_excel(writer, sheet_name='Country Data', index=False)
    if not df_cities.empty:
        cities_output.to_excel(writer, sheet_name='City Data', index=False)


start_date = merged[df_views.columns[0]].min()
last_day = merged[df_views.columns[0]].max()
last_day_data = merged[merged[df_views.columns[0]] == last_day]
all_data = merged.copy()

fig = make_subplots(
    rows=4, cols=1,
    subplot_titles=(
        f'Топ стран по трафику (Gb/s) за {last_day.date()}',
        f'Динамика трафика топ стран (Gb/s) (весь период)',
        f'Топ городов РФ по трафику (Gb/s) за {last_day.date()}',
        f'Динамика трафика топ городов РФ (Gb/s) (весь период)'
    ),
    vertical_spacing=0.12,
    specs=[[{"type": "bar"}], [{"type": "scatter"}], [{"type": "bar"}], [{"type": "scatter"}]]
)

colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd',
          '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf']

# 1. Топ стран по трафику за последний день
if not last_day_data.empty:
    top_countries = last_day_data.groupby('geoip_country')['country_traff'].sum().nlargest(18)
    top_countries_names = top_countries.index.tolist()
    
    fig.add_trace(
        go.Bar(
            x=top_countries.index,
            y=top_countries.values,
            marker_color='skyblue',
            text=[f'{x:.2f}' for x in top_countries.values],
            textposition='auto',
            showlegend=False
        ),
        row=1, col=1
    )

    # 2. Динамика трафика топ стран (весь период)
    top_all_data = all_data[all_data['geoip_country'].isin(top_countries_names)]
    dynamic_data = top_all_data.groupby([df_views.columns[0], 'geoip_country'])['country_traff'].sum().unstack()
    
    for i, country in enumerate(top_countries_names):
        if country in dynamic_data.columns:
            fig.add_trace(
                go.Scatter(
                    x=dynamic_data.index,
                    y=dynamic_data[country],
                    name=country,
                    line=dict(color=colors[i % len(colors)], width=2),
                    showlegend=True,
                    visible=True
                ),
                row=2, col=1
            )

# 3. Топ городов РФ по трафику за последний день
if not df_cities.empty:
    last_day_cities = cities_output[cities_output['ttt'] == last_day]
    if not last_day_cities.empty:
        top_cities = last_day_cities.groupby('city')['city_traffic'].sum().nlargest(20)
        top_cities_names = top_cities.index.tolist()
        
        fig.add_trace(
            go.Bar(
                x=top_cities.index,
                y=top_cities.values,
                marker_color='lightcoral',
                text=[f'{x:.2f}' for x in top_cities.values],
                textposition='auto',
                showlegend=False
            ),
            row=3, col=1
        )

        # 4. Динамика трафика топ городов РФ (весь период)
        all_cities_data = cities_output[cities_output['city'].isin(top_cities_names)]
        dynamic_cities_data = all_cities_data.groupby(['ttt', 'city'])['city_traffic'].sum().unstack()
        
        for i, city in enumerate(top_cities_names):
            if city in dynamic_cities_data.columns:
                fig.add_trace(
                    go.Scatter(
                        x=dynamic_cities_data.index,
                        y=dynamic_cities_data[city],
                        name=city,
                        line=dict(color=colors[i % len(colors)], width=2),
                        showlegend=True,
                        visible=True
                    ),
                    row=4, col=1
                )

fig.update_layout(
    height=1800,
    hovermode="x unified",
    margin=dict(t=60, b=80, l=60, r=150),
    legend=dict(
        title_text="Страны",
        orientation="v",
        yanchor="middle",
        y=0.72,
        xanchor="left",
        x=1.05,
        itemclick="toggle",
        itemdoubleclick="toggleothers"
    ),
    legend2=dict(
        title_text="Города",
        orientation="v",
        yanchor="middle",
        y=0.22,
        xanchor="left",
        x=1.05,
        itemclick="toggle",
        itemdoubleclick="toggleothers"
    )
)

fig.update_xaxes(
    rangeslider=dict(
        visible=True,
        thickness=0.05,
        yaxis=dict(rangemode="auto", range=[0, 0.9])
    ),
    row=2, col=1
)

fig.update_xaxes(
    rangeslider=dict(
        visible=True,
        thickness=0.05,
        yaxis=dict(rangemode="auto", range=[0, 0.9])
    ),
    row=4, col=1
)

initial_range_end = last_day
initial_range_start = last_day - pd.Timedelta(days=5)

fig.update_xaxes(
    range=[initial_range_start, initial_range_end],
    row=2, col=1
)

fig.update_xaxes(
    range=[initial_range_start, initial_range_end],
    row=4, col=1
)

fig.show()

if not last_day_data.empty:
    print("\nТоп стран по трафику за последний день:")
    print(top_countries.to_string(float_format="%.2f"))

if not df_cities.empty and not last_day_cities.empty:
    print("\nТоп городов РФ по трафику за последний день:")
    print(top_cities.to_string(float_format="%.2f"))
else:
    print("\nНет данных за последний день для анализа городов")
fig.write_html(os.path.join(link, 'traffic_visualization.html'))

"""
1. 202506 - city.xlsx
select 
    toStartOfHour(toDateTime64(ts, 3)) AS ttt,
    geoip_region,
    uniq(view_id) as view
from player.events
where 
    geoip_country = 'RU' and geoip_region != '' and qh >=1 and qw >=1
    and event_date >= '2025-07-01' and event_date < '2025-08-01' 
group by ttt, geoip_region
order by ttt

2. 202506 - player.events.xlsx
select 
    toStartOfHour(toDateTime64(ts, 3)) AS ttt,
    geoip_country,
    uniq(view_id) as view
from player.events
where 
    geoip_country != '' and geoip_region != '' and qh >=1 and qw >=1
    and event_date >= '2025-07-01' and event_date < '2025-08-01' 
group by ttt, geoip_country
order by ttt

3. 202506 - grafana.csv
Data trafic from grafana dashbord "Salam Network True" to scv
"""
