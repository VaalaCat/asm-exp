int l,r;
int ans=0;
void check(int x,int y)
{
	int tot=1;
	for (int i=2;i*i<=x;i++)
	{
		ans++;
		if (x%i==0)
		{
			if (i*i!=x)
			{
				tot+=i;
				tot+=x/i;
			}
			else tot+=i;
			if (tot>y) return;
		}
	}
	if (tot==y)
		return;
}
void getsum(int x)
{
	int tot=1;
	for (int i=2;i*i<=x;i++)
	{
		ans++;
		if (x%i==0)
		{
			if (i*i!=x)
			{
				tot+=i;
				tot+=x/i;
			}
			else tot+=i;
			if (tot>=x) return;
		}
	}
	check(tot,x);
}
int main()
{
	l=1;
	r=1000000;
	for (int i=l;i<=r;i++)
	{
		getsum(i);
	}
	return 0;
}