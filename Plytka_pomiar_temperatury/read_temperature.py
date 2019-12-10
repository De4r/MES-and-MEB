import datetime
import os
import csv
import serial
import time
import numpy as np

""" 
Skrypt odczytujący dane z portu seryjnego
Domyślnie ustawienia to:
serial_port - COM3 (dla windows) - port szeregowy
baud_rate - 9600 buad - predkość przesyłu danych
Skrypt generuje plik csv z pomiarami z czujnikow
 """


class serialRead():
    def __init__(self, sensor='DS18B20', serial_port='COM4',
                 baud_rate='115200', sen_num=17):
        self.sensor = sensor
        self.serial_port = serial_port
        self.baud_rate = baud_rate
        self.sen_num = sen_num
        now = datetime.datetime.now()
        self.path = f'{now.strftime("%d-%m-%Y_%H_%M_%S")}_LOGS_{self.sensor}.csv'
        self.header = ['Time']

        for i in range(1, sen_num-1):
            self.header.append(f'T_{i}')
        self.header.append('T_ot')
        print(f'Ustawiono: {self.baud_rate}, {self.serial_port}, {self.sensor}, {self.sen_num}')
        print(self.header)

    def start(self):
        ser = serial.Serial()
        ser.baudrate = self.baud_rate
        ser.port = self.serial_port

        ser.open()
        dataBuffer = np.zeros(self.sen_num)
        time_start = time.time()
        print('Serial status: ', ser.is_open)

        with open(self.path, mode='w', newline='') as csvFile:
            writer = csv.DictWriter(csvFile, fieldnames=self.header)
            writer.writeheader()
        # ser.write(b'start')
        print('Start')
        while True:
            line = ser.readline()
            line = line.decode('utf-8')

            dataBuffer[1::] = [float(temperature)
                               for temperature in line.split(",")]

            dataBuffer[0] = time.time() - time_start
            print(dataBuffer)

            with open(self.path, mode='a', newline='') as csvFile:
                writer = csv.DictWriter(csvFile, fieldnames=self.header)

                writer.writerow({self.header[i]: dataBuffer[i]
                                 for i in range(len(dataBuffer))})


if __name__ == "__main__":
    print("Odczyt danych z portu szeregowego, włącz skrypt do szukania adresów bądz zrestartuj Arduino Nano z wgranym skryptem")
    s = serialRead(serial_port='COM4')
    s.start()
