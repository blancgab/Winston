figure(2);

X = [1,2,3,4,5,6,7,8];
Y = [0,0,2,2,1,1,3,3];

plot(X,Y);
xlim([-5,5]);
ylim([-1,10]);
set(gca,'xtick',-5:5);
set(gca,'ytick',-1:10);
grid;
axis square;

r = .34/2;
d = .34;

w = d;
h = d;

x = 0-r;
y = 0-r;

rectangle('Position',[x,y,w,h]);

x = 0-r;
y = r;

rectangle('Position',[x,y,w,h]);

x = 0-r;
y = 3*r;

rectangle('Position',[x,y,w,h]);

x = 0-r;
y = 5*r;

rectangle('Position',[x,y,w,h]);
