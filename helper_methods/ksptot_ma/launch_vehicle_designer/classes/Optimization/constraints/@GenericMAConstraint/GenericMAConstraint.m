classdef GenericMAConstraint < AbstractConstraint
    %GenericMAConstraint Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        constraintType(1,:) char = '';
        normFact = 1;
        event(1,:) LaunchVehicleEvent
        
        lb(1,1) double = 0;
        ub(1,1) double = 0;
        
        refStation(1,:) struct
        refOtherSC(1,:) struct
        refBodyInfo(1,:) KSPTOT_BodyInfo
    end
    
    methods
        function obj = GenericMAConstraint(constraintType, event, lb, ub, refStation, refOtherSC, refBodyInfo)
            obj.constraintType = constraintType;
            obj.event = event;
            obj.lb = lb;
            obj.ub = ub;
            obj.refStation = refStation;
            obj.refOtherSC = refOtherSC;
            obj.refBodyInfo = refBodyInfo;         
        end
        
        function [lb, ub] = getBounds(obj)
            lb = obj.lb;
            ub = obj.ub;
        end
        
        function [c, ceq, value, lwrBnd, uprBnd, type, eventNum] = evalConstraint(obj, stateLog, maData)
            celBodyData = maData.celBodyData;
            
            stateLogEntry = stateLog.getLastStateLogForEvent(obj.event).getMAFormattedStateLogMatrix();
            type = obj.constraintType;
            
            refBodyId = obj.refBodyInfo.id;
            
            oscId = -1;
            if(not(isempty(obj.refOtherSC)))
                oscId = obj.refOtherSC.id;
            end
            
            stnId = -1;
            if(not(isempty(obj.refStation)))
                stnId = obj.refStation.id;
            end
            
            propNames = maData.spacecraft.propellant.names;
            value = ma_getDepVarValueUnit(1, stateLogEntry, type, 0, refBodyId, oscId, stnId, propNames, maData, celBodyData, false);
                       
            if(obj.lb == obj.ub)
                c = [];
                ceq(1) = value - obj.ub;
            else
                c(1) = obj.lb - value;
                c(2) = value - obj.ub;
                ceq = [];
            end
            c = c/obj.normFact;
            ceq = ceq/obj.normFact;  
            
            lwrBnd = obj.lb;
            uprBnd = obj.ub;
            
            eventNum = obj.event.getEventNum();
        end
        
        function tf = usesStage(obj, stage)
            tf = false;
        end
        
        function tf = usesEngine(obj, engine)
            tf = false;
        end
        
        function tf = usesTank(obj, tank)
            tf = false;
        end
        
        function tf = usesEngineToTankConn(obj, engineToTank)
            tf = false;
        end
        
        function name = getName(obj)
            name = sprintf('%s - Event %i', obj.constraintType, obj.event.getEventNum());
        end
        
        function [unit, lbLim, ubLim, usesLbUb, usesCelBody, usesRefSc] = getConstraintStaticDetails(obj)
            [unit, lbLim, ubLim, ~, ~, ~, ~, usesLbUb, usesCelBody, usesRefSc] = ma_getConstraintStaticDetails(obj.constraintType);           
        end
        
        function addConstraintTf = openEditConstraintUI(obj, maData, lvdData, hMaMainGUI)
            addConstraintTf = lvd_EditGenericMAConstraintGUI(obj, maData, lvdData, hMaMainGUI);
        end
    end
    
    methods(Static)
        function constraint = getDefaultConstraint(constraintType)            
            constraint = GenericMAConstraint(constraintType, LaunchVehicleEvent.empty(1,0), 0, 0, [], [], KSPTOT_BodyInfo.empty(1,0));
        end
    end
end






%             switch type
%                 case {'ut'}
%                     value = ma_TimeTask(stateLogEntry, type, celBodyData);
%                 case {'rX','rY','rZ','vX','vY','vZ','rNorm','vNorm'}
%                     value = ma_GAVectorElementsTask(stateLogEntry, type, celBodyData);
%                 case {'sma','ecc','inc','raan','arg','tru','mean','period','sunRX','sunRY','sunRZ','rPe','rAp','altPe','altAp','betaAngle'}
%                     value = ma_GAKeplerElementsTask(stateLogEntry, type, celBodyData);
%                 case {'Elevation'}
%                     value = ma_GAAzElRangeTasks(stateLogEntry, type, obj.refStation, celBodyData);
%                 case {'CB_ID'}
%                     value = ma_GACentralBodyTasks(stateLogEntry, type, celBodyData);
%                 case {'distToCelBody'}
%                     value = ma_GADistToCelBodyTask(stateLogEntry, type, obj.refBodyInfo, celBodyData);
%                 case {'distToRefSC','relVelToCelBody','relPositionInTrack','relPositionCrossTrack','relPositionRadial','relPositionInTrackOScCentered','relPositionCrossTrackOScCentered','relPositionRadialOScCentered','relSma','relEcc','relInc','relRaan','relArg'}
%                     value = ma_GADistToRefSCTask(stateLogEntry, type, obj.refOtherSC, celBodyData);
%                 case {'distToRefStn'}
%                     value = ma_GADistToRefStationTask(stateLogEntry, type, obj.refStation, celBodyData);
%                 case {'Eclipse','OtherSC_LOS','Station_LOS'}
%                     value = ma_GAEclipseTask(stateLogEntry, type, obj.refOtherSC, obj.refStation, celBodyData);
%                 case {'H1','K1','H2','K2'}
%                     value = ma_GAEquinoctialElementsTask(stateLogEntry, type, celBodyData);
%                 case {'long','lat','driftRate','horzVel','vertVel'}
%                     value = ma_GALongLatAltTasks(stateLogEntry, type, celBodyData);
%                 case {'fuelOx','monoprop','xenon','dry','total'}
%                     value = ma_GASpacecraftMassTasks(stateLogEntry, type, celBodyData);
%                 case {'X','Y','Z','mag','RA','Dec'}
%                     value = ma_OutboundHyperVelVectTask(stateLogEntry, type, celBodyData);
%             end