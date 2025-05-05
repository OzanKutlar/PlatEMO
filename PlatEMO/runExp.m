function file = runExp(dataFileName)
    global finalData

    if ~isfolder('experiments')
        mkdir('experiments');
    end

    addpath(genpath(pwd));
    load(dataFileName); %% data is loaded from here.

    finalData = {};

    funcHandle = eval(strcat("@CEC", data.year, "_F", num2str(double(data.func))));
    funcInfo = eval(strcat("CEC", data.year, "_F", num2str(double(data.func))));
    allSolutions = cell(1, data.repeat);  
    allFitness = cell(1, data.repeat);  % Preallocate a cell array
    algoVector = [double(data.tournamentPer), double(data.stocPer), double(data.rankPer), double(data.truncPer)];
	
    for ii = 1:data.repeat
        if(double(data.adaptive) == 1)
            temp = platemo('algorithm', @AdaptiveMiSeGA, ...
                'problem', funcHandle, ...
                'N', double(data.pop), ...
                'maxFE', double(data.maxFE), ...
                'D', double(data.D), ...
                'proM', 0.4);
            allSolutions{ii} = finalData.AlgoPercentages;
            allFitness{ii} = FitnessSingle(finalData.Pop);
        else
            temp = platemo('algorithm', @MiSeGA, ...
                'problem', funcHandle, ...
                'N', double(data.pop), ...
                'maxFE', double(data.maxFE), ...
                'D', double(data.D), ...
                'proM', 0.4, ...
                'algoPercentages', algoVector);
            allFitness{ii} = FitnessSingle(finalData.Pop);
        end
    end
    data.selectionMethods = algoVector;
    data = rmfield(data, {'tournamentPer', 'stocPer', 'rankPer', 'truncPer'});
    % data.finalPop = allSolutions;
    data.finalFitness = allFitness;
    data.funcInfo = funcInfo;

    nameOfFile = strcat("exp-testing", string(data.id));
	nameOfFile = strcat('experiments/', nameOfFile, '.mat');


    save(nameOfFile, "data");

	file = nameOfFile;
end
