import matplotlib.pyplot as plt
import pandas as pd
import csv

filename ='10-12-2019_19_48_27_LOGS_DS18B20.csv'

df = pd.read_csv(filename)


df['Time'] = round(df['Time'], 2)
print(df.head)

fig = plt.figure()

for col in df.columns[1::]:
    ax = plt.plot(df[df.columns[0]], df[col], label=col)

plt.grid()
plt.title('Wstępny pomiar, U=11,7[V], A=13[A]')
plt.xlabel('Czas [s]')
plt.ylabel('Temperatura [st. C]')
plt.legend()
plt.show()