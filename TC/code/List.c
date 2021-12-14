#include<stdio.h>

long double f(long double x){
    long double xhalf = 0.5f*x;
    long int i = *(int*)&x;
    i = 0x5f3759df - (i>>1);
    x = *(float*)&i;
    x = x*(1.5f - xhalf*x*x);
    return 1/x;
}

long int f2(int x ){
    long int i = 2;
    long int sum  =1 ;
    for (;i <=f(x) ;i++){
        if(x%i==0){
            sum  = sum  + i; 
            if(i != f(x))
                sum = sum  + x/i;
        }
    }
    return sum;
}

int main(){

    long int i;
    long int facnum;
    for(i = 1 ; i < 1000000L  ;i++){    
        facnum = f2(i);
        if( i == f2(facnum) && i < facnum)
            printf("%ld-%ld\n", i ,facnum);
    }

    return 0;
}