function featureOut=gaborProcess(imgIn,nwave,norient) %relies on downloaded subroutines, gaborFilterBank() and gaborFeatures


filterMat=gaborFilterBank(nwave,norient,3,3); %(3,3): 3x3 filter matrix
featureVec=gaborFeatures(imgIn,filterMat,1,1); %(1,1): no downsampling
n=numel(featureVec)/numel(imgIn); %compute number of feature modes
sz=size(imgIn);featureMatrix=reshape(featureVec,sz(1),sz(2),n);
featureOut=sum(featureMatrix,3)';
end