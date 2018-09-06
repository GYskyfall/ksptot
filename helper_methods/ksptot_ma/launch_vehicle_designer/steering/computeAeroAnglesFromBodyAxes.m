function [bankAng,angOfAttack,angOfSideslip] = computeAeroAnglesFromBodyAxes(rVect, vVect, bodyX, bodyY, bodyZ)
    %Source: http://www.dept.aoe.vt.edu/~cdhall/courses/aoe5204/AircraftMotion.pdf

    [RVvlh2Inert, vvlh_x, ~, ~] = computeVvlhFrame(rVect,vVect);
    RVel2Vvlh = computeVelFrameInVvlhFrame(rVect, vVect, vvlh_x);
    Rtotal = horzcat(bodyX, bodyY, bodyZ);
    
    [bankAng,angOfAttack,angOfSideslip] = dcm2angle(RVel2Vvlh' * RVvlh2Inert' * Rtotal, 'xyz');
end