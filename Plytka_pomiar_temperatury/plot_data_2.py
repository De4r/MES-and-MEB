import matplotlib.pyplot as plt
import pandas as pd



#################################################### 2 pomiar! ###########################################
# Parametry:
# T_ot = 22 [C]
# Napięcie 8 [V]
# Natęzenie: t[s] [A]
# 0-100s 4
# 100-140 3.9
# 140-200 3.8
# 200-250 3.7
# 250-270 3.6
# 270-440 3.5
# 440-530 3.4
# 530-750 3.35
# 750-end 3.3

filename = '19-12-2019_11_07_39_LOGS_DS18B20_pomiar2.csv'

df = pd.read_csv(filename)


df['Time'] = round(df['Time'], 2)
print(df.head())

fig3 = plt.figure()

for col in df.columns[1::]:
    ax = plt.plot(df[df.columns[0]], df[col], label=col)

plt.grid()
plt.title('Przebieg czasowy tempratury w punktach pomiarowych dla pomiaru 2')
plt.xlabel('Czas [s]')
plt.ylabel('Temperatura [st. C]')
plt.legend()
plt.show(block=False)

fig4 = plt.figure()

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

plt.title(f'Przebieg czasowy tempratury modulu peltiera dla pomiaru 2')
plt.xlabel('Czas [s]')
plt.ylabel('Temperatura [st. C]')
plt.legend()
plt.grid()
plt.show()

i = df.loc[df['Time'] > 300].index.values[0]
print('Średnia rożnica temperatury modulu dla ustalonej pracy: ', round(df[df.columns[-1]][i:].mean(), 2))
print('Średnia temperatura otoczenia podczas pomiaru: ', round(df['T_ot'].mean(), 2))
# print(df.loc[0, df.columns[1:16]].to_numpy())
print('Średnia temperatura plytki w chwili startu podczas pomiaru: ', round(df.loc[0, df.columns[1:16]].mean(), 2))
# filename = '19-12-2019_11_21_05_LOGS_DS18B20_chlodzenie.csv'