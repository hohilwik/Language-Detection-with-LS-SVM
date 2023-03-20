# Language Detection of recorded audio with LS-SVM

The dataset consisted of 3.5 hours of audio in 7-15 second clips in different languages from over 50 different speakers.

Language detection of 7 Indian languages using LPC and Hilbert envelope for VOP and syllable detection, pitch content found using peaks in autocorrelation vector as features, bayesian inference and LS-SVM for classification.

For each audio clip, the vowel onset points were found, and the autocorrelation vector for the pitch content was taken the audio between VOPs, corresponding to the pitch content of a syllable. The autocorrelation vector of length 1600 was taken as the recorded clips were sampled at 16kHz. This allows for a maximum rate of 10 syllables per second. As the world record for the fastest rap stands at 9.6 syllables per second for Eminem's "Rap God", we feel that this is a reasonable limit to put on the system. For initial analysis, the autocorrelation vectors of labeled clips were plotted by language, and a very clear pattern of varying shapes of the vector by language was found. To make the distinction clearer, maximum and minimumcutoffs of the vector were assigned, with any value below the minimum assigned value being changed to 0, and any value above the maximum being capped to the maximum assigned value. 

The plots from the analysis are shown in the plots folder, and it can be seen that the shape and positioning of the peaks is clearly distinct among languages. We can even distinguish between Bengali and Oriya, which are very similar languages. 

As we do not want to focus on minute changes in the positioning of peaks but rather the overall shape of the autocorrelation vector, we define a vector of length 24 which consists of the maximum value of the vector between 200 and 1400 lag of the vector in intervals of 50. 

We believe that these vectors are the optimal features to be used for this purpose, and as such were used for the training of the models.

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
