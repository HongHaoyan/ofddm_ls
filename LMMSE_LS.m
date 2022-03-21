echo off; 
clear all; 
close all; 

 
fprintf('OFDM���ڿ�״��Ƶ���ŵ������㷨����\n���ڻ�ͼ�����Ժ󡭡�\n'); 
format long 
%���η�����ƵΪ2GHz������1MHz�����ز���128����cpΪ16 
%���ز����Ϊ7.8125kHz 
%һ��ofdm���ų���Ϊ128us��cp����Ϊ16us 
%����16QAM���Ʒ�ʽ 
%���dopplerƵ��Ϊ132Hz 
%�ྶ�ŵ�Ϊ5���������ӳ��׷��Ӹ�ָ���ֲ�~exp(-t/trms),trms=(1/4)*cpʱ���������ӳ�ȡΪdelay=[0 2e-6 4e-6 8e-6 12e-6] 
pilot_inter=5;%��Ƶ���ż��Ϊ10,���Ե���������ͬ��Ƶ����µ�BER����������۹�ʽ�Ƚ� 
pilot_symbol_bit=[0 0 0 1];%��ƵΪ��������Ӧ������1+3*j 
cp_length=16;%cp����Ϊ16 
SNR_dB=[0:4:32]; 
ls_err_ber=zeros(1,length(SNR_dB)); 
lmmse_err_ber=zeros(1,length(SNR_dB)); 
lr_lmmse_err_ber=zeros(1,length(SNR_dB)); 
for i=1:length(SNR_dB)%ÿ��SNR���Ϸ������ɴ� 
    ls_error_bit=0; 
    lmmse_error_bit=0; 
    lr_lmmse_error_bit=0; 
    total_bit_num=0; 
