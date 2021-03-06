function circ05
% allow x and p to be vectors

% f = @(x,p) x^2 + p^2 - 1;
% f  = @(x,p) (p+x-x^3)*((x-2)^2-p+2);
f = @(x,p) [
  x(1)^2+x(2)^2-p(1)^2
  [sin(p(2)) 0 cos(p(2))]*[x(1);x(2);p(1)-1]
  ];

opts = [];
opts = circle_create(opts, f, [sqrt(0.5);sqrt(0.5)], [1;0.3]);

% run continuation, name branch '1'
bd = coco(opts, '1', [], 'PAR(1)', [-2 2]);

% plot bifurcation diagram
x = coco_bd_col(bd, 'x');
p = coco_bd_col(bd, 'p');
plot(x(1,:), x(2,:))
axis equal

end

function opts = circle_create(opts, f, x0, p0)

% initialise data structure
data.f = f;
data.x_idx = 1:numel(x0);
data.p_idx = data.x_idx(end) + (1:numel(p0));

% add continuation problem (zero problem)
opts = coco_add_func(opts, 'circle', @circle, data, 'zero', ...
  'x0', [ x0 ; p0 ]);

% define u(data.p_idx) as parameters
opts = coco_add_parameters(opts, '', data.p_idx, 1:numel(p0));

% add x to bifurcation diagram
opts = coco_add_slot(opts, 'circle_bddat', @circle_bddat, ...
  data, 'bddat');

% add x to screen output
opts = coco_add_slot(opts, 'circle_print', @circle_print, ...
  [], 'cont_print');

end

function [data y] = circle(opts, data, u) %#ok<INUSL>
y = data.f(u(data.x_idx), u(data.p_idx));
end

function [data res] = circle_bddat(opts, data, command, sol) %#ok<INUSL>
switch command
  case 'init'
    res = { 'x' 'p' };
  case 'data'
    res = { sol.x(data.x_idx) sol.x(data.p_idx) };
end
end

function data = circle_print(opts, data, command, x) %#ok<INUSL>
switch command
  case 'init'
    fprintf('%10s', 'x');
  case 'data'
    fprintf('%10.2e', x(1));
end
end
