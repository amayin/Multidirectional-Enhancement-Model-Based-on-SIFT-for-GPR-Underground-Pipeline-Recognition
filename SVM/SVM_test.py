#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2023/11/5 22:09
# @Author  : Ryu
# @Site    : 
# @File    : SVM_test.py
# @Software: PyCharm

import joblib
import os
from sklearn.metrics import classification_report, accuracy_score
import pandas as pd
import numpy as np

Data_Path = "D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\descriptors/target_real\guilin001_data_Gloh_8/"
Label_Path = "D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\descriptors/target_real\guilin001_label_Gloh_8/"

def load_data_merge(data_path,label_path):
    # 输入数据label需要是只有一列
    # 返回特征矩阵X和标签数组y
    # X的形状应该是[n_samples, n_features]，y的形状应该是[n_samples]
    data_dir_list = os.listdir(data_path)
    label_dir_list = os.listdir(label_path)
    data = [] #构建一个空list
    label = []
    for data_dir in data_dir_list:
        full_data_path = data_path+data_dir
        Train_data_dir = pd.read_csv(full_data_path,sep=',',header='infer')
        temp = Train_data_dir.values.tolist()
        for i in range(0,len(temp)):
            data.append(temp[i])
    for label_dir in label_dir_list:
        full_label_path = label_path + label_dir
        Train_label_dir = pd.read_csv(full_label_path,)
        label = Train_label_dir.to_numpy()
    return data,label


clf = joblib.load('svm_model.pkl')
X_test, y_test = load_data_merge(Data_Path,Label_Path)
y_pred = clf.predict(X_test)
# 打印分类报告和准确率
print("Classification Report:")
print(classification_report(y_test, y_pred))
print("Accuracy:", accuracy_score(y_test, y_pred))
# 保存，不包括行索引和列索引
yp = pd.DataFrame(y_pred)
yp.to_csv('D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\descriptors/target_real\pred.csv',index=False,header=False)

