function y = pneta(x, p, model)

y(1,:) = x(2,:);
y(2,:) = (0.5*p(1,:)).*x(2,:)-p(1,:).*x(2,:).^3-x(1,:);

end