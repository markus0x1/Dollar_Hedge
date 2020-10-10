import pandas as pd


if __name__ == "__main__":
    df = pd.read_csv("DEXUSEU.csv",  parse_dates=['DATE'])

    """ some cleaning"""
    df = df.rename(columns = {"DATE": "date", "DEXUSEU": "value"})
    is_missing = df["value"]=="."
    df.loc[is_missing, "value"] == NaN

    print("hello world")




