function [ delay ] = CSPRT_delay( X,h0,h1,m)
% input sample packages
% output delay and error probability after change of measure

sample_length=size(X,2); % length of every sample
package_size=size(X,1); % number of samples in one package
repeat=round(package_size/m); % repeat_time_per_package
mu0=-1; mu1=1;

L=2/2*(mu1-mu0)*X+(mu0^2-mu1^2)/2; %log-likelihood ratio
S=cumsum(L,2);% cumulative log-likelihood ratio
% add sensor LLR
Sc=zeros([repeat,sample_length]);
for i=1:repeat
    Sc(i,:)=sum(S((i-1)*m+1:i*m,:));
end
h1_index=ge(Sc,h1); % judge if geq b
h0_index=le(Sc,-h0);
h1_stop=zeros(repeat,1); % stop time for voting rule under theshold b
h0_stop=zeros(repeat,1);
stop=zeros(repeat,1); % final stopping time
chioce=zeros(repeat,1); % chioce of hypothesis
for re=1:repeat
    
    if ~isempty( find(h1_index(re,:)>0, 1) )
        tau_b=find(h1_index(re,:)>0, 1);
    else
        tau_b=sample_length+1;
    end
    if ~isempty( find(h0_index(re,:)>0, 1) )
        tau_a=find(h0_index(re,:)>0, 1);
    else
        tau_a=sample_length+1;
    end
    
    if tau_b>sample_length
        h1_stop(re)=sample_length+1;
    else
        h1_stop(re)=tau_b;
    end
    if tau_a>sample_length
        h0_stop(re)=sample_length+1;
    else
        h0_stop(re)=tau_a;
    end
    min_stop=min(h0_stop(re),h1_stop(re)); % stopping time
    if min_stop<=sample_length
        stop(re)=min_stop;
        chioce(re)=ge(h0_stop(re),h1_stop(re)); % if cross h1 earlier than cross h0, chioce=1 (means H_1 is chosen)
    else
        chioce(re)=-1; %nothing choosed (stop hold zero)
    end
end
num_nostop=sum(chioce<0); % number of chioces that don't stop before length
delay=stop;
mean_stop=sum(stop)/(repeat-num_nostop)

