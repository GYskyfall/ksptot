classdef ThrustForceModel < AbstractForceModel
    %ThrustForceModel Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = ThrustForceModel()
            
        end
        
        function [forceVect, tankMdots] = getForce(obj, ut, rVect, vVect, ~, bodyInfo, ~, throttleModel, steeringModel, tankStates, stageStates, lvState, dryMass, tankStatesMasses)    
            altitude = norm(rVect) - bodyInfo.radius;
            pressure = getPressureAtAltitude(bodyInfo, altitude);
            throttle = throttleModel.getThrottleAtTime(ut, rVect, vVect, tankStatesMasses, dryMass, stageStates, lvState, tankStates, bodyInfo);
            
            [tankMdots, ~, forceVect] = LaunchVehicleStateLogEntry.getTankMassFlowRatesDueToEngines(tankStates, tankStatesMasses, stageStates, throttle, lvState, pressure, ut, rVect, vVect, bodyInfo, steeringModel);
            
%             bodyThrust = [0;0;0];
%             
%             altitude = norm(rVect) - bodyInfo.radius;
%             pressure = getPressureAtAltitude(bodyInfo, altitude);
%             
%             throttle = throttleModel.getThrottleAtTime(ut, rVect, vVect, tankStatesMasses, dryMass, stageStates, lvState, tankStates, bodyInfo);
%             
%             tanksForTankStates = [tankStates.tank];
%             
%             for(i=1:length(stageStates)) %#ok<*NO4LP>
%                 stgState = stageStates(i);
%                 
%                 if(stgState.active)
%                     engineStates = stgState.engineStates;
%                     
%                     for(j=1:length(engineStates))
%                         engState = engineStates(j);
%                         
%                         if(engState.active)
%                             engine = engState.engine;
% 
%                             tanks = lvState.getTanksConnectedToEngine(engine); %connected tanks
% 
%                             propExistsInATank = false; 
%                             for(k=1:length(tanks))
%                                 tank = tanks(k);
%                                 tankState = tankStates(tanksForTankStates == tank);
% 
%                                 if(tankState.tankMass > 0) %just check to make sure the engine is connected to fuel somewhere
%                                     propExistsInATank = true; 
%                                     break;
%                                 end
%                             end
%                             
%                             if(propExistsInATank)                                
%                                 [thrust, ~] = engine.getThrustIspForPressure(pressure);
%                                 adjustedThrottle = engine.adjustThrottleForMinMax(throttle);
%                                 bodyThrust = bodyThrust + (thrust * adjustedThrottle * engine.bodyFrameThrustVect)/1000; %1/1000 to convert kN=mT*m/s^2 to mT*km/s^2 (see also ma_executeDVManeuver_finite_inertial()) 
%                             end
%                         end
%                     end
%                 end
%             end
%             
%             if(norm(bodyThrust) > 0)
%                 body2InertDcm = steeringModel.getBody2InertialDcmAtTime(ut, rVect, vVect, bodyInfo);
%                 forceVect = body2InertDcm * bodyThrust;
%             else
%                 forceVect = [0;0;0];
%             end
        end
    end
end