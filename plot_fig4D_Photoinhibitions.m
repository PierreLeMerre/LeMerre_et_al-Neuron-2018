%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure 4.D.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('Opto_Data','var')==0 || exist('Opto_Data_description','var')==0
[PathDatabase,Opto_Data,Opto_Data_description]=Load_Optogenetic_Inactivation_database;
end

%% Parameters
Areas={'wS1','wS2','wM1','PtA','dCA1','mPFC'};

fig1=figure;
for j=1:size(Areas,2)
        Area=char(Areas(j));
        Mouse_list=unique(Opto_Data.Mouse_Name(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1));

    
    for i=1:size(Mouse_list,1)
        Mouse=char(Mouse_list(i));
        
        h_l=sum(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Opto_Data.Mouse_Name,Mouse)==1 & Opto_Data.Trial_ID==1 & Opto_Data.Trial_Light==1);
        s_l=sum(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Opto_Data.Mouse_Name,Mouse)==1 & (Opto_Data.Trial_ID==1 | Opto_Data.Trial_ID==0) & Opto_Data.Trial_Light==1);
        HR_ChR2=h_l/s_l;
        h_nl=sum(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Opto_Data.Mouse_Name,Mouse)==1 & Opto_Data.Trial_ID==1 & Opto_Data.Trial_Light==0);
        s_nl=sum(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Opto_Data.Mouse_Name,Mouse)==1 & (Opto_Data.Trial_ID==1 | Opto_Data.Trial_ID==0) & Opto_Data.Trial_Light==0);
        HR_noChR2=h_nl/s_nl;
              
        
        eval(['Hits.' Area '(i,:)=[HR_noChR2 HR_ChR2];'])        
        
        
    end
    %% PLot

    ax(1)=subplot(3,2,j);
    for i=1:size(Mouse_list,1)
        eval(['plot(Hits.' Area '(i,:),''Color'',[.5 0 0]);'])
        hold on
    end
    
    eval(['plot_mean.' Area '=mean(Hits.' Area ',1);'])
    eval(['plot_sd.' Area '=std(Hits.' Area ',[],1);'])
    eval(['p.' Area '=signrank(Hits.' Area '(:,1)'',Hits.' Area '(:,2)'');'])
    eval(['errorbar(plot_mean.' Area ',plot_sd.' Area ',''ro'',''Markersize'',12);'])
    
 
    set(gca,'ylim',[0 1]);
    set(gca,'XTick',1:5);
    set(gca,'XTickLabel',{'No Light';'Light'});

    eval(['xlabel([''p_{hit rate}='' num2str(p.' Area ')])'])
    title([Area ' (n=' num2str(size(Mouse_list,1)) ')'],'fontweight','bold','fontsize',12);
    
end

%%
fig2=figure;
for j=1:size(Areas,2)
        Area=char(Areas(j));
        Mouse_list=unique(Opto_Data.Mouse_Name(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1));

    
    for i=1:size(Mouse_list,1)
        Mouse=char(Mouse_list(i));
               
        fa_l=sum(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Opto_Data.Mouse_Name,Mouse)==1 & Opto_Data.Trial_ID==3 & Opto_Data.Trial_Light==1);
        ns_l=sum(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Opto_Data.Mouse_Name,Mouse)==1 & (Opto_Data.Trial_ID==2 | Opto_Data.Trial_ID==3) & Opto_Data.Trial_Light==1);
        FAR_ChR2=fa_l/ns_l;
        fa_nl=sum(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Opto_Data.Mouse_Name,Mouse)==1 & Opto_Data.Trial_ID==3 & Opto_Data.Trial_Light==0);
        ns_nl=sum(strcmp(Opto_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Opto_Data.Mouse_Name,Mouse)==1 & (Opto_Data.Trial_ID==2 | Opto_Data.Trial_ID==3) & Opto_Data.Trial_Light==0);        
        FAR_noChR2=fa_nl/ns_nl;
           
        eval(['False_alarms.' Area '(i,:)=[FAR_noChR2 FAR_ChR2];'])
        
        
    end
    %% PLot

    ax(1)=subplot(3,2,j);
    for i=1:size(Mouse_list,1)
        eval(['plot(False_alarms.' Area '(i,:),''Color'',[.5 .5 .5]);'])
        hold on
    end
       
    eval(['plot_mean2.' Area '=mean(False_alarms.' Area ',1);'])
    eval(['plot_sd2.' Area '=std(False_alarms.' Area ',[],1);'])
    eval(['p2.' Area '=signrank(False_alarms.' Area '(:,1)'',False_alarms.' Area '(:,2)'');'])
    eval(['errorbar(plot_mean2.' Area ',plot_sd2.' Area ',''blacko'',''Markersize'',12);'])
   
    set(gca,'ylim',[0 1]);
    set(gca,'XTick',1:5);
    set(gca,'XTickLabel',{'No Light';'Light'});

    eval(['xlabel([''p_{false alarm rate}='' num2str(p2.' Area ')])'])
    title([Area ' (n=' num2str(size(Mouse_list,1)) ')'],'fontweight','bold','fontsize',12);
    
end
%%
clear all