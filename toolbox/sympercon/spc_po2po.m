function [opts argnum] = pocont_po2po(opts, prefix, rrun, rlab, varargin)

%% get toolbox settings
[opts pocont] = pocont_get_settings(opts, prefix);

%% create collocation system and use default zero problem
coll_func     = sprintf('%s_sol2sol', pocont.collocation);
coll_func     = str2func(coll_func);
[opts argnum] = coll_func(opts, prefix, rrun, rlab, varargin{:});

%% set up and initialise boundary conditions
[opts coll xidx] = pocont_add_BC(opts, prefix);

%% add codim-1 test functions
opts = pocont_add_TF(opts, prefix, pocont, xidx, coll, 1);

%% add external parameters if top-level toolbox
if isempty(prefix)
  opts = coco_add_parameters(opts, prefix, xidx(coll.p_idx), 1:numel(coll.p_idx));
end
