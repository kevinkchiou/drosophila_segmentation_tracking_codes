function [ output_args ] = ordFiltTest(img,domain)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


figure(1);imshow(img);
for i=1:floor(2/3*sum(sum(domain)))
    testimg=ordfilt2(img,i,domain);
    figure(i+1);imshow(testimg);
end


end

