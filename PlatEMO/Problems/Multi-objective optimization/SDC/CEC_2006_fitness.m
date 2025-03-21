function [objF, conV]=CEC_2006_fitness(P, problem, aaa,optimal)

%------------------------------- Copyright --------------------------------
% Copyright (c) 2025 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

% This function is written by Kangjia Qiao (email: qiaokangjia@yeah.net)

    popsize = size(P, 1);

    g = [];

    % g denotes the constraints
    % f denotes the objective function

    switch problem
        case 1
            g(:, 1) = 2 * P(:, 1) + 2 * P(:, 2) + P(:, 10) + P(:, 11) - 10;
            g(:, 2) = 2 * P(:, 1) + 2 * P(:, 3) + P(:, 10) + P(:, 12) - 10;
            g(:, 3) = 2 * P(:, 2) + 2 * P(:, 3) + P(:, 11) + P(:, 12) - 10;
            g(:, 4) = -8 * P(:, 1) + P(:, 10);
            g(:, 5) = -8 * P(:, 2) + P(:, 11);
            g(:, 6) = -8 * P(:, 3) + P(:, 12);
            g(:, 7) = -2 * P(:, 4) - P(:, 5) + P(:, 10);
            g(:, 8) = -2 * P(:, 6) - P(:, 7) + P(:, 11);
            g(:, 9) = -2 * P(:, 8) - P(:, 9) + P(:, 12);
            f = 5 * sum(P(:, 1 : 4), 2) - 5 * sum(P(:, 1 : 4).^2, 2) - sum(P(:, 5 : 13), 2);
        case 2
            g(:, 1) = 0.75 - prod(P, 2);
            g(:, 2) = sum(P')' - 7.5 * size(P, 2);
            f = -abs(sum((cos(P).^4), 2) - 2 * prod((cos(P).^2), 2)) ./ sqrt(1E-30 + sum(repmat(1 : size(P, 2), popsize, 1) .* (P.^2), 2));
        case 3
            g(:, 1) = abs(sum(P.^2, 2) - 1) - 0.0001;
            f = -(10.^0.5)^10 * prod(P, 2);
        case 4
            g(:, 1) = + 85.334407 + 0.0056858 * P(:, 2).* P(:, 5) + 0.0006262 * P(:, 1).* P(:, 4) - 0.0022053 * P(:, 3).* P(:, 5) - 92;
            g(:, 2) = -85.334407 - 0.0056858 * P(:, 2).* P(:, 5) - 0.0006262 * P(:, 1).* P(:, 4) + 0.0022053 * P(:, 3).* P(:, 5);
            g(:, 3) = + 80.51249 + 0.0071317 * P(:, 2).* P(:, 5) + 0.0029955 * P(:, 1).* P(:, 2) + 0.0021813 * P(:, 3).^2 - 110;
            g(:, 4) = -80.51249 - 0.0071317 * P(:, 2).* P(:, 5) - 0.0029955 * P(:, 1).* P(:, 2) - 0.0021813 * P(:, 3).^2 + 90;
            g(:, 5) = + 9.300961 + 0.0047026 * P(:, 3).* P(:, 5) + 0.0012547 * P(:, 1).* P(:, 3) + 0.0019085 * P(:, 3) .* P(:, 4) - 25;
            g(:, 6) = -9.300961 - 0.0047026 * P(:, 3).* P(:, 5) - 0.0012547 * P(:, 1).* P(:, 3) - 0.0019085 * P(:, 3) .* P(:, 4) + 20;
            f = 5.3578547 * P(:, 3).^2 + 0.8356891 * P(:, 1).* P(:, 5) + 37.293239 * P(:, 1) - 40792.141;
        case 5
            g(:, 1) = -P(:, 4) + P(:, 3) - 0.55;
            g(:, 2) = -P(:, 3) + P(:, 4) - 0.55;
            g(:, 3) = abs(1000 * sin(-P(:, 3) - 0.25) + 1000 * sin(-P(:, 4) - 0.25) + 894.8 - P(:, 1)) - 0.0001;
            g(:, 4) = abs(1000 * sin(P(:, 3) - 0.25) + 1000 * sin(P(:, 3) - P(:, 4) - 0.25) + 894.8 - P(:, 2)) - 0.0001;
            g(:, 5) = abs(1000 * sin(P(:, 4) - 0.25) + 1000 * sin(P(:, 4) - P(:, 3) - 0.25) + 1294.8) - 0.0001;
            f = 3 * P(:, 1) + 0.000001 * P(:, 1).^3 + 2 * P(:, 2) + 0.000002/3 * P(:, 2).^3;
        case 6
            g(:, 1) = -(P(:, 1) - 5).^2 - (P(:, 2) - 5).^2 + 100;
            g(:, 2) = (P(:, 1) - 6).^2 + (P(:, 2) - 5).^2 - 82.81;
            f = (P(:, 1) - 10).^3 + (P(:, 2) - 20).^3;
        case 7
            g(:, 1) = -105 + 4 * P(:, 1) + 5 * P(:, 2) - 3 * P(:, 7) + 9 * P(:, 8);
            g(:, 2) = 10 * P(:, 1) - 8 * P(:, 2) - 17 * P(:, 7) + 2 * P(:, 8);
            g(:, 3) = -8 * P(:, 1) + 2 * P(:, 2) + 5 * P(:, 9) - 2 * P(:, 10) - 12;
            g(:, 4) = 3 * (P(:, 1) - 2).^2 + 4 * (P(:, 2) - 3).^2 + 2 * P(:, 3).^2 - 7 * P(:, 4) - 120;
            g(:, 5) = 5 * P(:, 1).^2 + 8 * P(:, 2) + (P(:, 3) - 6).^2 - 2 * P(:, 4) - 40;
            g(:, 6) = P(:, 1).^2 + 2 * (P(:, 2) - 2).^2 - 2 * P(:, 1).* P(:, 2) + 14 * P(:, 5) - 6 * P(:, 6);
            g(:, 7) = 0.5 * (P(:, 1) - 8).^2 + 2 * (P(:, 2) - 4).^2 + 3 * P(:, 5).^2 - P(:, 6) - 30;
            g(:, 8) = -3 * P(:, 1) + 6 * P(:, 2) + 12 * (P(:, 9) - 8).^2 - 7 * P(:, 10);
            f = P(:, 1).^2 + P(:, 2).^2 + P(:, 1).* P(:, 2) - 14 * P(:, 1) - 16 * P(:, 2) + (P(:, 3) - 10).^2 + 4 * (P(:, 4) - 5).^2 + ...
                (P(:, 5) - 3).^2 + 2 * (P(:, 6) - 1).^2 + 5 * P(:, 7).^2 + 7 * (P(:, 8) - 11).^2 + 2 * (P(:, 9) - 10).^2 + (P(:, 10) - 7).^2 + 45;
        case 8
            g(:, 1) = P(:, 1).^2 - P(:, 2) + 1;
            g(:, 2) = 1 - P(:, 1) + (P(:, 2) - 4).^2;
            f = -(sin(2 * pi * P(:, 1)).^3).* sin(2 * pi * P(:, 2)) ./ (P(:, 1).^3 .* (P(:, 1) + P(:, 2)) + 1E-30);
        case 9
            g(:, 1) = -127 + 2 * P(:, 1).^2 + 3 * P(:, 2).^4 + P(:, 3) + 4 * P(:, 4).^2 + 5 * P(:, 5);
            g(:, 2) = -282 + 7 * P(:, 1) + 3 * P(:, 2) + 10 * P(:, 3).^2 + P(:, 4) - P(:, 5);
            g(:, 3) = -196 + 23 * P(:, 1) + P(:, 2).^2 + 6 * P(:, 6).^2 - 8 * P(:, 7);
            g(:, 4) = 4 * P(:, 1).^2 + P(:, 2).^2 - 3 * P(:, 1).* P(:, 2) + 2 * P(:, 3).^2 + 5 * P(:, 6) - 11 * P(:, 7);
            f = (P(:, 1) - 10).^2 + 5 * (P(:, 2) - 12).^2 + P(:, 3).^4 + 3 * (P(:, 4) - 11).^2 + 10 * P(:, 5).^6 + ...
                7 * P(:, 6).^2 + P(:, 7).^4 - 4 * P(:, 6).* P(:, 7) - 10 * P(:, 6) - 8 * P(:, 7);
        case 10
            g(:, 1) = -1 + 0.0025 * (P(:, 4) + P(:, 6));
            g(:, 2) = -1 + 0.0025 * (P(:, 5) + P(:, 7) - P(:, 4));
            g(:, 3) = -1 + 0.01 * (P(:, 8) - P(:, 5));
            g(:, 4) = -P(:, 1).* P(:, 6) + 833.33252 * P(:, 4) + 100 * P(:, 1) - 83333.333;
            g(:, 5) = -P(:, 2).* P(:, 7) + 1250 * P(:, 5) + P(:, 2).* P(:, 4) - 1250 * P(:, 4);
            g(:, 6) = -P(:, 3).* P(:, 8) + 1250000 + P(:, 3).* P(:, 5) - 2500 * P(:, 5);
            f = P(:, 1) + P(:, 2) + P(:, 3);
        case 11
            g(:, 1) = abs(P(:, 2) - P(:, 1).^2) - 0.0001;
            f = P(:, 1).^2 + (P(:, 2) - 1).^2;
        case 12
            f = -(100 - (P(:, 1) - 5).^2 - (P(:, 2) - 5).^2 - (P(:, 3) - 5).^2)/100;
            for j = 1 : popsize
            	g(j, 1) = min(sum((repmat(P(j, :), 9 * 9 * 9, 1) - aaa).^2, 2)) - 0.0625;
            end
        case 13
            g(:, 1) = abs(P(:, 1).^2 + P(:, 2).^2 + P(:, 3).^2 + P(:, 4).^2 + P(:, 5).^2 - 10) - 0.0001;
            g(:, 2) = abs(P(:, 2).* P(:, 3) - 5 * P(:, 4).* P(:, 5)) - 0.0001;
            g(:, 3) = abs(P(:, 1).^3 + P(:, 2).^3 + 1) - 0.0001;
            f = exp(P(:, 1).* P(:, 2).* P(:, 3).* P(:, 4).* P(:, 5));
        case 14
            c = [-6.089 -17.164 -34.054 -5.914 -24.721 -14.986 -24.1 -10.708 -26.662 -22.179];
            g(:, 1) = abs(P(:, 1) + 2 * P(:, 2) + 2 * P(:, 3) + P(:, 6) + P(:, 10) - 2) - 0.0001;
            g(:, 2) = abs(P(:, 4) + 2 * P(:, 5) + P(:, 6) + P(:, 7) - 1) - 0.0001;
            g(:, 3) = abs(P(:, 3) + P(:, 7) + P(:, 8) + 2 * P(:, 9) + P(:, 10) - 1) - 0.0001;
            f = sum(P.* (repmat(c, popsize, 1) + log(1E-30 + P./repmat(1E-30 + sum(P, 2), 1, 10))), 2);
        case 15
            g(:, 1) = abs(P(:, 1).^2 + P(:, 2).^2 + P(:, 3).^2 - 25) - 0.0001;
            g(:, 2) = abs(8 * P(:, 1) + 14 * P(:, 2) + 7 * P(:, 3) - 56) - 0.0001;
            f = 1000 - P(:, 1).^2 - 2 * P(:, 2).^2 - P(:, 3).^2 - P(:, 1).* P(:, 2) - P(:, 1).* P(:, 3);
        case 16
            y1 = P(:, 2) + P(:, 3) + 41.6;
            c1 = 0.024 * P(:, 4) - 4.62;
            y2 = 12.5./c1 + 12;
            c2 = 0.0003535 * P(:, 1).^2 + 0.5311 * P(:, 1) + 0.08705 * y2.* P(:, 1);
            c3 = 0.052 * P(:, 1) + 78 + 0.002377 * y2.* P(:, 1);
            y3 = c2./c3;
            y4 = 19 * y3;
            c4 = 0.04782 * (P(:, 1) - y3) + 0.1956 * (P(:, 1) - y3).^2./P(:, 2) + 0.6376 * y4 + 1.594 * y3;
            c5 = 100 * P(:, 2);
            c6 = P(:, 1) - y3 - y4;
            c7 = 0.950 - c4./c5;
            y5 = c6.* c7;
            y6 = P(:, 1) - y5 - y4 - y3;
            c8 = (y5 + y4) * 0.995;
            y7 = c8./y1;
            y8 = c8/3798;
            c9 = y7 - 0.0663 * y7./y8 - 0.3153;
            y9 = 96.82./c9 + 0.321 * y1;
            y10 = 1.29 * y5 + 1.258 * y4 + 2.29 * y3 + 1.71 * y6;
            y11 = 1.71 * P(:, 1) - 0.452 * y4 + 0.580 * y3;
            c10 = 12.3 / 752.3;
            c11 = 1.75 * y2.* 0.995.* P(:, 1);
            c12 = 0.995 * y10 + 1998.0;
            y12 = c10 * P(:, 1) + (c11./ c12);
            y13 = c12 - 1.75 * y2;
            y14 = 3623.0 + 64.4 * P(:, 2) + 58.4 * P(:, 3) + (146312.0./ (y9 + P(:, 5)));
            c13 = 0.995 * y10 + 60.8 * P(:, 2) + 48 * P(:, 4) - 0.1121 * y14 - 5095.0;
            y15 = y13./ c13;
            y16 = 148000.0 - 331000.0 * y15 + 40.0 * y13 - 61.0 .* y15 .* y13;
            c14 = 2324 * y10 - 28740000 * y2;
            y17 = 14130000 - 1328.0 * y10 - 531.0 * y11 + (c14./c12);
            c15 = (y13./y15) - (y13/ 0.52);
            c16 = 1.104 - 0.72 * y15;
            c17 = y9 + P(:, 5);

            g(:, 1) = 0.28/0.72.* y5 - y4;
            g(:, 2) = P(:, 3) - 1.5 * P(:, 2);
            g(:, 3) = 3496.* y2./c12 - 21;
            g(:, 4) = 110.6 + y1 - 62212./c17;
            g(:, 5) = 213.1 - y1;
            g(:, 6) = y1 - 405.23;
            g(:, 7) = 17.505 - y2;
            g(:, 8) = y2 - 1053.6667;
            g(:, 9) = 11.275 - y3;
            g(:, 10) = y3 - 35.03;
            g(:, 11) = 214.228 - y4;
            g(:, 12) = y4 - 665.585;
            g(:, 13) = 7.458 - y5;
            g(:, 14) = y5 - 584.463;
            g(:, 15) = 0.961 - y6;
            g(:, 16) = y6 - 265.916;
            g(:, 17) = 1.612 - y7;
            g(:, 18) = y7 - 7.046;
            g(:, 19) = 0.146 - y8;
            g(:, 20) = y8 - 0.222;
            g(:, 21) = 107.99 - y9;
            g(:, 22) = y9 - 273.366;
            g(:, 23) = 922.693 - y10;
            g(:, 24) = y10 - 1286.105;
            g(:, 25) = 926.832 - y11;
            g(:, 26) = y11 - 1444.046;
            g(:, 27) = 18.766 - y12;
            g(:, 28) = y12 - 537.141;
            g(:, 29) = 1072.163 - y13;
            g(:, 30) = y13 - 3247.039;
            g(:, 31) = 8961.448 - y14;
            g(:, 32) = y14 - 26844.086;
            g(:, 33) = 0.063 - y15;
            g(:, 34) = y15 - 0.386;
            g(:, 35) = 71084.33 - y16;
            g(:, 36) = -140000 + y16;
            g(:, 37) = 2802713 - y17;
            g(:, 38) = y17 - 12146108;
            f = 0.000117 * y14 + 0.1365 + 0.00002358 * y13 + 0.000001502 * y16 + 0.0321 * y12 ...
                + 0.004324 * y5 + 0.0001 * (c15 ./ c16) + 37.48 * (y2./c12) - 0.0000005843 * y17;
        case 17
            g(:, 1) = abs(-P(:, 1) + 300 - P(:, 3).* P(:, 4)./131.078.* cos(1.48477 - P(:, 6)) + 0.90798.* P(:, 3).^2./131.078.* cos(1.47588)) - 0.0001;
            g(:, 2) = abs(-P(:, 2) - P(:, 3).* P(:, 4)./131.078.* cos(1.48477 + P(:, 6)) + 0.90798.* P(:, 4).^2./131.078.* cos(1.47588)) - 0.0001;
            g(:, 3) = abs(-P(:, 5) - P(:, 3).* P(:, 4)./131.078.* sin(1.48477 + P(:, 6)) + 0.90798.* P(:, 4).^2./131.078.* sin(1.47588)) - 0.0001;
            g(:, 4) = abs(200 - P(:, 3).* P(:, 4)./131.078.* sin(1.48477 - P(:, 6)) + 0.90798.* P(:, 3).^2./131.078.* sin(1.47588)) - 0.0001;
            f = 30 .* P(:, 1) .* (P(:, 1) < 300) + 31.* P(:, 1) .* (P(:, 1) >= 300) + 28 .* P(:, 2) .* (P(:, 2) < 100) + 29.* P(:, 2) .* (P(:, 2) >= 100 & P(:, 2) < 200) + 30 .* P(:, 2) .* (P(:, 2) >= 200 & P(:, 2) < 1000);
        case 18
            g(:, 1) = P(:, 3).^2 + P(:, 4).^2 - 1;
            g(:, 2) = P(:, 9).^2 - 1;
            g(:, 3) = P(:, 5).^2 + P(:, 6).^2 - 1;
            g(:, 4) = P(:, 1).^2 + (P(:, 2) - P(:, 9)).^2 - 1;
            g(:, 5) = (P(:, 1) - P(:, 5)).^2 + (P(:, 2) - P(:, 6)).^2 - 1;
            g(:, 6) = (P(:, 1) - P(:, 7)).^2 + (P(:, 2) - P(:, 8)).^2 - 1;
            g(:, 7) = (P(:, 3) - P(:, 5)).^2 + (P(:, 4) - P(:, 6)).^2 - 1;
            g(:, 8) = (P(:, 3) - P(:, 7)).^2 + (P(:, 4) - P(:, 8)).^2 - 1;
            g(:, 9) = P(:, 7).^2 + (P(:, 8) - P(:, 9)).^2 - 1;
            g(:, 10) = P(:, 2).* P(:, 3) - P(:, 1).* P(:, 4);
            g(:, 11) = -P(:, 3).* P(:, 9);
            g(:, 12) = P(:, 5).* P(:, 9);
            g(:, 13) = P(:, 6).* P(:, 7) - P(:, 5).* P(:, 8);
            f = -0.5 * (P(:, 1).* P(:, 4) - P(:, 2).* P(:, 3) + P(:, 3).* P(:, 9) - P(:, 5).* P(:, 9) + P(:, 5).* P(:, 8) - P(:, 6).* P(:, 7));
        case 19
            a = [-16 2 0 1 0;
                0 -2 0 0.4 2;
                -3.5 0 2 0 0;
                0 -2 0 -4 -1;
                0 -9 -2 1 -2.8;
                2 0 -4 0 0;
                -1 -1 -1 -1 -1;
                -1 -2 -3 -2 -1;
                1 2 3 4 5;
                1 1 1 1 1];
            b = [-40 -2 -0.25 -4 -4 -1 -40 -60 5 1];
            c = [30 -20 -10 32 -10;
                -20 39 -6 -31 32;
                -10 -6 10 -6 -10;
                32 -31 -6 39 -20;
                -10 32 -10 -20 30];
            d = [4 8 10 6 2];
            e = [-15 -27 -36 -18 -12];
            g(:, 1) = -2 * sum(repmat(c(1:5, 1)', popsize, 1).* P(:, 11:15), 2) - 3 * d(1).* P(:, 11).^2 - e(1) + sum(repmat(a(1:10, 1)', popsize, 1).* P(:, 1:10), 2);
            g(:, 2) = -2 * sum(repmat(c(1:5, 2)', popsize, 1).* P(:, 11:15), 2) - 3 * d(2).* P(:, 12).^2 - e(2) + sum(repmat(a(1:10, 2)', popsize, 1).* P(:, 1:10), 2);
            g(:, 3) = -2 * sum(repmat(c(1:5, 3)', popsize, 1).* P(:, 11:15), 2) - 3 * d(3).* P(:, 13).^2 - e(3) + sum(repmat(a(1:10, 3)', popsize, 1).* P(:, 1:10), 2);
            g(:, 4) = -2 * sum(repmat(c(1:5, 4)', popsize, 1).* P(:, 11:15), 2) - 3 * d(4).* P(:, 14).^2 - e(4) + sum(repmat(a(1:10, 4)', popsize, 1).* P(:, 1:10), 2);
            g(:, 5) = -2 * sum(repmat(c(1:5, 5)', popsize, 1).* P(:, 11:15), 2) - 3 * d(5).* P(:, 15).^2 - e(5) + sum(repmat(a(1:10, 5)', popsize, 1).* P(:, 1:10), 2);
            f = sum(repmat(c(1:5, 1)', popsize, 1).* P(:, 11:15), 2).* P(:, 11) + sum(repmat(c(1:5, 2)', popsize, 1).* P(:, 11:15), 2).* P(:, 12)...
                + sum(repmat(c(1:5, 3)', popsize, 1).* P(:, 11:15), 2).* P(:, 13) + sum(repmat(c(1:5, 4)', popsize, 1).* P(:, 11:15), 2).* P(:, 14)...
                + sum(repmat(c(1:5, 5)', popsize, 1).* P(:, 11:15), 2).* P(:, 15) + 2 * sum(repmat(d, popsize, 1).* P(:, 11:15).^3, 2)...
                - sum(repmat(b, popsize, 1).* P(:, 1:10), 2);
        case 20
            a = [0.0693 0.0577 0.05 0.2 0.26 0.55 0.06 0.1 0.12 0.18 0.1 0.09...
                0.0693 0.0577 0.05 0.2 0.26 0.55 0.06 0.1 0.12 0.18 0.1 0.09];
            b = [44.094 58.12 58.12 137.4 120.9 170.9 62.501 84.94 133.425 82.507 46.07 60.097...
                44.094 58.12 58.12 137.4 120.9 170.9 62.501 84.94 133.425 82.507 46.07 60.079];
            c = [123.7 31.7 45.7 14.7 84.7 27.7 49.7 7.1 2.1 17.7 0.85 0.64];
            d = [31.244 36.12 34.784 92.7 82.7 91.6 56.708 82.7 80.8 64.517 49.4 49.1];
            e = [0.1 0.3 0.4 0.3 0.6 0.3];
            g(:, 1) = (P(:, 1) + P(:, 13))./(sum(P, 2) + e(1));
            g(:, 2) = (P(:, 2) + P(:, 14))./(sum(P, 2) + e(2));
            g(:, 3) = (P(:, 3) + P(:, 15))./(sum(P, 2) + e(3));
            g(:, 4) = (P(:, 7) + P(:, 19))./(sum(P, 2) + e(4));
            g(:, 5) = (P(:, 8) + P(:, 20))./(sum(P, 2) + e(5));
            g(:, 6) = (P(:, 9) + P(:, 21))./(sum(P, 2) + e(6));
            g(:, 7) = abs(P(:, 13)./(b(13) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(1) * P(:, 1)./(40 * b(1) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 8) = abs(P(:, 14)./(b(14) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(2) * P(:, 2)./(40 * b(2) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 9) = abs(P(:, 15)./(b(15) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(3) * P(:, 3)./(40 * b(3) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 10) = abs(P(:, 16)./(b(16) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(4) * P(:, 4)./(40 * b(4) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 11) = abs(P(:, 17)./(b(17) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(5) * P(:, 5)./(40 * b(5) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 12) = abs(P(:, 18)./(b(18) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(6) * P(:, 6)./(40 * b(6) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 13) = abs(P(:, 19)./(b(19) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(7) * P(:, 7)./(40 * b(7) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 14) = abs(P(:, 20)./(b(20) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(8) * P(:, 8)./(40 * b(8) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 15) = abs(P(:, 21)./(b(21) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(9) * P(:, 9)./(40 * b(9) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 16) = abs(P(:, 22)./(b(22) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(10) * P(:, 10)./(40 * b(10) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 17) = abs(P(:, 23)./(b(23) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(11) * P(:, 11)./(40 * b(11) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 18) = abs(P(:, 24)./(b(24) * (sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2))) - c(12) * P(:, 12)./(40 * b(12) * (sum(P(:, 1:12)./repmat(b(1:12), popsize, 1), 2)))) - 0.0001;
            g(:, 19) = abs(sum(P, 2) - 1) - 0.0001;
            g(:, 20) = abs(sum(P(:, 1:12)./repmat(d(1:12), popsize, 1), 2) + 0.7302 * 530 * 14.7/40 * sum(P(:, 13:24)./repmat(b(13:24), popsize, 1), 2) - 1.671)-0.0001;
            f = sum(repmat(a, popsize, 1).* P, 2);
        case 21
            g(:, 1) = -P(:, 1) + 35 * P(:, 2).^0.6 + 35 * P(:, 3).^0.6;
            g(:, 2) = abs(-300 * P(:, 3) + 7500 * P(:, 5) - 7500 * P(:, 6) - 25 * P(:, 4).* P(:, 5) + 25 * P(:, 4).* P(:, 6) + P(:, 3).* P(:, 4)) - 0.0001;
            g(:, 3) = abs(100 * P(:, 2) + 155.365 * P(:, 4) + 2500 * P(:, 7) - P(:, 2).* P(:, 4) - 25 * P(:, 4).* P(:, 7) - 15536.5) - 0.0001;
            g(:, 4) = abs(-P(:, 5) + log( - P(:, 4) + 900)) - 0.0001;
            g(:, 5) = abs(-P(:, 6) + log(P(:, 4) + 300)) - 0.0001;
            g(:, 6) = abs(-P(:, 7) + log(-2 * P(:, 4) + 700)) - 0.0001;
            f = P(:, 1);
        case 22
            g(:, 1) = -P(:, 1) + P(:, 2).^0.6 + P(:, 3).^0.6 + P(:, 4).^0.6;
            g(:, 2) = abs(P(:, 5) - 100000 * P(:, 8) + 10^7) - 0.0001;
            g(:, 3) = abs(P(:, 6) + 100000 * P(:, 8) - 100000 * P(:, 9)) - 0.0001;
            g(:, 4) = abs(P(:, 7) + 100000 * P(:, 9) - 5 * 10^7) - 0.0001;
            g(:, 5) = abs(P(:, 5) + 100000 * P(:, 10) - 3.3 * 10^7) - 0.0001;
            g(:, 6) = abs(P(:, 6) + 100000 * P(:, 11) - 4.4 * 10^7) - 0.0001;
            g(:, 7) = abs(P(:, 7) + 100000 * P(:, 12) - 6.6 * 10^7) - 0.0001;
            g(:, 8) = abs(P(:, 5) - 120 * P(:, 2).* P(:, 13)) - 0.0001;
            g(:, 9) = abs(P(:, 6) - 80 * P(:, 3).* P(:, 14)) - 0.0001;
            g(:, 10) = abs(P(:, 7) - 40 * P(:, 4).* P(:, 15)) - 0.0001;
            g(:, 11) = abs(P(:, 8) - P(:, 11) + P(:, 16)) - 0.0001;
            g(:, 12) = abs(P(:, 9) - P(:, 12) + P(:, 17)) - 0.0001;
            g(:, 13) = abs(-P(:, 18) + log(P(:, 10) - 100)) - 0.0001;
            g(:, 14) = abs(-P(:, 19) + log( - P(:, 8) + 300)) - 0.0001;
            g(:, 15) = abs(-P(:, 20) + log(P(:, 16))) - 0.0001;
            g(:, 16) = abs(-P(:, 21) + log( - P(:, 9) + 400)) - 0.0001;
            g(:, 17) = abs(-P(:, 22) + log(P(:, 17))) - 0.0001;
            g(:, 18) = abs(-P(:, 8) - P(:, 10) + P(:, 13).* P(:, 18) - P(:, 13).* P(:, 19) + 400) - 0.0001;
            g(:, 19) = abs(P(:, 8)-P(:, 9) - P(:, 11) + P(:, 14).* P(:, 20) - P(:, 14).* P(:, 21) + 400) - 0.0001;
            g(:, 20) = abs(P(:, 9) - P(:, 12) - 4.60517 * P(:, 15) + P(:, 15).* P(:, 22) + 100) - 0.0001;
            f = P(:, 1);
        case 23
            g(:, 1) = P(:, 9).* P(:, 3) + 0.02.* P(:, 6) - 0.025.* P(:, 5);
            g(:, 2) = P(:, 9).* P(:, 4) + 0.02.* P(:, 7) - 0.015.* P(:, 8);
            g(:, 3) = abs(P(:, 1) + P(:, 2) - P(:, 3) - P(:, 4)) - 0.0001;
            g(:, 4) = abs(0.03.* P(:, 1) + 0.01.* P(:, 2) - P(:, 9).* (P(:, 3) + P(:, 4))) - 0.0001;
            g(:, 5) = abs(P(:, 3) + P(:, 6) - P(:, 5)) - 0.0001;
            g(:, 6) = abs(P(:, 4) + P(:, 7) - P(:, 8)) - 0.0001;
            f = -9.* P(:, 5) - 15.* P(:, 8) + 6.* P(:, 1) + 16.* P(:, 2) + 10.* (P(:, 6) + P(:, 7));
        case 24
            g(:, 1) = -2 * P(:, 1).^4 + 8 * P(:, 1).^3 - 8 * P(:, 1).^2 + P(:, 2) - 2;
            g(:, 2) = -4 * P(:, 1).^4 + 32 * P(:, 1).^3 - 88 * P(:, 1).^2 + 96 * P(:, 1) + P(:, 2) - 36;
            f = -P(:, 1) - P(:, 2);
        case 25
            f=-(P(:,1)+P(:,2)-( P(:,1).^2+2*P(:,3).^2+P(:,2).^2+2*P(:,1).*P(:,3)+2*P(:,2).*P(:,3)));
            g(:,1)=abs(P(:,1)+P(:,2)+P(:,3)-1);
    end

    % Obtain the fitness
    objF  = f;
    term  = max(0, g);
    conV  = sum(term, 2);
    objF  = objF - optimal;
    index = abs(objF)<=0.001;
    objF(index) = 0;
end