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
from sklearn.svm import OneClassSVM
import chardet

Path1 = "F:/硕士文件/gprMAX相关/实测数据/SIFT_extract/Multidirectional Enhancement Model Based on SIFT for GPR Underground Pipeline Recognition_latex/描述符/trainset_FE-GLOH/"  #训练数据路径
Nu = 0.15

# 数据读取函数
def load_data(path):
    # 在这里实现你的数据加载逻辑
    # 返回特征矩阵X
    dir_list = os.listdir(path)
    csv_file_list = [file for file in dir_list if file.endswith('.csv')]
    Train_data = [] #构建一个空list
    for dir in csv_file_list:
        data_path = path+dir
        with open(data_path, 'rb') as f:
            result = chardet.detect(f.read())
            encoding = result['encoding']
            Train_data_dir = pd.read_csv(data_path,sep=',', header='infer', encoding=encoding)            # 读取csv文件，去掉表头第一行
            temp = Train_data_dir.values.tolist()
            for i in range(0,len(temp)):
                Train_data.append(temp[i])
    return Train_data


# 加载数据
# 加载真实数据
X = load_data(Path1)

# 初始化单核SVM分类器
# 这里使用了RBF核
clf = OneClassSVM(kernel='rbf', gamma='auto', nu=Nu)

# 训练分类器
clf.fit(X)

# 保存模型
joblib.dump(clf, 'one_class_svm_model.pkl')
