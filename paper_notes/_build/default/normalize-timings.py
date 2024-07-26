#!/usr/bin/env python
import pandas as pd

timings = pd.read_csv("timings.csv", index_col='benchmark')
non_error_columns = list(filter(lambda c: not c.endswith('err'), timings.columns))
timings = (timings.divide(timings[non_error_columns].min(axis='columns'), axis='rows'))
timings.round(decimals=2).to_csv("timings_normalized.csv", index=True)