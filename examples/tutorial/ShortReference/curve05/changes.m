% Changes since curve04:
%-----------------------
%
% created separate function for branch-switching, which will work for all
%   types of zero-problems and should be used as outlined in the reference
%   manual
%
% new toolbox file:
%   computeFirstPoint.m : black-box function for branch switching
%
% modified file:
%   curve_BP2sol.m : this function now uses computeFirstPoint instead of
%     setting up its own continuation problem
%
% Changes since curve03:
%-----------------------
%
% created parser for branch-switching at branch point
%
% new toolbox file(s):
%   curve_BP2sol.m : parser for branch-switching at BP point
%
% modified demo file(s):
%   demo_ode1.m : added run for branch-switching at BP
%
%
% Changes since curve02.m:
%-------------------------
%
% created separate toolbox and example files
%
% toolbox files:
%   curve_create.m   : constructor
%   curve_isol2sol.m : parser for start from initial point
%   curve_sol2sol.m  : parser for re-start from saved point
%
% demo files:
%   demo_circ.m : computation of circle
%   demo_ode1.m : bifurcation diagram of ODE (1)
%   demo_csec.m : computation of cone section