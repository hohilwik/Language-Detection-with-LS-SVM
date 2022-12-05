# Language-Detection-with-LS-SVM
Language detection of 7 Indian languages using LPC and Hilbert envelope for VOP and syllable detection, pitch content found using peaks in autocorrelation vector as features, bayesian inference and LS-SVM for classification.

The languages are:
1. Assamese
2. Bengali
3. Gujarati
4. Manipuri
5. Marathi
6. Odiya
7. Telugu

The same features were trained on multiple models, wherein:

1. Decision Tree: 39% accuracy
2. Random Forest: 52%
3. Random Forest with PCA: 60%
4. LS-SVM with Gaussian Kernel: 83%
5. LS-SVM with Polynomial Kernel: 85%
6. LS-SVM with Linear Kernel: 87%
7. Semisupervised LS-SVM: 86%

The data was shuffled and split into three splits:
1. Labeled training (20%)
2. Unlabeled training (60%)
3. Testing (20%)

Bayesian Inference is used for calculating w and b when fitting the data. In LSSVC, the methods `lssvc.predictmargins` and `lssvc.predict` are used together to remove indices with low margins, and the remaining data is appended to the labeled data and used for unsupervised training. 

The training data is labeled, and accuracy on test data is compared for supervised and semisupervised trained models, and we see that semisupervised learning with appropriate margins does not degrade accuracy much.
