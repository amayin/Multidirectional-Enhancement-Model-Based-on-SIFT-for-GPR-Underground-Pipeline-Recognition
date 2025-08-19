#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2023/10/24 15:25
# @Author  : Ryu
# @Site    : 
# @File    : SVM_for_GPR.py
# @Software: PyCharm
import numpy
import numpy as np
from sklearn import svm
import joblib
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score
import pandas as pd
import os
import numpy as np


Path1 = "D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\descriptors/target_real\origin_size_4/"
Path0 = "D:\硕士文件\gprMAX相关\实测数据\SIFT_extract\SIFT_extract_in_GPR\descriptors\clutter\seleted_clutter_vertical - part/"

# 假设你的数据读取函数如下，返回特征矩阵和标签数组，标签数组一致
def load_data_separate(path,con):
    # 在这里实现你的数据加载逻辑
    # 返回特征矩阵X和标签数组y
    # X的形状应该是[n_samples, n_features]，y的形状应该是[n_samples]
    dir_list = os.listdir(path)
    Train_data = [] #构建一个空list
    for dir in dir_list:
        data_path = path+dir
        Train_data_dir = pd.read_csv(data_path,sep=',',header='infer')
        temp = Train_data_dir.values.tolist()
        for i in range(0,len(temp)):
            Train_data.append(temp[i])
    desnum = len(Train_data)
    if con == 1:
        lable = np.ones([desnum,1])
    elif con == 0:
        lable = np.zeros([desnum,1])
    else:
        print("Con only be 0 and 1!")
    lable = np.ravel(lable) # 转化为一维数组
    return Train_data,lable

# 以下是同时读取不同标签的读取函数：
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

# 加载数据
# 加载真实数据
X1, y1 = load_data_separate(Path1,1)
# 加载干扰数据
X2, y2 = load_data_separate(Path0,0)
# 合并
X = X1+X2
y = np.concatenate((y1, y2), axis=0)

# 加载0,1标签混合数据
# X, y = load_data_merge(Data_Path,Label_Path)
# 划分训练集和测试集
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 初始化SVM分类器
# 这里使用了RBF核
clf = svm.SVC(kernel='rbf', C=1, gamma='auto')

# 训练分类器
clf.fit(X, y)

# 保存模型
joblib.dump(clf, 'svm_model.pkl')

# 在测试集上进行预测
y_pred = clf.predict(X_test)

# 打印分类报告和准确率
print("Classification Report:")
print(classification_report(y_test, y_pred))
print("Accuracy:", accuracy_score(y_test, y_pred))