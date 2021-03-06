function [opts argnum] = hscont_ho2ho(opts, prefix, rrun, rlab, varargin)

%% get toolbox settings
[opts hscont] = hscont_get_settings(opts, prefix);

%% create collocation system and use default zero problem
coll_func     = sprintf('%s_sol2sol', hscont.collocation);
coll_func     = str2func(coll_func);
[opts argnum] = coll_func(opts, prefix, rrun, rlab, varargin{:});

%% set up and initialise boundary conditions
[opts coll xidx] = hscont_add_BC(opts, prefix);

%% add external parameters if top-level toolbox
if isempty(prefix)
  opts = coco_add_parameters(opts, prefix, xidx(coll.p_idx), 1:numel(coll.p_idx));
end
