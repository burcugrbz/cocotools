function [F]=tor(xx,pp)
% p = [nu be ga r a3 b3]

nu=pp(1,:);
be=pp(2,:);
ga=pp(3,:);
r =pp(4,:);
a3=pp(5,:);
b3=pp(6,:);

x=xx(1,:);
y=xx(2,:);
z=xx(3,:);

F(1,:)= ( -(be+nu).*x + be.*y - a3.*x.^3 + b3.*(y-x).^3 )./r;
F(2,:)=  be.*x - (be+ga).*y - z - b3.*(y-x).^3;
F(3,:)= y;
