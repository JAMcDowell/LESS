%% Installation - Anchor/Foundation
figure;
Device_LineTypes = {'g-','g-.',...
                    'b-','b--',...
                    'r-','r--',...
                    'm-','m--'};  

for d = [2,4,6]
    plot([OPERATIONS.DISCRETE.SITES.DEVICES(d).OPERATIONS(1).VESSELS(3).TotalStandbyTime.TotalStandbyTime_D],...
        Device_LineTypes{d},'linewidth',6); hold on;

end

legend('PLATO',...
       'PLATI',...
       'HBMT',...
       'location','best','Interpreter', 'none');
   
set(gca,'XTick',1:12)
set(gca, 'XTickLabel',monthnum2name(get(gca,'XTick'),'Short'),...           
        'FontSize',FontSize_Axes);  
    
xlim([1,12]); 
ylim([0 31]);

xlabel('Month',...
   'FontSize',FontSize_Axes);
ylabel('Standby Days',...
   'FontSize',FontSize_Axes);  
title({'Total Standby Days:',...
       'Anchor Installation at FORCE Site'},...
       'FontSize',FontSize_Axes);
set(gca, 'FontSize',FontSize_Axes);   

fig2fullscreen;

%% Installation - Cable Laying
figure;
Device_LineTypes = {'g-','g-.',...
                    'b-','b--',...
                    'r-','r--',...
                    'm-','m--'};  

for d = [2,4,6]
    plot([OPERATIONS.DISCRETE.SITES.DEVICES(d).OPERATIONS(2).VESSELS(3).TotalStandbyTime.TotalStandbyTime_D],...
        Device_LineTypes{d},'linewidth',6); hold on;

end

legend('PLATO',...
       'PLATI',...
       'HBMT',...
       'location','best','Interpreter', 'none');
   
set(gca,'XTick',1:12)
set(gca, 'XTickLabel',monthnum2name(get(gca,'XTick'),'Short'),...           
        'FontSize',FontSize_Axes);      
    
xlim([1,12]); 
ylim([0 31]);

xlabel('Month',...
   'FontSize',FontSize_Axes);
ylabel('Standby Days',...
   'FontSize',FontSize_Axes);  
title({'Total Standby Days:',...
       'Cable Laying Installation at FORCE Site'},...
       'FontSize',FontSize_Axes);
set(gca, 'FontSize',FontSize_Axes);   

fig2fullscreen;

%% Installation - Device Connection
figure;
Device_LineTypes = {'g-','g-.',...
                    'b-','b--',...
                    'r-','r--',...
                    'm-','m--'};  

for d = [2,4,6]
    plot([OPERATIONS.DISCRETE.SITES.DEVICES(d).OPERATIONS(3).VESSELS(3).TotalStandbyTime.TotalStandbyTime_D],...
        Device_LineTypes{d},'linewidth',6); hold on;

end

legend('PLATO',...
       'PLATI',...
       'HBMT',...
       'location','best','Interpreter', 'none');
   
set(gca,'XTick',1:12)
set(gca, 'XTickLabel',monthnum2name(get(gca,'XTick'),'Short'),...           
        'FontSize',FontSize_Axes);      
    
xlim([1,12]); 
ylim([0 31]);

xlabel('Month',...
   'FontSize',FontSize_Axes);
ylabel('Standby Days',...
   'FontSize',FontSize_Axes);  
title({'Total Standby Days:',... 
       'Device Connection Installation at FORCE Site'},...
       'FontSize',FontSize_Axes);
set(gca, 'FontSize',FontSize_Axes);   

fig2fullscreen;

%% Maintenance - Minor
figure;
Device_LineTypes = {'g-','g-.',...
                    'b-','b--',...
                    'r-','r--',...
                    'm-','m--'};  

for d = [2,4,6]
    plot([OPERATIONS.DISCRETE.SITES.DEVICES(d).OPERATIONS(4).VESSELS(3).TotalStandbyTime.TotalStandbyTime_D],...
        Device_LineTypes{d},'linewidth',6); hold on;

end

legend('PLATO',...
       'PLATI',...
       'HBMT',...
       'location','best','Interpreter', 'none');
   
set(gca,'XTick',1:12)
set(gca, 'XTickLabel',monthnum2name(get(gca,'XTick'),'Short'),...           
        'FontSize',FontSize_Axes);      
    
xlim([1,12]); 
ylim([0 31]);

xlabel('Month',...
   'FontSize',FontSize_Axes);
ylabel('Standby Days',...
   'FontSize',FontSize_Axes);  
title({'Total Standby Days:',... 
       'Minor Maintenance at FORCE Site'},...
       'FontSize',FontSize_Axes);
set(gca, 'FontSize',FontSize_Axes);   

fig2fullscreen;

