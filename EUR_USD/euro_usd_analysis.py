import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('TkAgg')

if __name__ == "__main__":
    df = pd.read_csv("DEXUSEU.csv",  parse_dates=['DATE'])

    """ some cleaning"""
    df = df.rename(columns = {"DATE": "date", "DEXUSEU": "EUR/USD"})
    sns.lineplot(data=df, x="date", y="EUR/USD")
    plt.show()
    print("hello world")





