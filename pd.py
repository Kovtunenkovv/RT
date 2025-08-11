# Simple time series plot using matplotlib

import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime

data = {
    'Datetime': ['01.07.2025', '02.07.2025', '03.07.2025', '04.07.2025','05.07.2025', '06.07.2025'],
    'line1': [8, 4, 8, 8, 8, 6],
    'line2': [7, 7, 7, 7, 7, 7],
    'line3': [5, 4, 3, 4, 5, 6],
    'line4': [4, 2, 4, 4, 4, 2],
    'line5': [1, 2, 1, 2, 1, 2]
    }

for key in data:
    print(f"Length of {key}: {len(data[key])}")

df = pd.DataFrame(data)

df['Datetime'] = pd.to_datetime(df['Datetime'], format='%d.%m.%Y')  #format='%Y-%m-%d %H:%M:%S'

plt.figure(figsize=(15, 8))

plt.plot(df['Datetime'], df['line1'], label='line1', linewidth=2)
plt.plot(df['Datetime'], df['line2'], label='line2', linewidth=2)
plt.plot(df['Datetime'], df['line3'], label='line3', linewidth=2)
plt.plot(df['Datetime'], df['line4'], label='line4', linewidth=2)
plt.plot(df['Datetime'], df['line5'], label='line5', linewidth=2)

plt.title('This is title', fontsize=16, pad=20)
plt.xlabel('Date', fontsize=12)
plt.ylabel('Count', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend(fontsize=10)
#plt.xticks(rotation=45)

plt.tight_layout()

plt.show()
