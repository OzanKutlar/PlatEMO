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
        function main(Algorithm,Problem)
            %% Parameter setting
            [expansionSpeed] = Algorithm.ParameterSet(1);
            
            %% Generate random population
            Population = Problem.Initialization();
            
            %% Optimization
            while Algorithm.NotTerminated(Population)
                Best = TournamentSelection(2,5,FitnessSingle(Population));
                Population  = OperatorBBBC(Problem,Population(Best(1)),{expansionSpeed});
            end
        end
    end
end