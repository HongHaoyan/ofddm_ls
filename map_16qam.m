function output=map_16qam(input)%���һ��ofdm���16QAMӳ��
[N,NL]=size(input);
 N=N/4;
 output=zeros(N,NL);
  for j=1:NL
      for n=1:N
          for ic=1:4
              qam_input(ic)=input((n-1)*4+ic,j);  %ÿ��ȡ4��bit 
          end
          output(n,j)=qam16(qam_input);           %outputÿһ��Ϊһ��FFT������źţ���һ��ofdm���Žṹ����
      end
   
  end   
