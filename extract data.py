
# import kaggle
"kaggle datasets download shivamb/netflix-shows " # this in ran in the terminal , command copied from kaggle CLI in the web page"

import zipfile
zip_ref = zipfile.ZipFile('netflix-shows.zip') #to unzip the file 
zip_ref.extractall('/Users/vbsbmhamsinikanuru/Desktop/Data Work/netflix ELT') #to extarct file in your desired location
zip_ref.close() # close file

# from the values we have , need to return/ consider Not Avaliable , unknown , nan as Null or na_values
import pandas as pd
df = pd.read_csv('netflix_titles.csv')
#print (df) 

#to load data into sqlite
import sqlite3
conn = sqlite3.connect("netflixproject.db") 
df.to_sql("netflix_raw", conn, if_exists="replace", index=False) # this is used to load the data into sql 
conn.close()
print("Data loaded successfully into SQLite!")
