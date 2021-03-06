classdef ConstraintSet < matlab.mixin.SetGet
    %ConstraintSet Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        consts(1,:) AbstractConstraint
        
        lvdOptim LvdOptimization
        lvdData LvdData
        
        lastRunValues ConstraintValues
    end
    
    methods
        function obj = ConstraintSet(lvdOptim, lvdData)
            obj.consts = AbstractConstraint.empty(1,0);
            obj.lastRunValues = ConstraintValues();
            
            if(nargin > 0)
                obj.lvdOptim = lvdOptim;
                obj.lvdData = lvdData;   
            end
        end
        
        function addConstraint(obj, newConst)
            obj.consts(end+1) = newConst;
        end
        
        function removeConstraint(obj, const)
            obj.consts(obj.consts == const) = [];
        end      
        
        function constraint = getConstraintForInd(obj, ind)
            constraint = AbstractConstraint.empty(1,0);
            
            if(ind >= 1 && ind <= length(obj.consts))
                constraint = obj.consts(ind);
            end
        end
        
        function listBoxStr = getListboxStr(obj)
            listBoxStr = {};
            
            for(i=1:length(obj.consts))
                listBoxStr{end+1} = obj.consts(i).getName(); %#ok<AGROW>
            end
        end
        
        function num = getNumConstraints(obj)
            num = length(obj.consts);
        end
        
        function [c, ceq, value, lb, ub, type, eventNum, cEventInds, ceqEventInds] = evalConstraints(obj, x, tfRunScript, evtToStartScriptExecAt)
            c = [];
            ceq = [];
            value = [];
            lb = [];
            ub = [];
            type = {};
            eventNum = [];
            cEventInds = [];
            ceqEventInds = [];
            
            celBodyData = obj.lvdData.celBodyData;
            
            if(~isempty(obj.consts))
                if(tfRunScript == true)                   
                    obj.lvdOptim.vars.updateObjsWithScaledVarValues(x);
                    stateLog = obj.lvdData.script.executeScript(true, evtToStartScriptExecAt, false);
                else
                    stateLog = obj.lvdData.stateLog;
                end

                for(i=1:length(obj.consts)) %#ok<*NO4LP>
                    constraint = obj.consts(i);
                    
                    if(obj.isEventOptimDisabled(constraint))
                        continue;
                    end
                    
                    [c1, ceq1, value1, lb1, ub1, type1, eventNum1] = constraint.evalConstraint(stateLog, celBodyData);

                    for(j=1:length(c1))
                        cEventInds(end+1) = eventNum1; %#ok<AGROW>
                    end
                    
                    for(j=1:length(ceq1))
                        ceqEventInds(end+1) = eventNum1; %#ok<AGROW>
                    end
                    
                    c   = [c, c1]; %#ok<AGROW>
                    ceq = [ceq, ceq1]; %#ok<AGROW>
                    value = [value, value1]; %#ok<AGROW>
                    lb = [lb, lb1]; %#ok<AGROW>
                    ub = [ub, ub1]; %#ok<AGROW>
                    type = horzcat(type, type1); %#ok<AGROW>
                    eventNum = [eventNum, eventNum1]; %#ok<AGROW>
                end
            end
        end
        
        function tf = usesStage(obj, stage)
            tf = false;
            
            for(i=1:length(obj.consts))
                tf = tf || obj.consts(i).usesStage(stage);
            end
        end
        
        function tf = usesEngine(obj, engine)
            tf = false;
            
            for(i=1:length(obj.consts))
                tf = tf || obj.consts(i).usesEngine(engine);
            end
        end
        
        function tf = usesTank(obj, tank)
            tf = false;
            
            for(i=1:length(obj.consts))
                tf = tf || obj.consts(i).usesTank(tank);
            end
        end
        
        function tf = usesEngineToTankConn(obj, engineToTank)
            tf = false;
            
            for(i=1:length(obj.consts))
                tf = tf || obj.consts(i).usesEngineToTankConn(engineToTank);
            end
        end
        
        function tf = usesStopwatch(obj, stopwatch)
            tf = false;
            
            for(i=1:length(obj.consts))
                tf = tf || obj.consts(i).usesStopwatch(stopwatch);
            end
        end
        
        function removeConstraintsThatUseEvent(obj, event)
            indsToRemove = [];
            for(i=1:length(obj.consts))
                c = obj.consts(i);
                
                if(c.usesEvent(event))
                    indsToRemove(end+1) = i; %#ok<AGROW>
                end
            end
            
            for(i=length(indsToRemove):-1:1)
                indToRemove = indsToRemove(i);
                c = obj.consts(indToRemove);
                obj.removeConstraint(c);
            end
        end
    end
    
    methods(Access=private)
        function tf = isEventOptimDisabled(obj, constraint)
            tf = false;
            
            event = constraint.getConstraintEvent();
            if(not(isempty(event)))
                if(not(isempty(event)) && event.disableOptim == true)
                    tf = true;
                end
            end
        end
    end
end