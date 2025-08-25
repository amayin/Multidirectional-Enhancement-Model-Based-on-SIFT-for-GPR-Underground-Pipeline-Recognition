# Multidirectional-Enhancement-Model-Based-on-SIFT-for-GPR-Underground-Pipeline-Recognition
This is a small training set recognition method based on SIFT for identifying underground targets in ground-penetrating radar images. You need to run this code through the following three steps:
Step 1
Run the main code 'Generate_Training_descriptor_solo.m' to generate the descriptor, the output path and other parameters should be set correctly.
Step 2
Navigate to the 'SVM' folder and run the 'One_class_SVM_for_GPR' and 'One_class_svm_test_solo' codes separately.
Code 'One_class_SVM_for_GPR' is responsible for generating the support vector machine model, and the training set used can be 'descriptor/trainset_FE-GLOH' or your own training set.
Then run the 'One_class_svm_test_solo', it will generate the prediction results 'pred_***.csv' under the output path.
