classdef BBBC < ALGORITHM
% <1992> <single> <real/integer/label/binary/permutation> <large/none> <constrained/none>
% Big Bang-Big Crunch

%------------------------------- Reference --------------------------------
% Erol, Osman K., and Ibrahim Eksin. "A new optimization method: big bang–big crunch.",
% Advances in engineering software 37.2 (2006): 106-111
%------------------------------- Copyright --------------------------------
% Copyright (c) 2025 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    methods
        function main(Algorithm, Problem)
            %% Parameter setting
            [expansionSpeed] = Algorithm.ParameterSet(100);
            
            %% Generate initial population
            Population = Problem.Initialization();
            Generation = 0;
            
            %% Optimization loop
            while Algorithm.NotTerminated(Population)
                Generation = Generation + 1;
                % Pass the entire population so the center of mass can be computed
                Population = OperatorBBBC(Problem, Population, {1, Generation});
                if mod(Generation, 10) == 0 || Generation < 5
                    DisplayTopFitnesses(Population, Generation);
                end
            end
        end
    end
end
