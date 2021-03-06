function [opts argnum] = fp_curve_PD2sol(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
% Parser of toolbox curve, starting at a branch point.

% compute number of processed arguments, varargin is ignored here
argnum = 4;

% Restore data associated with a specific run and solution label from disc.
% 'data' will contain the toolbox data structure, and 'sol' contains a
% structure with the solution vector (and more). We only access the
% solution vector 'sol.x'.
[data sol] = coco_read_solution('curve_save', rrun, rlab);
f  = data.f;
fx = data.fx;
fp = data.fp;
k = data.k*2;
x0 = sol.x(data.x_idx);
p0 = sol.x(data.p_idx);


% compute vector 't' normal to 'data.t' such that the plane spanned by 't'
% and 'data.t' contains both branches approximately
if issparse(data.J)
  [X D] = eigs(data.J,1,0); %#ok<NASGU>
  t     = X;
else
    
  [X D] = eig(data.J);
  [v idx] = min(abs(diag(D)+1)); %#ok<ASGLU>
  t       = X(:,idx);
end
t       = t/norm(t);
tx      = t(data.x_idx);
tp      = zeros(size(p0));
tp(data.acp_idx) = t(end);

% make small step in direction of [tx;tp]
step = varargin{1};
h = coco_get(opts, 'cont.h0');
if isstruct(h)
  h = 0.001;
else
  h = step*h;
end
x0 = x0 + h*tx;
p0 = p0 + h*tp;

% call toolbox constructor
opts = fp_curve_create(opts, f, fx, fp, x0, p0, k, tx, tp);

end
