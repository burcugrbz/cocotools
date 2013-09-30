%!coll_init_data
function data = coll_init_data(data, x0, p0)

NTST = data.coll.NTST;
NCOL = data.coll.NCOL;
dim  = size(x0,2);
pdim = numel(p0);

data.dim  = dim;
data.pdim = pdim;

bpnum  = NCOL+1;
bpdim  = dim*(NCOL+1);
xbpnum = (NCOL+1)*NTST;
xbpdim = dim*(NCOL+1)*NTST;
cndim  = dim*NCOL;
xcnnum = NCOL*NTST;
xcndim = dim*NCOL*NTST;
cntnum = NTST-1;
cntdim = dim*(NTST-1);

data.xbp_idx = (1:xbpdim)';
data.T_idx   = xbpdim+1;
data.p_idx   = xbpdim+1+(1:pdim)';
data.tbp_idx = setdiff(1:xbpnum, 1+bpnum*(1:cntnum))';
data.x_shp   = [dim xcnnum];
data.xbp_shp = [dim xbpnum];
data.p_rep   = [1 xcnnum];

tm = linspace(-1, 1, bpnum)';
t  = repmat((0.5/NTST)*(tm+1), [1 NTST]);
t  = t+repmat((0:cntnum)/NTST, [bpnum 1]);
data.tbp    = t(:)/t(end);

data.x0_idx = (1:dim)';
data.x1_idx = xbpdim-dim+(1:dim)';

[tc wts]    = coll_nodes(NCOL);
wts         = repmat(wts, [dim NTST]);
data.wts1   = wts(1,:);
data.wts2   = spdiags(wts(:), 0, xcndim, xcndim);

pmap        = coll_L(tm, tc);
dmap        = coll_Lp(tm, tc);
rows        = reshape(1:xcndim, [cndim NTST]);
rows        = repmat(rows, [bpdim 1]);
cols        = repmat(1:xbpdim, [cndim 1]);
W           = repmat(kron(pmap, eye(dim)), [1 NTST]);
Wp          = repmat(kron(dmap, eye(dim)), [1 NTST]);
data.W      = sparse(rows, cols, W);
data.Wp     = sparse(rows, cols, Wp);

mmap        = coll_Lm(tm);
rows        = reshape(1:dim*NTST, [dim NTST]);
rows        = repmat(rows, [bpdim 1]);
cols        = repmat(1:xbpdim, [dim 1]);
Wm          = repmat(kron(mmap, eye(dim)), [1 NTST]);
data.Wm     = sparse(rows, cols, Wm);
x           = linspace(tm(1), tm(2), 51);
y           = arrayfun(@(x) prod(x-tm), x);
data.wn     = max(abs(y));

data.dxrows = repmat(reshape(1:xcndim, [dim xcnnum]), [dim 1]);
data.dxcols = repmat(1:xcndim, [dim 1]);
data.dprows = repmat(reshape(1:xcndim, [dim xcnnum]), [pdim 1]);
data.dpcols = repmat(1:pdim, [dim xcnnum]);

temp        = reshape(1:xbpdim, [bpdim NTST]);
Qrows       = [1:cntdim 1:cntdim];
Qcols       = [temp(1:dim, 2:end) temp(cndim+1:end, 1:end-1)];
Qvals       = [ones(cntdim,1) -ones(cntdim,1)];
data.Q      = sparse(Qrows, Qcols, Qvals, cntdim, xbpdim);
data.Qnum   = cntdim;

end %!end_coll_init_data

function [nds wts] = coll_nodes(m)

n = (1:m-1)';
g = n.*sqrt(1./(4.*n.^2-1));
J = -diag(g,1)-diag(g,-1);

[w x] = eig(J);
nds   = diag(x);
wts   = 2*w(1,:).^2;

end

function A = coll_L(ts, tz)

q = numel(ts);
p = numel(tz);

zi = repmat(reshape(tz, [p 1 1]), [1 q q]);
sj = repmat(reshape(ts, [1 q 1]), [p 1 q]);
sk = repmat(reshape(ts, [1 1 q]), [p q 1]);

t1 = zi-sk;
t2 = sj-sk;
idx = find(abs(t2)<=eps);
t1(idx) = 1;
t2(idx) = 1;

A = prod(t1./t2, 3);

end

function A = coll_Lp(ts, tz)

q = numel(ts);
p = numel(tz);

zi = repmat(reshape(tz, [p 1 1 1]), [1 q q q]);
sj = repmat(reshape(ts, [1 q 1 1]), [p 1 q q]);
sk = repmat(reshape(ts, [1 1 q 1]), [p q 1 q]);
sl = repmat(reshape(ts, [1 1 1 q]), [p q q 1]);

t3 = sj(:,:,:,1)-sk(:,:,:,1);
t4 = zi-sl;
t5 = sj-sl;

idx1 = find(abs(t5)<=eps);
idx2 = find(abs(t3)<=eps);
idx3 = find(abs(sk-sl)<=eps);
t5(union(idx1, idx3)) = 1;
t4(union(idx1, idx3)) = 1;
t3(idx2) = 1;
t3       = 1.0./t3;
t3(idx2) = 0;

A = sum(t3.*prod(t4./t5, 4), 3);

end
%!coll_Lm
function A = coll_Lm(ts)

p = numel(ts);

sj = repmat(reshape(ts, [1 p]), [p 1]);
sk = repmat(reshape(ts, [p 1]), [1 p]);
t1 = sj-sk;
idx = abs(t1)<=eps;
t1(idx) = 1;

A = 1./t1;
A = prod(A, 2)';

end %!end_coll_Lm