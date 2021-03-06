switchpath('old')
opts = coco_add_func('fun', @catenary, [], 'zero', 'x0', [5.5531 ; -0.4321 ; 2.1131]);
opts = coco_add_parameters(opts, '', 3, 'Y');
opts = coco_add_slot(opts, 'bd_cb', @bddat, [], 'bddat');

data.dfdx = @catenary_DFDX;
data.c = (1:2)';
data.c = data.c/norm(data.c,2);
data.b = data.c;

data_ptr = coco_ptr(data);

opts = coco_add_func(opts,'fundx1', @catenary_fold2, data_ptr, 'regular', 'fold');
opts = coco_add_slot(opts, 'update', @update, data_ptr, 'covering_update');

opts = coco_add_event(opts, 'LP', 'fold', 0);

opts = coco_set(opts, 'cont', 'ItMX', 100);
bd = coco(opts, 'run', [], 'Y', [.1, 20]);

a = coco_bd_col(bd, 'a');
b = coco_bd_col(bd, 'b');
Y = coco_bd_col(bd, 'Y');
idx = find(strcmp('LP', coco_bd_col(bd, 'TYPE')));

figure(1)
clf
hold on
plot3(Y,a,b,'r')
plot3(Y,a,b,'b.')
plot3(Y(idx),a(idx),b(idx),'rs')
hold off