
package com.fingerPrint.common.util.test;

@SuppressWarnings("restriction")
public class RSAUtil {
function [pxy3,error2]=combine(thin,r,txy,num)
error=0;
[pxy2,error]=single_point(txy,r);
n=size(pxy2,1);
k=1;
erroe2=0;
for i=1:n
    [error,a,b]=walk(thin,pxy2(i,1),pxy2(i,2),num);
    if error~=1
        pxy3(k,1)=pxy2(i,1);
        pxy3(k,2)=pxy2(i,2);
        pxy3(k,3)=pxy2(i,3);
        k=k+1;
        error2=0;
        plot(pxy2(i,1),pxy2(i,2),'r+');
    end
end

}