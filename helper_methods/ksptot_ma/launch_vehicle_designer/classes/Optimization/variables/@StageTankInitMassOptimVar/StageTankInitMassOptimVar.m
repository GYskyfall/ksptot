classdef StageTankInitMassOptimVar < AbstractOptimizationVariable
    %StageTankInitMassOptimVar Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tank(1,:) LaunchVehicleTank
        
        lwrBnd(1,1) double = 0;
        uprBnd(1,1) double = 0;
        
        useTf(1,1) = false;
    end
    
    methods
        function obj = StageTankInitMassOptimVar(tank)
            obj.tank = tank;
            obj.tank.optVar = obj;
            
            obj.id = rand();
        end
        
        function x = getXsForVariable(obj)
            x = obj.tank.initialMass;
        end
        
        function [lb, ub] = getBndsForVariable(obj)
            lb = obj.lwrBnd;
            ub = obj.uprBnd;
        end
        
        function setBndsForVariable(obj, lb, ub)
            obj.lwrBnd = lb;
            obj.uprBnd = ub;
        end
        
        function useTf = getUseTfForVariable(obj)
            useTf = obj.useTf;
        end
        
        function setUseTfForVariable(obj, useTf)
            obj.useTf = useTf;
        end
        
        function updateObjWithVarValue(obj, x)
            if(any(isnan(x)))
                a = 1;
            end
            
            obj.tank.initialMass = x;
        end
    end
end