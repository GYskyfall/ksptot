classdef ThrustForceModel < AbstractForceModel
    %ThrustForceModel Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = ThrustForceModel()
            
        end
        
        function forceVect = getForce(obj, stateLogEntry)
            [ut, rVect, vVect, ~, bodyInfo, ~] = obj.getParamsFromStateLogEntry(stateLogEntry);
            
            bodyThrust = [0;0;0];
            
            altitude = norm(rVect) - bodyInfo.radius;
            pressure = getPressureAtAltitude(bodyInfo, altitude);
            
            throttle = stateLogEntry.throttleModel.getThrottleAtTime(ut);
            body2InertDcm = stateLogEntry.steeringModel.getBody2InertialDcmAtTime(obj, ut, rVect, vVect);
            
            tankStates = obj.stateLogEntry.getAllTankStates();
            stageStates = obj.stateLogEntry.stageStates;
            for(i=1:length(stageStates)) %#ok<*NO4LP>
                stgState = stageStates(i);
                
                if(stgState.active)
                    engineStates = stgState.engineStates;

                    lv = stgState.stage.launchVehicle;
                    
                    for(j=1:length(engineStates))
                        engState = engineStates(j);
                        
                        if(engState.active)
                            engine = engState.engine;

                            tanks = lv.getTanksConnectedToEngine(engine); %connected tanks

                            propExistsInATank = false; 
                            for(k=1:length(tanks))
                                tank = tanks(k);
                                tankState = findobj(tankStates,'tank',tank);

                                if(tankState.tankMass > 0) %just check to make sure the engine is connected to fuel somewhere
                                    propExistsInATank = true; 
                                    break;
                                end
                            end
                            
                            if(propExistsInATank)
                                [thrust, ~] = engine.getThrustFlowRateForPressure(obj, pressure);
                                adjustedThrottle = engine.adjustThrottleForMinMax(throttle);
                                bodyThrust = bodyThrust + thrust * adjustedThrottle * engine.bodyFrameThrustVect;
                            end
                        end
                    end
                end
            end
            
            forceVect = body2InertDcm * bodyThrust;
        end
    end
end