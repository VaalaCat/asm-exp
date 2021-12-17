unsigned int min_low,max_low;
unsigned int min_high,max_high;

unsigned int now_high,now_low;
unsigned int sum_high,sum_low;

unsigned int i_high,i_low;
unsigned int i1_high,i1_low;
unsigned int tmp_high,tmp_low;

unsigned int arg_high,arg_low;

unsigned int output_high,output_low;

void getsum(){
	sum_high=0;sum_low=0;
	for (i1_high=0;i1_high<=arg_high;i1_high++){
		if (i1_high == arg_high){
			for (i1_low=0;i1_low<=arg_low;i1_low++){
				unsigned int tmp1=(arg_high<<16)+arg_low;
				unsigned int tmp2=(i1_high<<16)+i1_low;
				if (i1_high==arg_high && i1_low==arg_low){
					return;
				}
				if (tmp1 % tmp2==0){ // 伪代码
					sum_low=sum_low+i1_low;
					unsigned int tmp3=(sum_low>>16);
					sum_low-=(tmp3<<16);
					sum_high=sum_high+i1_high+tmp3;
				}
			}
		}
		else{
			for (i1_low=0;i1_low<=0xffff;i1_low++){
				unsigned int tmp1=(arg_high<<16)+arg_low;
				unsigned int tmp2=(i1_high<<16)+i1_low;
				if (i1_high==arg_high && i1_low==arg_low){
					return;
				}
				if (tmp1 % tmp2==0){ // 伪代码
					sum_low=sum_low+i1_low;
					unsigned int tmp3=(sum_low>>16);
					sum_low-=(tmp3<<16);
					sum_high=sum_high+i1_high+tmp3;
				}
			}
		}
	}
	return;
}

int main(){
	min_low = 0x00dc;
	min_high = 0x0000;
	max_low = 0x0000;
	max_high = 0x0011;
	arg_high = 0x0000;
	arg_low = 0x0000;
	for (i_high=min_high;i_high<=max_high;i_high++){
		if (i_high==min_high && min_high==max_high){
			for (i_low=min_low;i_low<=max_low;i_low++){// 伪代码
				arg_high=i_high;
				arg_low=i_low;
				getsum();
				tmp_high=sum_high;
				tmp_low=sum_low;
				arg_high=tmp_high;
				arg_low=tmp_low;
				getsum();
				if (i_high==sum_high && i_low==sum_low){
					output_high=tmp_high;
					output_low=tmp_low;
					printf("%.4x%.4x-%.4x%.4x\n",i_high,i_low,tmp_high,tmp_low);
				}
			}
			break;
		}
		if (i_high==min_high && min_high!=max_high){
			for (i_low=min_low;i_low<=0xffff;i_low++){
				arg_high=i_high;
				arg_low=i_low;
				getsum();
				tmp_high=sum_high;
				tmp_low=sum_low;
				arg_high=tmp_high;
				arg_low=tmp_low;
				getsum();
				if (i_high==sum_high && i_low==sum_low){
					output_high=tmp_high;
					output_low=tmp_low;
					printf("%.4x%.4x-%.4x%.4x\n",i_high,i_low,tmp_high,tmp_low);
				}
			}
			continue;
		}
		if (i_high!=min_high && min_high!=max_high && i_high!=max_high){
			for (i_low=0;i_low<=0xffff;i_low++){
				arg_high=i_high;
				arg_low=i_low;
				getsum();
				tmp_high=sum_high;
				tmp_low=sum_low;
				arg_high=tmp_high;
				arg_low=tmp_low;
				getsum();
				if (i_high==sum_high && i_low==sum_low){
					output_high=tmp_high;
					output_low=tmp_low;
					printf("%.4x%.4x-%.4x%.4x\n",i_high,i_low,tmp_high,tmp_low);
				}
			}
			continue;
		}
		if (i_high==max_high){
			for (i_low=0;i_low<=max_low;i_low++){
				arg_high=i_high;
				arg_low=i_low;
				getsum();
				tmp_high=sum_high;
				tmp_low=sum_low;
				arg_high=tmp_high;
				arg_low=tmp_low;
				getsum();
				if (i_high==sum_high && i_low==sum_low){
					output_high=tmp_high;
					output_low=tmp_low;
					printf("%.4x%.4x-%.4x%.4x\n",i_high,i_low,tmp_high,tmp_low);
				}
			}
			continue;
		}
	}
	return 0;
}