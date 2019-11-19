package com.fingerPrint.common.util.test;


@SuppressWarnings("restriction")
public class getSpecialAreaFeature {
M=0;var=0;
for x=1:m
    for y=1:n
        M=M+gray(x,y);
    end
end
M1=M/(m*n);
for x=1:m
    for y=1:n
        var=var+(gray(x,y)-M1).^2;
    end;
end;
var1=var/(m*n);
for x=1:m
    for y=1:n
        if gray(x,y)>M1
            gray(x,y)=150+sqrt(2000*(gray(x,y)-M1)/var1);
        else 
            gray(x,y)=150-sqrt(2000*(M1-gray(x,y))/var1);
        end
    end
end
figure;imshow(uint8(gray))


}