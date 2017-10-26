function [fitresult, gof] = createFitGround(ground_x, ground_y, ground_z)
%CREATEFIT(GROUND_X,GROUND_Y,GROUND_Z)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : ground_x
%      Y Input : ground_y
%      Z Output: ground_z
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 26-Oct-2017 11:06:42 自动生成


[xData, yData, zData] = prepareSurfaceData( ground_x, ground_y, ground_z );

% Set up fittype and options.
ft = fittype( 'poly11' );

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, [xData, yData], zData );
legend( h, 'untitled fit 1', 'ground_z vs. ground_x, ground_y', 'Location', 'NorthEast' );
% Label axes
xlabel ground_x
ylabel ground_y
zlabel ground_z
grid on
view( 102.9, 2.8 );


