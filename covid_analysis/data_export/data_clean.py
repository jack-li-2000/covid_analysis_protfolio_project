import pandas as pd

inf_rate = pd.read_csv('inf_rate.csv')
inf_rate.fillna(0, inplace=True)

inf_date = pd.read_csv('inf_rate_date.csv')
inf_date.fillna(0, inplace=True)