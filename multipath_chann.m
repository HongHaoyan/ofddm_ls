function output_sig=multipath_chann(input_sig,num,var_pow,delay,fd,t_interval,counter,count_begin)
%input_sig�����źž���,����cp����źţ���СΪNL��(���ز�����+cp����lp)��
%num�ྶ��;
%var_pow�������������ƽ������,��λdB��
%delay������ʱ,��λs��
%fd���doppleƵ�ʣ�
%t_intervalΪ��ɢ�ŵ�����ʱ����������OFDM���ų���/(���ز�����+cp����lp)��
%output_sigΪ�����ྶ�ŵ�������ź�ʸ��
%counter���������¼
%count_begin���β����ŵ���ʼ��¼�ĳ�ʼλ��

t_shift=floor(delay/t_interval);%��һ��������ʱ
%theta_shift=2*pi*fc*delay;
[nl,l]=size(input_sig);
output_sig=zeros(size(input_sig));

chann_l=nl*l;%�ŵ�������������һ�����Ʒ��Ų���һ���ŵ��㣬���ŵ������������������ź��еĵ��Ʒ��Ÿ���
selec_ray_chan=zeros(num,chann_l);%��ʼ��Ƶ��ѡ�����ŵ���������num
pow_per_channel=10.^(var_pow/10);%�����������Ի�����dBת�������
total_pow_allchan=sum(pow_per_channel);%��������֮��
%����forѭ�������໥������num��rayleigh�ŵ�
for k=1:num
    atts=sqrt(pow_per_channel(k));
    selec_ray_chan(k,:)=atts*rayleighnew(chann_l,t_interval,fd,count_begin+k*counter)/sqrt(total_pow_allchan);
end
for k=1:l
    input_sig_serial(((k-1)*nl+1):k*nl)=input_sig(:,k).';%�����źž���ת��ɴ�������
end
delay_sig=zeros(num,chann_l);%��ʼ����ʱ�������������źţ�ÿ������������Ϊchann_l
%����forѭ��Ϊ�����������ź����ӳٴ���
for f=1:num
    if t_shift(f)~=0
        delay_sig(f,1:t_shift(f))=zeros(1,t_shift(f));
    end
    delay_sig(f,(t_shift(f)+1):chann_l)= input_sig_serial(1:(chann_l-t_shift(f)));
end
output_sig_serial=zeros(1,chann_l);%��ʼ������źŴ�������
%�õ��������Ӻ������ź�����
for f=1:num
        output_sig_serial= output_sig_serial+selec_ray_chan(f,:).*delay_sig(f,:);
end
for k=1:l
    output_sig(:,k)=output_sig_serial(((k-1)*nl+1):k*nl).';%����źŴ�������ת����������ź���ͬ�ľ�����ʽ����Ϊ���������
end
%ע�⣬�ڱ�������û��Ϊ�źŵ��Ӱ�����