width = 5
points = 100
t = linspace(-width/2,width/2,points);
[X, Y, Z] = meshgrid(t);

function f = f(t)
f = normpdf(5*t) + 2*normpdf(5*(t-2));
endfunction

T = f(X).*f(X+Y).*f(X+Z);
size(T)
T_sum = sum(T, 2) * (width/points);
T_squeeze = squeeze(T_sum);

figure()
imshow(flip(T_squeeze, 2) ./ max(T_squeeze(:)))
%subplot(3, 4, 5)
%surf(t, t, T_squeeze ./ max(T_squeeze(:)))

t0 = 2
t1 = 0
figure()
subplot(4, 1, 1)
plot(t, f(t))
subplot(4, 1, 2)
plot(t, f(t+t0))
subplot(4, 1, 3)
plot(t, f(t+t1))
subplot(4, 1, 4)
plot(t, f(t).*f(t+t0).*f(t+t1))