loop_num=10; %������10�� 
for l=1:loop_num 
    ofdm_symbol_num=100;%ÿ�η������100��ofdm����,��ÿ�η��湲��100��128������ӳ����ţ�16QAM�����£�1������ӳ����Ű���4��bit 
     
    bit_source=input_b(128,ofdm_symbol_num);%Ϊÿ�η������100��ofdm���ŵı��ظ�����128Ϊÿ��ofdm���ŵ����ز����� 
    [nbit,mbit]=size(bit_source); 
    total_bit_num=total_bit_num+nbit*mbit; 
     
    map_out=map_16qam(bit_source);%��һ�η�����ſ����16QAMӳ�� 
     
    [insert_pilot_out,pilot_num,pilot_sequence]=insert_pilot(pilot_inter,pilot_symbol_bit,map_out);%����״��Ƶ�ṹ����ӳ���Ľ�����뵼Ƶ���� 
     
    ofdm_modulation_out=ifft(insert_pilot_out,128);%��128����FFT���㣬���ofdm���� 
     
    ofdm_cp_out=insert_cp(ofdm_modulation_out,cp_length);%����ѭ��ǰ׺ ����������ˣ�����û��
         
    %********************** ���¹���Ϊofdm����ͨ��Ƶ��ѡ���Զྶ�ŵ� ************************* 
    num=5; 
    %���蹦���ӳ��׷��Ӹ�ָ���ֲ�~exp(-t/trms),trms=(1/4)*cpʱ���� 
    %t��0~cpʱ���Ͼ��ȷֲ� 
    %��cpʱ��Ϊ16e-6s������ȡ5���ӳ����� 
    delay=[0 2e-6 4e-6 8e-6 12e-6]; 
    trms=4e-6; 
    var_pow=10*log10(exp(-delay/trms)); 
    fd=132;%���dopplerƵ��Ϊ132Hz 
    t_interval=1e-6;%�������Ϊ1us 
    counter=200000;%�����ŵ��Ĳ���������Ӧ�ô����ŵ��������������������������ŵ��������� 
    count_begin=(l-1)*(5*counter);%ÿ�η����ŵ������Ŀ�ʼλ�� 
    trms_1=trms/t_interval; 
    t_max=16e-6/t_interval; 
    %�ŵ�����������ÿ�����Ʒ��Ų�һ���� 
    passchan_ofdm_symbol=multipath_chann(ofdm_cp_out,num,var_pow,delay,fd,t_interval,counter,count_begin); 
     
    %********************** ���Ϲ���Ϊofdm����ͨ��Ƶ��ѡ���Զྶ�ŵ� ************************* 
     
     %********************** ���¹���Ϊofdm���żӸ�˹������ ************************* 
    snr=10^(SNR_dB(i)/10); 
    [nnl,mml]=size(passchan_ofdm_symbol); 
    spow=0; 
    for k=1:nnl 
      for b=1:mml 
        spow=spow+real(passchan_ofdm_symbol(k,b))^2+imag(passchan_ofdm_symbol(k,b))^2; 
      end 
    end 
    spow1=spow/(nnl*mml);         
    sgma=sqrt(spow1/(2*snr));%sgma��μ��㣬�뵱ǰSNR���ź�ƽ�������й�ϵ 
    receive_ofdm_symbol=add_noise(sgma,passchan_ofdm_symbol);%���������˹��������receive_ofdm_symbolΪ���ս��ջ��յ���ofdm���ſ� ��Ϊʲô������Ϊ1�ˣ�
     
    %********************** ���Ϲ���Ϊofdm���żӸ�˹������ ************************* 
    cutcp_ofdm_symbol=cut_cp(receive_ofdm_symbol,cp_length);%ȥ��ѭ��ǰ׺ 
     
    ofdm_demodulation_out=fft(cutcp_ofdm_symbol,128);%��128��FFT���㣬���ofdm��� 
     
    %********************** ���¾��ǶԽ���ofdm�źŽ����ŵ����ƺ��źż��Ĺ���************************ 
    ls_zf_detect_sig=ls_estimation(ofdm_demodulation_out,pilot_inter,pilot_sequence,pilot_num);%����LS�����㷨��������õ��Ľ����ź� 
    lmmse_zf_detect_sig=lmmse_estimation(ofdm_demodulation_out,pilot_inter,pilot_sequence,pilot_num,trms_1,t_max,snr);%����LMMSE�����㷨��������õ��Ľ����ź� 
    low_rank_lmmse_sig=lr_lmmse_estimation(ofdm_demodulation_out,pilot_inter,pilot_sequence,pilot_num,trms_1,t_max,snr,cp_length);%���õ���LMMSE�����㷨��������õ��Ľ����ź� 
    %********************** ���¾��ǶԽ���ofdm�źŽ����ŵ����ƺ��źż��Ĺ���************************ 
     
    ls_receive_bit_sig=de_map(ls_zf_detect_sig);%16QAM��ӳ�� 
    lmmse_receive_bit_sig=de_map(lmmse_zf_detect_sig); 
    lr_lmmse_receive_bit_sig=de_map(low_rank_lmmse_sig); 
     
    %���¹���ͳ�Ƹ��ֹ����㷨�õ��Ľ����ź��еĴ�������� 
    ls_err_num=error_count(bit_source,ls_receive_bit_sig); 
    lmmse_err_num=error_count(bit_source,lmmse_receive_bit_sig); 
    lr_lmmse_err_num=error_count(bit_source,lr_lmmse_receive_bit_sig); 
     
    ls_error_bit=ls_error_bit+ls_err_num; 
    lmmse_error_bit=lmmse_error_bit+lmmse_err_num; 
    lr_lmmse_error_bit=lr_lmmse_error_bit+lr_lmmse_err_num; 
end 
%������ֹ����㷨��������� 
 
ls_err_ber(i)=ls_error_bit/total_bit_num; 
lmmse_err_ber(i)=lmmse_error_bit/total_bit_num; 
lr_lmmse_err_ber(i)=lr_lmmse_error_bit/total_bit_num; 
 
end 
 
plot(SNR_dB,ls_err_ber,'-*b'); 
hold on 
plot(SNR_dB,lmmse_err_ber,'-oblack'); 
hold on; 
plot(SNR_dB,lr_lmmse_err_ber,'-vblack'); 
grid on; 
xlabel('�����SNR(dB)'); 
ylabel('�������(BER)'); 
%title('OFDM���ڿ�״��Ƶ���ŵ������㷨����'); 
legend('LS�ŵ�����','MMSE�ŵ�����','LMMSE�ŵ�����'); 
 
fprintf('��ͼ���@��@\n') 
hold off; 
 
