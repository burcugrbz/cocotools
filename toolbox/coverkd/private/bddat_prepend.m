function [opts bd] = bddat_prepend(opts, bd, sol)
%BDDAT_PREPEND  Add a point at the beginning of the point list.
%
%   [OPTS BD] = BDDAT_PREPEND(OPTS, BD) Add a point at the beginning of the
%   point list in bddat.bd.
%
%   See also: bddat_append, bddat_insert
%

if strcmp(sol.pt_type, 'ROS')
	new_data = { ...
		opts.cont.branch, ...
		opts.cont.It, ...
		opts.xfunc.h, ...
		sol.pt_type, ...
		sol.lab, [], ...
		sol.p(opts.cont.op_idx(1)), ...
		norm(sol.x(opts.cont.xidx)), ...
		sol.p(opts.cont.op_idx), ...
		};
else
	new_data = { ...
		opts.cont.branch, ...
		opts.cont.It, ...
		opts.xfunc.h, ...
		sol.pt_type, ...
		sol.lab, sol.lab, ...
		sol.p(opts.cont.op_idx(1)), ...
		norm(sol.x(opts.cont.xidx)), ...
		sol.p(opts.cont.op_idx), ...
		};
end

[opts res] = coco_emit(opts, 'bddat', 'data', sol);
for i=1:size(res,1)
  new_data = [new_data res{i,2}]; %#ok<AGROW>
end

bd = [ bd(1,:) ; new_data ; bd(2:end,:) ];