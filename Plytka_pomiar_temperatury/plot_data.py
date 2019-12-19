import matplotlib.pyplot as plt
import pandas as pd
import csv

filename = '19-12-2019_10_22_24_LOGS_DS18B20_pomiar1.csv'
# filename ='19-12-2019_11_07_39_LOGS_DS18B20_pomiar2.csv'

df = pd.read_csv(filename)


df['Time'] = round(df['Time'], 2)
print(df.head())

fig = plt.figure()

for col in df.columns[1::]:
    ax = plt.plot(df[df.columns[0]], df[col], label=col)

plt.grid()
plt.title('Przebieg czasowy tempratury w punktach pomiarowych')
plt.xlabel('Czas [s]')
plt.ylabel('Temperatura [st. C]')
plt.legend()
plt.show(block=False)

fig2 = plt.figure()

cols = ['T_6', 'T_c']

for col in cols:
    # temp T_c i T_6
    ax1 = plt.plot(df[df.columns[0]], df[col], label=col)

# obliczenie dT z przebiegu plus wykres
df['dT'] = df[cols[0]] - df[cols[-1]]
ax1 = plt.plot(df[df.columns[0]], df[df.columns[-1]], label=df.columns[-1])

# wykres usrednionego przebgiegu T_c
ax1 = plt.plot(df[df.columns[0]], df[df.columns[-2]].rolling(window=20,
                                                             center=True, min_periods=1).mean(), label='Srednia T_c')

# obliczenie przebiegu T_h - T_c.srednia
df['dT'] = df[cols[0]] - df[cols[-1]
                            ].rolling(window=20, center=True, min_periods=1).mean()

ax1 = plt.plot(df[df.columns[0]], df[df.columns[-1]], label='dT=T_h-MA(T_c)')

ax1 = plt.plot(df[df.columns[0]], df[df.columns[-1]].rolling(window=20,
                                                             center=True, min_periods=1).mean(), label='dT=MA(dT T_h-MA(T_c))')

plt.title('Przebieg czasowy tempratury moduly peltiera')
plt.xlabel('Czas [s]')
plt.ylabel('Temperatura [st. C]')
plt.legend()
plt.grid()
plt.show()
