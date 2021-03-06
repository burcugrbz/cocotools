function [opts chart J] = efunc_DFDX(opts, chart, xp)
%EFUNC_DFDX  Evaluate Jacobian of extended system at UP=[U;P].
%
%   [OPTS J] = EFUNC_DFDX(OPTS, UP) evaluates the Jacobian of the extended
%   system, which is the system combined of all algorithms and user
%   functions.
%
% See also: EFUNC_F
%

% create cache for variables that grow
persistent rows cols vals

if nargin==0
  % clear cache
  rows = [];
  cols = [];
  vals = [];
  return;
end

%% extract x from xp=[x;p] and
%  initialise derivatives with respect to x(efunc.p_idx,1)

efunc         = opts.efunc;
x             = xp(efunc.xp_idx,1);
J             = efunc.J_init;
[r c v]       = find(J);
[nrows ncols] = size(J);
idx_MX        = numel(r);
idx           = 1:idx_MX;
rows(idx)     = r;
cols(idx)     = c;
vals(idx)     = v;

%% compute Jacobian of extended continuation problem

for i = [ efunc.zero efunc.embedded ]
  func  = efunc.funcs(i);
  f_idx = func.f_idx;
  x_idx = func.x_idx;
  data  = func.data;
  
  % evaluate Jacobian of function
  switch func.call_mode
    case 1 % [d J]=DFDX(o,d,x)
      if isempty(func.DFDX)
        if isfield(func, 'vectorised') && func.vectorised
          [data DFDX] = fdm_ezDFDX('f(o,d,x)v', opts, data, func.F, x(x_idx));
        else
          [data DFDX] = fdm_ezDFDX('f(o,d,x)',  opts, data, func.F, x(x_idx));
        end
      else
        [data DFDX] = func.DFDX(opts, data, x(x_idx));
      end
    case 2 % [d f J]=FDF(o,d,x)
      [data F DFDX] = func.F(opts, data, x(x_idx)); %#ok<ASGLU>
    case 3 % [d c J]=DFDX(o,d,c,x)
      if isempty(func.DFDX)
        if isfield(func, 'vectorised') && func.vectorised
          [data chart2 DFDX] = fdm_ezDFDX('f(o,d,c,x)v', opts, data, chart, func.F, x(x_idx));
        else
          [data chart2 DFDX] = fdm_ezDFDX('f(o,d,c,x)',  opts, data, chart, func.F, x(x_idx));
        end
      else
        [data chart2 DFDX] = func.DFDX(opts, data, chart, x(x_idx));
      end
      chart.private.data = chart2.private.data;
    case 4 % [d c f J]=FDF(o,d,c,x)
      [data chart2 F DFDX] = func.F(opts, data, chart, x(x_idx)); %#ok<ASGLU>
      chart.private.data = chart2.private.data;
  end
  
  % merge Jacobians
  [r c v]   = find(DFDX);
  idx       = idx_MX+(1:numel(r));
  idx_MX    = idx_MX+numel(r);
  rows(idx) = f_idx(r)';
  cols(idx) = x_idx(c)';
  vals(idx) = v;
  
  % allow modification of associated toolbox data
  % for example, counting evaluations of F and DFDX
  opts.efunc.funcs(i).data = data;
  
end

%% apply permutations
% [opts J1] = fdm_ezDFDX('f(o,x)', opts, @efunc_F, xp);

idx = 1:idx_MX;
J = sparse(efunc.f_idx(rows(idx)), efunc.xp_idx(cols(idx)), vals(idx), nrows, ncols);
