#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2023/11/14 11:58
# @Author  : Ryu
# @Site    : 
# @File    : One_class_svm_test.py
# @Software: PyCharm
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
Root_Path = 'C:/Users\chen2\OneDrive\Desktop\crack/'              #特征描述符路径
dsp_method = 'FE-GLOH-like'
flag_swift = "on"  # 对称性判别的开关

def load_multiscale_data(data_path,label_path):
    # 输入数据label需要是只有一列
    # 返回特征矩阵X和标签数组y
    # X的形状应该是[n_samples, n_features]，y的形状应该是[n_samples]
    # 文件命名必须要有严格要求，本尺度数据”now“开头，上一尺度数据”pre“开头，下一回读数据”nex“开头
    data_dir_list = os.listdir(data_path)
    label_dir_list = os.listdir(label_path)
    now_data = [] #构建一个空list
    nex_data = []
    label = []
    for data_dir in data_dir_list:
        data_set = set(data_dir)
        if "now" in data_dir:
            full_data_path = data_path+data_dir
            Train_data_dir = pd.read_csv(full_data_path,sep=',',header='infer')
            temp = Train_data_dir.values.tolist()
            for i in range(0, len(temp)):
                now_data.append(temp[i])
        elif "nex" in data_dir:
            full_data_path = data_path+data_dir
            Train_data_dir = pd.read_csv(full_data_path,sep=',',header='infer')
            temp = Train_data_dir.values.tolist()
            for i in range(0, len(temp)):
                nex_data.append(temp[i])

    for label_dir in label_dir_list:
        full_label_path = label_path + label_dir
        Train_label_dir = pd.read_csv(full_label_path,)
        label = Train_label_dir.to_numpy()
    return now_data,nex_data,label

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

def label_zero_to_reverse(label):
    # 该函数作用：将0转化为-1
    label_sp = label.shape[0]
    label_temp = label
    for i in range(0,label_sp):
        if label[i] == 0:
            label_temp[i] = -1
    label = label_temp
    return label

def label_reverse_to_zero(label):
    # 该函数作用：将-1转化为0
    label_sp = label.shape[0]
    label_temp = label
    for i in range(0,label_sp):
        if label[i] == -1:
            label_temp[i] = 0
    label = label_temp
    return label

def load_symmery_flag(flag_path):
    flag_dir_list = os.listdir(flag_path)
    now_flag = []
    nex_flag = []
    for flag_dir in flag_dir_list:
        if "now" in flag_dir:
            full_flag_path = flag_path+flag_dir
            Train_flag_dir = pd.read_csv(full_flag_path,)
            now_flag = Train_flag_dir.to_numpy()
        elif "nex" in flag_dir:
            full_flag_path = flag_path+flag_dir
            Train_flag_dir = pd.read_csv(full_flag_path,)
            nex_flag = Train_flag_dir.to_numpy()
    return now_flag, nex_flag

clf = joblib.load('one_class_svm_model.pkl')
dir_list = os.listdir(Root_Path)
# X_now_test, y_test = load_data_merge(Data_Path,Label_Path)
for dir_path in dir_list:
    Data_Dir_Path = Root_Path + '/' + dir_path + '/' + 'data_' + dsp_method + '/'
    Label_Dir_Path = Root_Path + '/' + dir_path + '/' + 'label_' + dsp_method + '/'
    Flag_Dir_Path = Root_Path + '/' + dir_path + '/' + 'flag_' + dsp_method + '/'
    Pred_file_name = Root_Path + '/' + dir_path + '/' + 'pred_' + dsp_method + '.csv'

    X_now_test, X_nex_test, y_test = load_multiscale_data(Data_Dir_Path,Label_Dir_Path)
    y_test = label_zero_to_reverse(y_test)
    y_now_pred = clf.predict(X_now_test)
    y_nex_pred = clf.predict(X_nex_test)
    if flag_swift == "on":
        f_now, f_nex = load_symmery_flag(Flag_Dir_Path)
        f_now = f_now.flatten()
        f_nex = f_nex.flatten()
        f = f_now * f_nex
        y_now_pred1 = y_now_pred * f_now
        y_nex_pred1 = y_nex_pred * f_nex
    # 打印分类报告和准确率
    y_now_pred = label_reverse_to_zero(y_now_pred1)
    y_nex_pred = label_reverse_to_zero(y_nex_pred1)
    y_pred = y_now_pred | y_nex_pred
    y_pred = label_zero_to_reverse(y_pred)
    print(dir_path)
    print("Classification Report:")
    print(classification_report(y_test, y_pred))
    print("Accuracy:", accuracy_score(y_test, y_pred))
    # 保存，不包括行索引和列索引
    yp = pd.DataFrame(y_pred)
    yp.to_csv(Pred_file_name,index=False,header=False)