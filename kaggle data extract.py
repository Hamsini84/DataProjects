import kaggle
"kaggle datasets download ankitbansal06/retail-orders -f orders.csv " # this in ran in the terminal , command copied from kaggle CLI in the web page"

import zipfile
zip_ref = zipfile.ZipFile('retail-orders.zip') #to unzip the file 
zip_ref.extractall('/Users/vbsbmhamsinikanuru/Desktop/Data Work/kaggle python sql') #to extarct file in your desired location
zip_ref.close() # close file

# from the values we have , need to return/ consider Not Avaliable , unknown , nan as Null or na_values
import pandas as pd
df = pd.read_csv('orders.csv',na_values = ['Not Available','unknown'])
pf = df['Ship Mode'].unique()
#print (df) 

# to rename all the columns , make it lowercasse and add '_'
columns = df.columns.str.lower()
columns = df.columns.str.replace(' ','_')
#print(columns)

# to get the list of all columns
k = list(df.columns)
#print (k)


# to add the above calculation as new columns in thhe file and Overwrites the original file
df['discount'] = df['List Price']*df['Discount Percent']*0.01
df['sale_price'] = df['List Price']- df['discount']
df['Profit'] = df['sale_price'] - df['cost price']
df.to_csv("orders.csv", index=False)  # this is used to add these new columns in csv file


# to change the data typt and get the data types of all the columns 
df['Order Date'] = pd.to_datetime(df['Order Date'],format="%Y-%m-%d")
#print(df.dtypes) 

#to drop columns not required from the file
df.drop(columns=['List Price','cost price','Discount Percent'],inplace=True)
df.to_csv("orders.csv", index=False)  

#to load data into sqlite
import sqlite3
conn = sqlite3.connect("practiseDB.db") 
df.to_sql("orders_table", conn, if_exists="replace", index=False) # this is used to load the data into sql 
conn.close()
print("Data loaded successfully into SQLite!")
