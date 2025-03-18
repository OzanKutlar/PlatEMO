function Offspring = OperatorBBBC(Problem,Best,Parameter)

%------------------------------- Reference --------------------------------

%------------------------------- Copyright --------------------------------
% Copyright (c) 2025 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    if nargin > 2
        [exp, Generation] = deal(Parameter{:});
    else
        [exp, Generation] = deal(1, 1);
    end
    if isa(Best(1),'SOLUTION')
        evaluated = true;
        Best    = Best.decs;
    else
        evaluated = false;
    end
    
    Offspring = bigBang_norm(Problem, Best, Problem.N, exp * Generation);

    if evaluated
        Offspring = Problem.Evaluation(Offspring);
    end
end


function [pop] = bigBang_norm(Problem, centerOfMass, n, g)
    mu = 0;
    sigma = 1;
    % generate normally distributed random numbers
    randomNumbers = normrnd(mu, sigma, [n, width(centerOfMass)]);
    
    % normalize the numbers to the range [-1, 1]
    minVal = min(randomNumbers); % find the minimum value
    maxVal = max(randomNumbers); % find the maximum value
    
    % normalize to [0, 1]
    normalizedNumbers = (randomNumbers - minVal) ./ (maxVal - minVal);
    
    % scale and shift to [-1, 1]
    scaledNumbers = 2 * normalizedNumbers - 1;

    pop = centerOfMass + ((Problem.upper-Problem.lower).*scaledNumbers)/g;
    pop = max(min(pop, Problem.upper), Problem.lower);
end


