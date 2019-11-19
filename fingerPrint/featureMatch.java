
package com.fingerPrint.common.util.test;
@SuppressWarnings("restriction")
public class featureMatch {
function d=distance(x0,y0,num,thin)
num2=fix(num/5);
for i=1:num2
    [error,a,b]=walk(thin,x0,y0,5*i);
    if error~=1
        d(i)=sqrt((a-x0)^2+(b-y0)^2);
    else
        break;
    end
end
 
 f=（sum(abs((d1./d2)-1))）

 fff=abs(f11-f21)/(f11+f12)
close all;
tic;
clear;
thin1=tuxiangyuchuli('zhiwen.png');
thin2=tuxiangyuchuli('zhiwen.png');
figure;
txy1=point(thin1);
txy2=point(thin2);
[w1,txy1]=guanghua(thin2,txy2);
[w2,txy2]=guanghua(thin2,txy2);
thin1=w1;
thin2=w2;
txy1=cut(thin1,txy1);
txy2=cut(thin2,txy2);
[pxy31,error2]=combine(thin1,8,txy1,60);
[pxy32,error2]=combine(thin2,8,txy2,60);
error=1;
num=20;
cxy1=pxy31;
cxy2=pxy32;
d1=distance(cxy1(1,1),cxy1(1,2),num,thin1);
d2=distance(cxy2(1,1),cxy2(1,2),num,thin2);
f=(sum(abs((d1./d2)-1)));
if(f<0.5)
    error=0;
else
    error=1;
end
}