%% Maintenance - Major
figure;
Device_LineTypes = {'g-','g-.',...
                    'b-','b--',...
                    'r-','r--',...
                    'm-','m--'};  

for d = [2,4,6]
    plot([OPERATIONS.DISCRETE.SITES.DEVICES(d).OPERATIONS(5).VESSELS(3).TotalStandbyTime.TotalStandbyTime_D],...
        Device_LineTypes{d},'linewidth',6); hold on;

end

legend('PLATO',...
       'PLATI',...
       'HBMT',...
       'location','best','Interpreter', 'none');
   
set(gca,'XTick',1:12)
set(gca, 'XTickLabel',monthnum2name(get(gca,'XTick'),'Short'),...           
        'FontSize',FontSize_Axes);      
    
xlim([1,12]); 
ylim([0 31]);

xlabel('Month',...
   'FontSize',FontSize_Axes);
ylabel('Standby Days',...
   'FontSize',FontSize_Axes);  
title({'Total Standby Days:',... 
       'Major Maintenance at FORCE Site'},...
       'FontSize',FontSize_Axes);
set(gca, 'FontSize',FontSize_Axes);   

fig2fullscreen;

%% Decommissioning - Device Disconnection
figure;
Device_LineTypes = {'g-','g-.',...
                    'b-','b--',...
                    'r-','r--',...
                    'm-','m--'};  

for d = [2,4,6]
    plot([OPERATIONS.DISCRETE.SITES.DEVICES(d).OPERATIONS(6).VESSELS(3).TotalStandbyTime.TotalStandbyTime_D],...
        Device_LineTypes{d},'linewidth',6); hold on;

end

legend('PLATO',...
       'PLATI',...
       'HBMT',...
       'location','best','Interpreter', 'none');
   
set(gca,'XTick',1:12)
set(gca, 'XTickLabel',monthnum2name(get(gca,'XTick'),'Short'),...           
        'FontSize',FontSize_Axes);      
    
xlim([1,12]); 
ylim([0 31]);

xlabel('Month',...
   'FontSize',FontSize_Axes);
ylabel('Standby Days',...
   'FontSize',FontSize_Axes);  
title({'Total Standby Days:',... 
       'Device Disconnection Decommissioning at FORCE Site'},...
       'FontSize',FontSize_Axes);
set(gca, 'FontSize',FontSize_Axes);   

fig2fullscreen;

%% Decommissioning - Cable Retrieval
figure;
Device_LineTypes = {'g-','g-.',...
                    'b-','b--',...
                    'r-','r--',...
                    'm-','m--'};  

for d = [2,4,6]
    plot([OPERATIONS.DISCRETE.SITES.DEVICES(d).OPERATIONS(7).VESSELS(3).TotalStandbyTime.TotalStandbyTime_D],...
        Device_LineTypes{d},'linewidth',6); hold on;

end

legend('PLATO',...
       'PLATI',...
       'HBMT',...
       'location','best','Interpreter', 'none');
   
set(gca,'XTick',1:12)
set(gca, 'XTickLabel',monthnum2name(get(gca,'XTick'),'Short'),...           
        'FontSize',FontSize_Axes);      
    
xlim([1,12]); 
ylim([0 31]);

xlabel('Month',...
   'FontSize',FontSize_Axes);
ylabel('Standby Days',...
   'FontSize',FontSize_Axes);  
title({'Total Standby Days:',... 
       'Cable Retrieval Decommissioning at FORCE Site'},...
       'FontSize',FontSize_Axes);
set(gca, 'FontSize',FontSize_Axes);   

fig2fullscreen;

%% Decommissioning - Anchor Retrieval
figure;
Device_LineTypes = {'g-','g-.',...
                    'b-','b--',...
                    'r-','r--',...
                    'm-','m--'};  

for d = [2,4,6]
    plot([OPERATIONS.DISCRETE.SITES.DEVICES(d).OPERATIONS(8).VESSELS(3).TotalStandbyTime.TotalStandbyTime_D],...
        Device_LineTypes{d},'linewidth',6); hold on;

end

legend('PLATO',...
       'PLATI',...
       'HBMT',...
       'location','best','Interpreter', 'none');
   
set(gca,'XTick',1:12)
set(gca, 'XTickLabel',monthnum2name(get(gca,'XTick'),'Short'),...           
        'FontSize',FontSize_Axes);      
    
xlim([1,12]); 
ylim([0 31]);

xlabel('Month',...
   'FontSize',FontSize_Axes);
ylabel('Standby Days',...
   'FontSize',FontSize_Axes);  
title({'Total Standby Days:',... 
       'Anchor Retrieval Decommissioning at FORCE Site'},...
       'FontSize',FontSize_Axes);
set(gca, 'FontSize',FontSize_Axes);   

fig2fullscreen;
