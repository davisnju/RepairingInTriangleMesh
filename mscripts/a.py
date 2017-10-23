# -*- coding: utf-8 -*-
"""
Created on Mon Oct 23 13:22:00 2017

@author: davis
"""

from sklearn.cluster import KMeans

import pandas as pd

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


vertexes = pd.read_csv("D:/OSG/Production_1/Data/vertex.csv")


fig = plt.figure()
ax = Axes3D(fig, rect=[9, 9, 15, 15], elev=30, azim=20)
plt.scatter(vertexes[:, 0], vertexes[:, 1], vertexes[:, 2],marker='o')
plt.show()


# n_clusters参数指定分组数量，random_state = 1用来重现同样的结果

kmeans_model = KMeans(n_clusters=4, random_state=1)

# 通过fit_transform()方法来训练模型

senator_distances = kmeans_model.fit_transform(vertexes.iloc[:, :])

labels = kmeans_model.labels_


plt.scatter(x=senator_distances[:,0], y=senator_distances[:,1], c=labels)

plt.show()

