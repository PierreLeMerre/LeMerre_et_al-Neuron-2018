%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script that plots the results presented in figure S4.B.
%
% Written by Pierre Le Merre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Matrices
if exist('Mus_Data','var')==0 || exist('Mus_Data_description','var')==0
[PathDatabase,Mus_Data,Mus_Data_description]=Load_Pharmacological_Inactivation_database;
end

%% Parameters
Areas={'wS1','wS2','wM1','PtA','dCA1','mPFC'};
for j=1:size(Areas,2)
        Area=char(Areas(j));
        Mouse_list=unique(Mus_Data.Mouse_Name(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Mus')==1));

    
    for i=1:size(Mouse_list,1)
        Mouse=char(Mouse_list(i));        
        hit=sum(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Name,Mouse)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Mus')==1 & Mus_Data.Trial_ID==1);
        s=sum(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Name,Mouse)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Mus')==1 & (Mus_Data.Trial_ID==1 | Mus_Data.Trial_ID==0));
        eval(['HR_Mus.' Area '(i,:)=hit/s;'])
        
        fa=sum(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Name,Mouse)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Mus')==1 & Mus_Data.Trial_ID==3);
        ns=sum(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Name,Mouse)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Mus')==1 & (Mus_Data.Trial_ID==2 | Mus_Data.Trial_ID==3));
        eval(['FAR_Mus.' Area '(i,:)=fa/ns;'])
    end
end

Areas={'wS1','wS2','wM1','PtA','mPFC'};
for j=1:size(Areas,2)
        Area=char(Areas(j));
        Mouse_list=unique(Mus_Data.Mouse_Name(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Rin')==1));

    
    for i=1:size(Mouse_list,1)
        Mouse=char(Mouse_list(i));
        
        hit=sum(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Name,Mouse)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Rin')==1 & Mus_Data.Trial_ID==1);
        s=sum(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Name,Mouse)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Rin')==1 & (Mus_Data.Trial_ID==1 | Mus_Data.Trial_ID==0));
         eval(['HR_Rin.' Area '(i,:)=hit/s;'])
        
        fa=sum(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Name,Mouse)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Rin')==1 & Mus_Data.Trial_ID==3);
        ns=sum(strcmp(Mus_Data.Mouse_InactivatedArea,Area)==1 & strcmp(Mus_Data.Mouse_Name,Mouse)==1 & strcmp(Mus_Data.Mouse_Drug(:,1),'Rin')==1 & (Mus_Data.Trial_ID==2 | Mus_Data.Trial_ID==3));
        eval(['FAR_Rin.' Area '(i,:)=fa/ns;'])

    end
end


       

 



%% Plot Pharmacological inactivation data
Hit_Rin=[HR_Rin.wS1 ; HR_Rin.wS2 ; HR_Rin.wM1 ; HR_Rin.PtA ; HR_Rin.mPFC];
FA_Rin=[FAR_Rin.wS1 ; FAR_Rin.wS2 ; FAR_Rin.wM1 ; FAR_Rin.PtA ; FAR_Rin.mPFC];
plot_HR=mean(Hit_Rin,1);
plot_FAR=mean(FA_Rin,1);
plot_SD_HR=std(Hit_Rin,[],1)/sqrt(size(Hit_Rin,1));
plot_SD_FAR=std(FA_Rin,[],1)/sqrt(size(FA_Rin,1));

Areas={'wS1','wS2','wM1','PtA','dCA1','mPFC'};
for j=1:size(Areas,2)
    Area=char(Areas(j));
    eval(['plot_HR=[plot_HR mean(HR_Mus.' Area ',1)];'])
    eval(['plot_FAR=[plot_FAR mean(FAR_Mus.' Area ',1)];'])
    eval(['n_size(j)=[size(HR_Mus.' Area ',1)];'])
    eval(['plot_SD_HR=[plot_SD_HR std(HR_Mus.' Area ',[],1)/sqrt(size(HR_Mus.' Area ',1))];'])
    eval(['plot_SD_FAR=[plot_SD_FAR std(FAR_Mus.' Area ',[],1)/sqrt(size(HR_Mus.' Area ',1))];'])
end
figure
errorbar([0  plot_HR  0],[0  plot_SD_HR  0],'r','LineStyle','none','Marker','o')
hold on
errorbar([0  plot_FAR  0],[0  plot_SD_FAR  0],'k','LineStyle','none','Marker','o')
NumTicks = 8;
set(gca,'XTick',linspace(1,NumTicks,NumTicks))
set(gca,'XTickLabel',{'','Rin (n=12)',['wS1 (n=' num2str(n_size(1)) ')'],['wS2 (n=' num2str(n_size(2)) ')'],['wM1 (n=' num2str(n_size(3)) ')']...
    ,['PtA (n=' num2str(n_size(4)) ')'],['dCA1 (n=' num2str(n_size(5)) ')'],['mPFC (n=' num2str(n_size(6)) ')'],''})
y=ylabel('p(Lick)');
ylim([0 1]);
title('Muscimol injections 5min bloc, 30min after injection' ,'fontweight','bold','fontsize',12,'fontname','times new roman');

p1=ranksum(Hit_Rin,HR_Mus.wS1);
p2=ranksum(Hit_Rin,HR_Mus.wS2);
p3=ranksum(Hit_Rin,HR_Mus.wM1);
p4=ranksum(Hit_Rin,HR_Mus.PtA);
p5=ranksum(Hit_Rin,HR_Mus.dCA1);
p6=ranksum(Hit_Rin,HR_Mus.mPFC);

p_fa_1=ranksum(FA_Rin,FAR_Mus.wS1);
p_fa_2=ranksum(FA_Rin,FAR_Mus.wS2);
p_fa_3=ranksum(FA_Rin,FAR_Mus.wM1);
p_fa_4=ranksum(FA_Rin,FAR_Mus.PtA);
p_fa_5=ranksum(FA_Rin,FAR_Mus.dCA1);
p_fa_6=ranksum(FA_Rin,FAR_Mus.mPFC);

%% Bonferoni- Holm correction for p_values
[corrected_p_hr,~]=bonf_holm([p1 p2 p3 p4 p5 p6]);
[corrected_p_fa,~]=bonf_holm([p_fa_1 p_fa_2 p_fa_3 p_fa_4 p_fa_5 p_fa_6]);

%%

clear all
   