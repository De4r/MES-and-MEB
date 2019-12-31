import matplotlib.pyplot as plt
import pandas as pd


filename = '19-12-2019_10_22_24_LOGS_DS18B20_pomiar1.csv'

df = pd.read_csv(filename)


df['Time'] = round(df['Time'], 2)
print(df.head())

fig = plt.figure()

for col in df.columns[1::]:
    ax = plt.plot(df[df.columns[0]], df[col], label=col)

plt.grid()
plt.title('Przebieg czasowy tempratury w punktach pomiarowych dla pomiaru 1')
plt.xlabel('Czas [s]')
plt.ylabel('Temperatura [st. C]')
plt.legend()
plt.show(block=False)

fig2 = plt.figure()
i = df.loc[df['Time'] > 1250].index.values[0]
for col in df.columns[1::]:
    ax = plt.plot(df[df.columns[0]][i:], df[col][i:], label=col)

plt.grid()
plt.title('Ustalony przebieg temperatury dla pomiaru 1')
plt.xlabel('Czas [s]')
plt.ylabel('Temperatura [st. C]')
plt.legend()
plt.show(block=False)



# usredniania

df_mean = df.copy(deep = True)
df_mean[df_mean.columns[1:17]] = df_mean[df_mean.columns[1:17]].rolling(window=25, center=True, min_periods=1).mean()
df_mean[df_mean.columns[-1]] = df_mean[df_mean.columns[-1]].rolling(window=50, center=True, min_periods=1).mean()
# df_mean.loc[df_mean['Time'] > 50, df_mean.columns[-1]] = df_mean.loc[df_mean['Time'] > 50, df_mean.columns[-1]].rolling(window=50, center=True, min_periods=1).mean()
fig3 = plt.figure()

for col in df_mean.columns[1::]:
    ax = plt.plot(df_mean[df_mean.columns[0]], df_mean[col], label=col)

plt.grid()
plt.title('Przebieg czasowy tempratury w punktach pomiarowych dla pomiaru 1 po wygladzeniu przebiegow')
plt.xlabel('Czas [s]')
plt.ylabel('Temperatura [st. C]')
plt.legend()
plt.show(block=False)


fig4 = plt.figure()

cols = ['T_6', 'T_c']

for col in cols:
    # temp T_c i T_6
    ax1 = plt.plot(df_mean[df_mean.columns[0]], df_mean[col], label=col)

# obliczenie dT z przebiegu plus wykres
df_mean['dT'] = df_mean[cols[0]] - df_mean[cols[-1]]
# df_mean.loc[df_mean['Time'] > 50, df_mean.columns[-1]] = df_mean.loc[df_mean['Time'] > 50, df_mean.columns[-1]].rolling(window=100, center=True, min_periods=1).mean()
ax1 = plt.plot(df_mean[df_mean.columns[0]], df_mean[df_mean.columns[-1]], label=df_mean.columns[-1])

plt.title(f'Przebieg czasowy tempratur modulu peltiera dla pomiaru 1')
plt.xlabel('Czas [s]')
plt.ylabel('Temperatura [st. C]')
plt.legend()
plt.grid()
plt.show()

i = df.loc[df_mean['Time'] > 400].index.values[0]
print('Średnia rożnica temperatury modulu dla ustalonej pracy: ', round(df_mean[df_mean.columns[-1]][i:].mean(), 2))
print('Średnia temperatura otoczenia podczas pomiaru: ', round(df[df.columns[-2]].mean(), 2))
# print(df.loc[0, df.columns[1:16]].to_numpy())
print('Średnia temperatura plytki w chwilis startu podczas pomiaru: ', round(df.loc[0, df.columns[1:16]].mean(), 2))