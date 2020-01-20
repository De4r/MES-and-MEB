import matplotlib.pyplot as plt
import pandas as pd
from matplotlib import style, rc
style.use('seaborn-bright')

#################################################### 1 pomiar! ###########################################
# Parametry:
# T_ot = 22 [C]
# Napięcie 6,2 [V]
# Natęzenie: 3 [A], 2.6 [A] od 700 s
label_size = 20
title_size = 28
legend_size = 16
filename = '19-12-2019_10_22_24_LOGS_DS18B20_pomiar1.csv'

df = pd.read_csv(filename)


df['Time'] = round(df['Time'], 2)
print(df.head())

fig = plt.figure()

for col in df.columns[1::]:
    col1, col2 = col.split('_')
    col_n = col1 +'_{' + col2 + '}'
    # print(col_n)
    l = r'${}$'.format(col_n)
    ax = plt.plot(df[df.columns[0]], df[col], label=l)

plt.xticks(fontsize=14, rotation=45)
plt.yticks(fontsize=14)
plt.grid()
plt.title(r'$Dane\ pomiarowe\ nr\ 1$', fontsize=title_size)
plt.xlabel(r'$Czas\ [s]$', fontsize=label_size)
plt.ylabel(r'$Temperatura\ [\degree C]$', fontsize=label_size)
plt.legend(fontsize=legend_size)
plt.show(block=False)

fig2 = plt.figure()
i = df.loc[df['Time'] > 1250].index.values[0]
for col in df.columns[1::]:
    col1, col2 = col.split('_')
    col_n = col1 +'_{' + col2 + '}'
    # print(col_n)
    l = r'${}$'.format(col_n)
    ax = plt.plot(df[df.columns[0]][i:], df[col][i:], label=l)

plt.xticks(fontsize=14, rotation=45)
plt.yticks(fontsize=14)
plt.grid()
plt.title(r'$Ustalony\ przebieg\ temperatur\ dla\ pomiaru\ 1$', fontsize=title_size)
plt.xlabel(r'$Czas\ [s]$', fontsize=label_size)
plt.ylabel(r'$Temperatura\ [\degree C]$', fontsize=label_size)
plt.legend(fontsize=legend_size)
plt.show(block=False)



# usredniania

df_mean = df.copy(deep = True)
print(df_mean[['T_6', 'T_8', 'T_10']][i:].mean())
print(df_mean[['T_5', 'T_3', 'T_1']][i:].mean())
print(df_mean[['T_15', 'T_13', 'T_11']][i:].mean())
df_mean[df_mean.columns[1:17]] = df_mean[df_mean.columns[1:17]].rolling(window=25, center=True, min_periods=1).mean()
df_mean[df_mean.columns[-1]] = df_mean[df_mean.columns[-1]].rolling(window=50, center=True, min_periods=1).mean()
# df_mean.loc[df_mean['Time'] > 50, df_mean.columns[-1]] = df_mean.loc[df_mean['Time'] > 50, df_mean.columns[-1]].rolling(window=50, center=True, min_periods=1).mean()
fig3 = plt.figure()

for col in df_mean.columns[1::]:
    col1, col2 = col.split('_')
    col_n = col1 +'_{' + col2 + '}'
    # print(col_n)
    l = r'${}$'.format(col_n)
    ax = plt.plot(df_mean[df_mean.columns[0]], df_mean[col], label=l)

plt.xticks(fontsize=14, rotation=45)
plt.yticks(fontsize=14)
plt.grid()
plt.title(r'$Dane\ pomiarowe\ po\ wygładzeniu\ średnią\ ruchomą$', fontsize=title_size)
plt.xlabel(r'$Czas\ [s]$', fontsize=label_size)
plt.ylabel(r'$Temperatura\ [\degree C]$', fontsize=label_size)
plt.legend(fontsize=legend_size)
plt.show(block=False)



fig4 = plt.figure()

cols = ['T_6', 'T_c']

for col in cols:
    # temp T_c i T_6
    col1, col2 = col.split('_')
    col_n = col1 +'_{' + col2 + '}'
    # print(col_n)
    l = r'${}$'.format(col_n)
    ax1 = plt.plot(df_mean[df_mean.columns[0]], df_mean[col], label=l)

# obliczenie dT z przebiegu plus wykres
df_mean['dT'] = df_mean[cols[0]] - df_mean[cols[-1]]
# df_mean.loc[df_mean['Time'] > 50, df_mean.columns[-1]] = df_mean.loc[df_mean['Time'] > 50, df_mean.columns[-1]].rolling(window=100, center=True, min_periods=1).mean()
ax1 = plt.plot(df_mean[df_mean.columns[0]], df_mean[df_mean.columns[-1]], label=r'${}$'.format(df_mean.columns[-1]))

plt.xticks(fontsize=14, rotation=45)
plt.yticks(fontsize=14)
plt.title(r'$Dane\ pomiarowe\ dla\ modułu\ Peltiera\ w\ pomiarze\ 1$', fontsize=title_size)
plt.xlabel(r'$Czas\ [s]$', fontsize=label_size)
plt.ylabel(r'$Temperatura\ [\degree C]$', fontsize=label_size)
plt.legend(fontsize=legend_size)
plt.grid()
plt.show()

i = df.loc[df_mean['Time'] > 400].index.values[0]
print('Średnia rożnica temperatury modulu dla ustalonej pracy: ', round(df_mean[df_mean.columns[-1]][i:].mean(), 2))
print('Średnia temperatura otoczenia podczas pomiaru: ', round(df[df.columns[-2]].mean(), 2))
# print(df.loc[0, df.columns[1:16]].to_numpy())
print('Średnia temperatura plytki w chwili startu podczas pomiaru: ', round(df.loc[0, df.columns[1:16]].mean(), 2))