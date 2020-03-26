#!/usr/bin/env python
# coding: utf-8

# # Libraries

# In[1]:


import pandas as pd
import numpy as np
import math
import pickle

from scipy import stats
import scipy.io
from scipy.spatial.distance import pdist
from scipy.linalg import cholesky
from scipy.io import loadmat

import matlab.engine as engi
import matlab as mat

from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC
from sklearn.metrics import classification_report,roc_auc_score,recall_score,precision_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler

from src import SMOTE
from src import CFS
from src import metrices

import platform
from os import listdir
from os.path import isfile, join
from glob import glob
from pathlib import Path
import sys
import os
import copy
import traceback
from pathlib import Path

import matplotlib.pyplot as plt


# # Start matlab service

# In[2]:


eng = engi.start_matlab()
eng.addpath(r'src/matlab_CTKCCA/',nargout=0)
eng.addpath(r'src/matlab_KS/',nargout=0)


# # variables

# In[3]:


result_path = 'result/result.csv'
repeats = 20
ratio = 0.1
lrank = 70
reg = 1E-5


# # Data loading and Normalizing Data

# In[8]:


def load_data(project):
    understand_path = 'data/understand_files_all/' + project + '_understand.csv'
    commit_guru_path = 'data/commit_guru/' + project + '.csv'
    understand_df = pd.read_csv(understand_path)
    understand_df = understand_df.dropna(axis = 1,how='all')
    cols_list = understand_df.columns.values.tolist()
    for item in ['Kind', 'Name','commit_hash', 'Bugs']:
        if item in cols_list:
            cols_list.remove(item)
            cols_list.insert(0,item)
    understand_df = understand_df[cols_list]
    commit_guru_df = pd.read_csv(commit_guru_path)
    cols = understand_df.columns.tolist()
    
    commit_guru_df = commit_guru_df.drop(labels = ['parent_hashes','author_name','author_name',
                                                   'author_email','fileschanged','author_date',
                                                   'author_date_unix_timestamp', 'commit_message',
                                                  'classification', 'fix', 'contains_bug','fixes',],axis=1)

#     print(commit_guru_df.columns)
    understand_df = understand_df.drop_duplicates(cols[4:len(cols)])
    df = understand_df.merge(commit_guru_df,on='commit_hash')
#     df = understand_df
    cols = df.columns.tolist()
    cols = cols[1:] + [cols[0]]
    df = df[cols]
    for item in ['Kind', 'Name','commit_hash']:
        if item in cols:
            df = df.drop(labels = [item],axis=1)
    df.dropna(inplace=True)
    df.reset_index(drop=True, inplace=True)
    s_df,s_cols = apply_cfs(df)
    y = s_df.Bugs
    X = s_df.drop('Bugs',axis = 1)
#     y = df.Bugs
#     X = df.drop('Bugs',axis = 1)
    cols = X.columns
    scaler = MinMaxScaler()
    X = scaler.fit_transform(X)
    X = pd.DataFrame(X,columns = cols)
    df = pd.concat([X,y],axis = 1)
    return df

def apply_smote(df):
    cols = df.columns
    smt = SMOTE.smote(df)
    df = smt.run()
    df.columns = cols
    return df

def apply_cfs(df):
        y = df.Bugs.values
        X = df.drop(labels = ['Bugs'],axis = 1)
        X = X.values
        selected_cols = CFS.cfs(X,y)
        cols = df.columns[[selected_cols]].tolist()
        cols.append('Bugs')
        return df[cols],cols


# # Matlab integration
# ## Matlab integration - CTKCCA

# In[9]:


def CTKCCA(source_df,target_df):
    mat_source_df = mat.double(source_df.values.T.tolist())
    mat_target_df = mat.double(target_df.values.T.tolist())
    X = eng.CTKCCA(mat_source_df,mat_target_df,nargout=4)
    train_X,train_y = np.array(X[0]),np.array(X[1]).tolist()[0]
    test_X,test_y = np.array(X[2]),np.array(X[3]).tolist()[0]
    return train_X,train_y,test_X,test_y


# # Teting using original Data

# ## Running CPDP with CTKCCA

# In[10]:



precision_list = {}
recall_list = {}
pf_list = {}
f1_list = {}
g_list = {}
auc_list = {}
proj_df = pd.read_csv('projects.csv')
projects = proj_df.repo_name.tolist()
for s_project in projects:
    try:
        if s_project not in precision_list.keys():
            precision_list[s_project] = {}
            recall_list[s_project] = {}
            pf_list[s_project] = {}
            f1_list[s_project] = {}
            g_list[s_project] = {}
            auc_list[s_project] = {} 
        source_df = load_data(s_project)
        source_df = apply_smote(source_df)
        for d_project in projects:
            try:
                target_df = load_data(d_project)
                # Transforming metrics
                trasformed_train_X,trasformed_train_y,trasformed_test_X,trasformed_test_y = CTKCCA(source_df,target_df)
        #         train_df = pd.DataFrame(trasformed_train_X)
        #         train_df['Bugs'] = trasformed_train_y
        #         train_df = apply_smote(train_df)
        #         trasformed_train_y = train_df.Bugs
        #         trasformed_train_X = train_df.drop('Bugs',axis = 1)
                #Training Model & Predicting
                t_clf = LogisticRegression()
                t_clf.fit(trasformed_train_X,trasformed_train_y)
                t_predicted = t_clf.predict(trasformed_test_X)
                # Calculating metrics
                abcd = metrices.measures(trasformed_test_y,t_predicted)
                pf = abcd.get_pf()
                recall = abcd.calculate_recall()
                precision = abcd.calculate_precision()
                f1 = abcd.calculate_f1_score()
                g_score = abcd.get_g_score()
                auc = roc_auc_score(trasformed_test_y, t_predicted)
                # Storing Performance scores
                precision_list[s_project][d_project] = precision
                recall_list[s_project][d_project] = recall
                pf_list[s_project][d_project] = pf
                f1_list[s_project][d_project] = f1
                g_list[s_project][d_project] = g_score
                auc_list[s_project][d_project] = auc
                print(classification_report(trasformed_test_y, t_predicted))
            except:
                continue
    except:
        continue
final_result = {}
final_result['precision'] = precision_list
final_result['recall'] = recall_list
final_result['pf'] = pf_list
final_result['f1'] = f1_list
final_result['g'] = g_list
final_result['auc'] = auc_list
with open('results/Performance/KS_100.pkl', 'wb') as handle:
    pickle.dump(final_result, handle, protocol=pickle.HIGHEST_PROTOCOL)


# In[ ]:




