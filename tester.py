
# coding: utf-8

# # Check `GDS` stack
# 
# This notebook checks all software requirements for the course Geographic Data Science are correctly installed. 
# 
# A successful run of the notebook implies no errors returned in any cell *and* every cell beyond the first one returning a printout of `True`. This ensures a correct environment installed.

# ---

# In[1]:

import bokeh as bk
print(float(bk.__version__[:4]) >= 0.12)


# In[2]:

import matplotlib as mpl
print(float(mpl.__version__[:3]) >= 1.5)


# In[3]:

import mplleaflet as mpll


# In[4]:

import seaborn as sns
print(float(sns.__version__[:3]) >= 0.6)


# ---

# In[5]:

import qgrid


# In[6]:

import pandas as pd
print(float(pd.__version__[:4]) >= 0.18)


# In[7]:

import sklearn
print(float(sklearn.__version__[:4]) >= 0.17)


# In[8]:

import statsmodels.api as sm
print(float(sm.version.version[:3]) >= 0.6)


# In[9]:

import xlrd


# In[10]:

import xlsxwriter


# ---

# In[11]:

import clusterpy as cl
print(float(cl.__version__[:3]) >= 1.0)


# In[12]:

import fiona
print(float(fiona.__version__[:3]) >= 1.7)


# In[13]:

import geopandas as gpd
print(float(gpd.__version__[:3]) >= 0.2)


# In[14]:

import pysal as ps
print(float(ps.version[:4]) >= 1.11)


# In[20]:

import rasterio as rio


# # Test

# In[15]:

shp = ps.examples.get_path('columbus.shp')
db = gpd.read_file(shp)
print(db.head())


# In[16]:

import matplotlib.pyplot as plt
#f, ax = plt.subplots(1)
#db.plot(facefolor='yellow', edgecolor='grey', linewidth=0.1)
#ax.set_axis_off()
#plt.show()


# In[17]:

db.crs['init'] = 'epsg:26918'


# In[18]:

db_wgs84 = db.to_crs(epsg=4326)
#db_wgs84.plot()
#plt.show()


# In[19]:

#db.plot(column='INC', scheme='fisher_jenks', cmap=plt.matplotlib.cm.Blues)
#plt.show()


# import numpy as np
# source = rio.open('../labs/figs/lab03_GBOverview.tif', 'r')
# red = source.read(1)
# green = source.read(2)
# blue = source.read(3)
# pix = np.dstack((red, green, blue))
# bounds = (source.bounds.left, source.bounds.right, \
#           source.bounds.bottom, source.bounds.top)
# f = plt.figure(figsize=(6, 6))
# ax = plt.imshow(pix, extent=bounds)
