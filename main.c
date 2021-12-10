#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/types.h>

u_int16_t factorSum(u_int16_t x) {
    x = x/2;
	u_int16_t i, sum;
	for (i = 1, sum = 0; i < x; i++) {
		if (x % i == 0) {
			sum += i;
		}
	}
	return sum;
}
int main() {
	u_int16_t min, max, i;
	printf("input\n");
	scanf("%hu%hu", &min, &max);
	for (i = 220; i <= max; i++) {
        if(i == 0) break;
		u_int16_t facSum = factorSum(i);
		if (facSum < min || facSum > max) {
			continue;
		}
		if (i == factorSum(facSum) && i < facSum) {
			printf("%d-%d\n", i, facSum);
		}
	}
	return 0;
}