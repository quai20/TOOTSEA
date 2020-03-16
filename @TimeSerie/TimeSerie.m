%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
classdef TimeSerie
    %TS OOP Matlab   
    properties
        Name;
        Time;
        Data;        
        Depth;
        QC_Serie;
        Unit;
        Long_name;
        Comment;
        FillValue;
        ValidMin;
        ValidMax;
        dT;
        dTi;
        p2p;
        calc;
    end  
    methods                     
        %CONSTRUCTOR 
        function obj=TimeSerie(MName,Time2Store,Data2Store)
            if nargin~=3
                error('Usage : TimeSerie(Name,Data,Time)');
            end
            if length(Data2Store)~=length(Time2Store)
                error('Size Error');
            end
            obj.Name=MName;
            obj.Time=Time2Store(:)';
            msi=size(Data2Store);
            if(msi(1)>msi(2))
                Data2Store=Data2Store';
            end
            obj.Data=Data2Store;                                     
            obj.Depth=[];
            obj.QC_Serie=obj.Data.*0;
            obj.Unit='not set';
            obj.Long_name='not set';
            %obj.Comment='not set';
            obj.FillValue=999999;
            obj.ValidMin=[];
            obj.ValidMax=[];
            obj.calc=[];
            
            %pk2pk Calculation
            obj.p2p = 0;
            for i=1:size(obj.Data,1)
                if(max(obj.Data(i,:))-min(obj.Data(i,:)) > obj.p2p)
                obj.p2p=max(obj.Data(i,:))-min(obj.Data(i,:));
                end                
            end
            
            %dT CALCULATION, IF IRREGULAR, dT=0 
            dTime=etime(datevec(obj.Time(2:end)),datevec(obj.Time(1:end-1)));            
            if(std(dTime) == 0) %If dT regular, dT=dT
              obj.dT=dTime(1);
              obj.dTi=obj.dT;
            else %if dT unregular, dT=0
            obj.dT=0;
            obj.dTi=mode(dTime);
            end                                    
        end        
        %PLOTTING METHOD
        plha=Plot(obj,paxes)                                  
        %SUBSERIE
        obss=Subserie(obj,name,t1,t2,lev)        
        %SPECTRUM
        tspectrum(obj,dt,WINDOW,NOVERL,NFFT,CONFL,lev,qcone,intrp)        
    end    
end

