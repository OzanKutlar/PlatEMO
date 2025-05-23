classdef PBNSGAIII < ALGORITHM
% <2022> <multi/many> <real/integer> <expensive>
% NSGA-III based on Pareto based bi-indicator infill sampling criterion
% wmax --- 15 --- Number of generations before updating Kriging models

%------------------------------- Reference --------------------------------
% Z. Song, H. Wang, and H. Xu. A framework for expensive many-objective
% optimization with Pareto-based bi-indicator infill sampling criterion.
% Memetic Computing, 2022, 14: 179-191.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2025 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

% This function is written by Zhenshou Song
% Email: zssong@stu.xidian.edu.cn

    methods
        function main(Algorithm,Problem)
            %% Parameter setting
            wmax = Algorithm.ParameterSet(15);
            
            %% Initialization of NSGAIII
            
            NI            = Problem.N;
            P             = UniformPoint(NI,Problem.D,'Latin');
            Population    = Problem.Evaluation(repmat(Problem.upper-Problem.lower,NI,1).*P+repmat(Problem.lower,NI,1));
            [W,~] = UniformPoint(Problem.N,Problem.M);
            Zmin  = min(Population.objs,[],1); 
            A             = Population;
            
            THETA         = 5.*ones(Problem.M,Problem.D);
            Model         = cell(1,Problem.M);
            
            while Algorithm.NotTerminated(A)
                Dec = Population.decs;
                Obj = Population.objs;
                train_X = A.decs;
                train_Y = A.objs;
                [~,distinct] = unique(round(train_X*1e6)/1e6,'rows');  
                train_X      = train_X(distinct,:);
                train_Y      = train_Y(distinct,:);
                for i = 1:Problem.M % train surrogates
                    dmodel     = dacefit(train_X,train_Y(:,i),'regpoly0','corrgauss',THETA(i,:),1e-5.*ones(1,Problem.D),100.*ones(1,Problem.D));
                    Model{i}   = dmodel;
                    THETA(i,:) = dmodel.theta;
                end
                if isempty(Dec)
                    size(Dec),
                    pause
                end
                w = 1;
                while w <= wmax
                    w = w + 1;
                    OffspringDec = OperatorGA(Problem,Dec(randi(end,1,NI),:));
                    N = size(OffspringDec,1);
                    OffspringObj = zeros(N,Problem.M);
                    for i = 1:N
                        for j = 1:Problem.M
                            [OffspringObj(i,j),~,~] = predictor(OffspringDec(i,:),Model{j});
                        end
                    end
                    Zmin  = min([Zmin; OffspringObj],[],1);
                    %% Non-dominated sorting
                    all_Obj = [Obj;OffspringObj];
                    all_Dec = [Dec;OffspringDec];
                    [FrontNo,MaxFNo] = NDSort([Obj;OffspringObj],NI);
                    Next = FrontNo < MaxFNo;
                    %% Select the solutions in the last front
                    Last   = find(FrontNo==MaxFNo);  
                    Choose = LastSelection(all_Obj(Next,:),all_Obj(Last,:),NI-sum(Next),W,Zmin); 
                    Next(Last(Choose)) = true;
                    Dec = all_Dec(Next,:);
                    Obj = all_Obj(Next,:);
                end
                
               %% Pareto-based bi-indicator infill sampling criterion 
                DAdec = Dec;
                DA    = Population;
                % Normalization
                DA_Nor = (DA.objs - repmat(min([Obj;DA.objs],[],1),length(DA),1))...  
                    ./repmat(max([Obj;DA.objs],[],1) - min([Obj;DA.objs],[],1),length(DA),1);
                DA_Nor_pre = (Obj - repmat(min([Obj;DA.objs],[],1),size(Obj,1),1))...
                    ./repmat(max([Obj;DA.objs],[],1) - min([Obj;DA.objs],[],1),size(Obj,1),1);
                Zmin = min([DA_Nor;DA_Nor_pre],[],1);
                
                dist_D = zeros(size(DA_Nor_pre,1),size(DA_Nor,1));
                
                 % Calculate the distance between candidate solutions and parents
                for i = 1 : size(DA_Nor_pre,1)    
                    for j = 1 : size(DA_Nor,1)
                        dist_D(i,j) = norm(DA_Nor_pre(i,:)-DA_Nor(j,:),2);
                    end
                end
                
                % Diversity Indicator
                DI = -min(dist_D,[],2); 
                
                % Calculate the distance between candidate solutions and ideal point
                dist_C = pdist2(DA_Nor_pre,repmat(Zmin,size(DA_Nor_pre,1),1));
                
                % Convergence Indicator
                CI      = dist_C(:,1);
                newObj  = [DI,CI];
                ND1     = NDSort(newObj,1);
                PnewDec = DAdec((ND1==1),:);  % find solutions in the first front
                PnewDec = unique(PnewDec,'rows');
                
                New  = Problem.Evaluation(PnewDec); 
                A    = [A,New];
                A2   = [Population,New];
                Zmin = min(A2.objs,[],1);
                Population = EnvironmentalSelection([Population,New],Problem.N,W,Zmin);
            end
        end
    end
end