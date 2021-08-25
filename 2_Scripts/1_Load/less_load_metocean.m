function [METOCEAN] = less_load_metocean(SCENARIO, IN)
%% Function Description - less_load_metocean - JAM 30/11/20
% This function loads in the user specified metocean data for all DISCRETE
% Sites and/or for the the SPATIAL Region.

%% Inputs Description
% SCENARIO - Structure of Scenario data.
% IN       - Structure of Input data.

%% Outputs Description
% METOCEAN - Structure of Metocean data.
  
%% Load SPATIAL Region Data
if IN.RUN.SPATIAL
    disp('Loading SPATIAL metocean data...');
    disp(' - Loading DateTime...');
    DateTime_UTC = load(SCENARIO.Region.Region_MatFiles.Region_DateTime_UTC_MatFile{1});
    METOCEAN.SPATIAL.DateTime_UTC = DateTime_UTC.DateTime;
        
    
    disp(' - Loading Bathymetry XYZ data...');
    BathyXYZ_UTM_m = load(SCENARIO.Region.Region_MatFiles.Region_BathyXYZ_UTM_m_MatFile{1});    
    METOCEAN.SPATIAL.BathyXYZ_UTM_m = BathyXYZ_UTM_m.BathyXYZ_UTM_m;
    
    disp(' - Loading Depth data...');
    Depth_m = load(SCENARIO.Region.Region_MatFiles.Region_Depth_m_MatFile{1}); 
    METOCEAN.SPATIAL.Depth_m = Depth_m.Depth_m;
     
    disp(' - Loading Flow data...');
    Flow_Vel_Abs_DepAv_ms = load(SCENARIO.Region.Region_MatFiles.Region_Flow_Vel_Abs_DepAv_ms_MatFile{1});   
    METOCEAN.SPATIAL.Flow_Vel_Abs_DepAv_ms = Flow_Vel_Abs_DepAv_ms.Flow_Vel_Abs_DepAv_ms;
        
%     disp(' - Loading Wind data...');
%     Wind_Vel_Abs_U10_ms = load(SCENARIO.Region.Region_MatFiles.Region_Wind_Vel_Abs_U10_ms_MatFile{1});   
%     METOCEAN.SPATIAL.Wind_Vel_Abs_U10_ms = Wind_Vel_Abs_U10_ms.Wind_Vel_Abs_U10_ms;

    disp(' - Loading Wave data...');
    Wave_Hs_m = load(SCENARIO.Region.Region_MatFiles.Region_Wave_Hs_m_MatFile{1});
    METOCEAN.SPATIAL.Wave_Hs_m = Wave_Hs_m.Wave_Hs_m;
             
    disp (' % All SPATIAL metocean data loaded successfully.'); 

else
     warning('User has specified that SPATIAL calculation not be run.');
    
end

%% Load DISCRETE Sites Data
if IN.RUN.DISCRETE
    disp('Loading DISCRETE metocean data...');
    for r = 1:size(SCENARIO.Sites.Sites_Location,1)
        disp(' - Loading DateTime...');
        DateTime_UTC = load(SCENARIO.Sites.Sites_MatFiles.Sites_DateTime_UTC_MatFile{r});
        METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{r}).DateTime_UTC...
            = DateTime_UTC.DateTime;

        disp(' - Loading Depth data...');
        Depth_m = load(SCENARIO.Sites.Sites_MatFiles.Sites_Depth_m_MatFile{r});   
        METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{r}).Depth_m...
            = Depth_m.Depth_m;

        disp(' - Loading Flow data...');
        Flow_Vel_Abs_DepAv_ms = load(SCENARIO.Sites.Sites_MatFiles.Sites_Flow_Vel_Abs_DepAv_ms_MatFile{r});   
        METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{r}).Flow_Vel_Abs_DepAv_ms...
            = Flow_Vel_Abs_DepAv_ms.Flow_Vel_Abs_DepAv_ms;

%         disp(' - Loading Wind data...');
%         Wind_Vel_Abs_U10_ms = load(SCENARIO.Sites.Sites_MatFiles.Sites_Wind_Vel_Abs_U10_ms_MatFile{r}); 
%         METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{r}).Wind_Vel_Abs_U10_ms...
%             = Wind_Vel_Abs_U10_ms.Wind_Vel_Abs_U10_ms;

        disp(' - Loading Wave data...');
        Wave_Hs_m = load(SCENARIO.Sites.Sites_MatFiles.Sites_Wave_Hs_m_MatFile{r}); 
        METOCEAN.DISCRETE.(SCENARIO.Sites.Sites_Location.Sites_Name{r}).Wave_Hs_m...
            = Wave_Hs_m.Wave_Hs_m;
        
    end   
    disp (' % All DISCRETE metocean data loaded successfully.'); 
      
else
    warning('User has specified that DISCRETE calculation not be run.');
    
end

end
