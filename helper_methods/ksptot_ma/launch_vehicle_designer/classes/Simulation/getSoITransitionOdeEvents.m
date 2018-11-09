function [value, isterminal, direction, causes] = getSoITransitionOdeEvents(ut, rVect, bodyInfo, celBodyData)
        value = [];
        isterminal = [];
        direction = [];
        causes = AbstractIntegrationTerminationCause.empty(0,1);
            
        %Max Radius (SoI Radius) Constraint (Leave SOI Upwards)
        parentBodyInfo = getParentBodyInfo(bodyInfo, celBodyData);
        rSOI = getSOIRadius(bodyInfo, parentBodyInfo);
        radius = norm(rVect);

        if(isempty(parentBodyInfo))
            parentBodyInfo = KSPTOT_BodyInfo.empty(0,1);
        end

        value(end+1) = rSOI - radius;
        isterminal(end+1) = 1;
        direction(end+1) = -1;
        causes(end+1) = SoITransitionUpIntTermCause(bodyInfo, parentBodyInfo, celBodyData);    

        %Leave SoI Downwards
        children = getChildrenOfParentInfo(celBodyData, bodyInfo.name);
        for(i=1:length(children)) %#ok<*NO4LP>
            childBodyInfo = children{i};

            dVect = getAbsPositBetweenSpacecraftAndBody(ut, rVect, bodyInfo, childBodyInfo, celBodyData);
            distToChild = norm(dVect);

            rSOI = getSOIRadius(childBodyInfo, bodyInfo);

            value(end+1) = distToChild - rSOI; %#ok<AGROW>
            isterminal(end+1) = 1; %#ok<AGROW>
            direction(end+1) = -1; %#ok<AGROW>
            causes(end+1) = SoITransitionDownIntTermCause(bodyInfo, childBodyInfo, celBodyData); %#ok<AGROW>
        end    
end