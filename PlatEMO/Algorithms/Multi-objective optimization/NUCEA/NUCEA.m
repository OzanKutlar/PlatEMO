classdef NUCEA < ALGORITHM
% <2023> <multi> <real/binary> <large/none> <constrained/none> <sparse>
% Non-uniform clustering based evolutionary algorithm

%------------------------------- Reference --------------------------------
% S. Shao, Y. Tian, and X. Zhang. A non-uniform clustering based
% evolutionary algorithm for solving large-scale sparse multi-objective
% optimization problems. Proceedings of the 18th International Conference
% on Bio-inspired Computing: Theories and Applications, 2023.
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
            %% Population initialization
            % Calculate the fitness of each decision variable
            TDec    = [];
            TMask   = [];
            TempPop = [];
            Fitness = zeros(1,Problem.D);
            for i = 1 : 1+4*any(Problem.encoding~=4)
                Dec = unifrnd(repmat(Problem.lower,Problem.D,1),repmat(Problem.upper,Problem.D,1));
                Dec(:,Problem.encoding==4) = 1;
                Mask       = eye(Problem.D);
                Population = Problem.Evaluation(Dec.*Mask);
                TDec       = [TDec;Dec];
                TMask      = [TMask;Mask];
                TempPop    = [TempPop,Population];
                Fitness    = Fitness + NDSort([Population.objs,Population.cons],inf);
            end
            % Generate initial population
            Dec = unifrnd(repmat(Problem.lower,Problem.N,1),repmat(Problem.upper,Problem.N,1));
            Dec(:,Problem.encoding==4) = 1;
            Mask = false(Problem.N,Problem.D);
            for i = 1 : Problem.N
                Mask(i,TournamentSelection(2,ceil(rand*Problem.D),Fitness)) = 1;
            end
            Population = Problem.Evaluation(Dec.*Mask);
            [Population,Dec,Mask,FitnessSpea2] = EnvironmentalSelection([Population,TempPop],[Dec;TDec],[Mask;TMask],Problem.N);
     
            %% Optimization
            while Algorithm.NotTerminated(Population)                
                MatingPool       = TournamentSelection(2,2*Problem.N,FitnessSpea2);
                [OffDec,OffMask] = Operator(Problem,Dec(MatingPool,:),Mask(MatingPool,:),Fitness,Mask);
                Offspring        = Problem.Evaluation(OffDec.*OffMask);
                [Population,Dec,Mask,FitnessSpea2] = EnvironmentalSelection([Population,Offspring],[Dec;OffDec],[Mask;OffMask],Problem.N);
            end
        end
    end
end