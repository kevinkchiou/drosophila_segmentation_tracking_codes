function Iout=imageShift(I)
Imax=max(max(I));Imin=min(min(I));
mintarget=0.3;maxtarget=1.0; %minimum and maximum targets of the shifted image
Iout=mintarget+(I-Imin)*(maxtarget-mintarget)/(Imax-Imin); %linear interpolation
end