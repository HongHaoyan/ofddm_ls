 function x=input_b(N,NL)%NΪһ��ofdm�����е��ӷ��Ÿ�����NLΪһ�η�����������ofdm������
    for i=1:NL    
         input_0=rand(1,4*N);    %����Ķ�������������
         for j=1:4*N
              if input_0(j)>0.5
                 input(j,i)=1;
               else 
                  input(j,i)=0;
              end
         end
     end
     x=input;
    