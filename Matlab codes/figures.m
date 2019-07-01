real=[320 280 250 210 170];
measured=[316.6 275.8 258.4 212.2 174.1];
error=[1.0625 1.5 -3.36 -1.0476 -2.4117];
time=[32 26.34 22.79 17.45 9.77];

subplot(2,1,1);
plot(real,error)
title('Distance-Error Relationship');
ylabel('Error Percentage');
xlabel('Distance (cm)');
axis([170 320 -30 30]);
grid on
grid minor

subplot(2,1,2);
plot(time,real)
title('Time-Distance Relationship');
ylabel('Distance (cm)');
xlabel('Time (sec)');
axis([9.77 32 170 320]);
hold on
plot(time,measured)
legend('Real','Measured');
grid on
grid minor
