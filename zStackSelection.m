function [outimg] = zStackSelection(FILENAME,fig)
%ZSTACKSELECTION zStackSelection(FILENAME) takes a string
%FILENAME='/path/to/file.tif' a tif hyperstack and prompts the user to 
%help create an output max-intensity projection image using only a subset
%of the z-stacks
%   Detailed explanation goes here

imginfo=imfinfo(FILENAME);
N=numel(imginfo); %total number of stacks
img=zeros(imginfo(1).Height,imginfo(1).Width,N);
for i=1:N
    img(:,:,i)=imread(FILENAME,i);
end
[num_z,num_t]=detZStackNum(N);

if nargin<2
    h=figure;
else
    h=figure(fig);
end

sz=size(img(:,:,1));
img_zstack=zeros(sz(1),sz(2),num_z);
outimg=zeros(sz(1),sz(2),num_t);
fprintf('Use the format ''start:end'' without the quotes (e.g. ''3:5'')\n');
fprintf('Or just press enter to select this projection for this t\n')
for i=1:num_t
    for j=1:num_z
        img_zstack(:,:,j)=img(:,:,num_z*(i-1)+j);
    end
    maxintproj=max(img_zstack,[],3);figure(h);
    imshow(maxintproj,[median(maxintproj(:))/2,max(maxintproj(:))]);title(sprintf('t = %d, z = all',i));
    userflag=1;
    fprintf('Enter the range of z stacks between %d and %d for t=%d.\n',1,num_z,i);
    while(userflag)
        vec=input('("startZ:endZ", or just press "ENTER" to confirm current image and continue): ');
        if isempty(vec)
            userflag=0;
        elseif min(vec)>0 && max(vec)<num_z+1
            maxintproj=max(img_zstack(:,:,vec),[],3);figure(h);
            imshow(maxintproj,[median(maxintproj(:))/2,max(maxintproj(:))]);title(sprintf('t = %d, z = [%s]',i,num2str(vec)));
        else
            fprintf(sprintf('Oops, your chosen stacks (%d) are out of range! Try again...\n',vec));
        end
    end
    outimg(:,:,i)=maxintproj;
end

end

function [n,t]=detZStackNum(N)
fprintf('I have detected %d total stacks in the image\n',N);
fprintf('Enter the number of time slices (t) or z slices (z)?\n');
in1=input('(Please enter either ''t'' or ''z'' without the quotes): ','s');
Time={'t','t ','t  ',' t','  t','  t ',' t ','  t ','T','T ',' T','T  ','  T',' T '};
Z={'z','z ','z  ',' z','  z','  z ',' z ','  z ','Z','Z ',' Z','Z  ','  Z',' T '};
if(sum(strcmp(in1,Time))>0)
    in2=input('Please enter the total number of time slices: ');
    if(mod(N,in2)==0)
        n=N/in2;t=in2;
        fprintf('Great! We have %d z stacks and a total of %d time slices!\n',n,t);
    else
        fprintf('Sorry, %lf does not evenly divide %d. We will try again...\n',in2,N);
        [n,t]=detZStackNum(N);
    end
elseif(sum(strcmp(in1,Z))>0)
    in2=input('Please enter the number of z stacks per time slice: ');
    if(mod(N,in2)==0)
        n=in2;t=N/n;
        fprintf('Great! We have %d z stacks and a total of %d time slices!\n',n,t);
    else
        fprintf('Sorry, %lf does not evenly divide %d. We will try again...\n',in2,N);
        [n,t]=detZStackNum(N);
    end
else
    fprintf('Sorry, I did not understand your answer. We will try again...\n');
    [n,t]=detZStackNum(N);
end
end