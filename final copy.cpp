unsigned int min_low,max_low;
unsigned int min_high,max_high;

unsigned int now_high,now_low;
unsigned int sum_high,sum_low;

unsigned int i_high,i_low;
unsigned int tmp_high,tmp_low;

unsigned int arg_high,arg_low;

unsigned int output_high,output_low;

void getsum(){
	for (i_high=0;i_high<arg_high;i_high++){
		for (i_low=0;i_low<arg_low;i_low++){
			if ((arg_high+arg_low) % (i_high+i_low) == 0){ // 伪代码
				sum_low=sum_low+i_low;
				sum_high=sum_high+i_high;
			}
		}
	}
	return;
}

void main(){
	min_low = 0x0001;
	min_high = 0x0000;
	max_low = 0x0000;
	max_high = 0x0020;

	for (i_high=min_high;i_high<=max_high;i_high++){
		if (i_high==max_high){
			for (i_low=min_low;i_low<=max_low;i_low++){
				arg_high=i_high;
				arg_low=i_low;
				getsum();
				tmp_high=sum_high;
				tmp_low=sum_low;
				arg_high=tmp_high;
				arg_low=tmp_low;
				getsum();
				if (tmp_high==sum_high && tmp_low==sum_low){
					output_high=tmp_high;
					output_low=tmp_low;
				}
			}
		}else{
			for (i_low=min_low;i_low<0xffff;i_low++){
				arg_high=i_high;
				arg_low=i_low;
				getsum();
				tmp_high=sum_high;
				tmp_low=sum_low;
				arg_high=tmp_high;
				arg_low=tmp_low;
				getsum();
				if (tmp_high==sum_high && tmp_low==sum_low){
					output_high=tmp_high;
					output_low=tmp_low;
				}
			}
		}
	}
}