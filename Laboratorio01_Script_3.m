% Cleaning variables and console
clear all
clc

% Read input data
% Creating input/output patterns
rio_01_Camargos = load('Rio 01 Camargos.txt');
rio_02_Furnas = load('Rio 02 Furnas.txt');
rio_03_Itutinga = load('Rio 03 Itutinga.txt');

Prio_01_Camargos = [];
Trio_01_Camargos = [];

Prio_02_Furnas = [];
Trio_02_Furnas = [];

Prio_03_Itutinga = [];
Trio_03_Itutinga = [];

for i=1:1:size(rio_01_Camargos, 1) - 2
    Prio_01_Camargos = [Prio_01_Camargos rio_01_Camargos(i, :)'];
    Trio_01_Camargos = [Trio_01_Camargos rio_01_Camargos(i+1, :)'];

    Prio_02_Furnas = [Prio_02_Furnas rio_02_Furnas(i, :)'];
    Trio_02_Furnas = [Trio_02_Furnas rio_02_Furnas(i+1, :)'];

    Prio_03_Itutinga = [Prio_03_Itutinga rio_03_Itutinga(i, :)'];
    Trio_03_Itutinga = [Trio_03_Itutinga rio_03_Itutinga(i+1, :)'];
end

P = [Prio_01_Camargos; Prio_02_Furnas; Prio_03_Itutinga];
T = [Trio_01_Camargos; Trio_02_Furnas; Trio_03_Itutinga];

% Creating MLP network architecture
net = feedforwardnet(190);
net = configure(net, P, T);

% Divide Training, Validation and Test data
net.divideFcn = 'dividerand';
net.divideParam.trainRatio = 1.00;
net.divideParam.valRatio = 0.00;
net.divideParam.testRatio = 0.00;

% Initializing network
net = init(net);

% Training the Neural Network
net.trainParam.showWindow = true;
net.layers{1}.dimensions = 190;
net.layers{1}.transferFcn = 'tansig';
% net.layers{2}.dimensions = 30;
% net.layers{2}.transferFcn = 'tansig';
% net.layers{3}.dimensions = 25;
% net.layers{3}.transferFcn = 'tansig';
% net.layers{4}.transferFcn = 'purelin';
net.layers{2}.transferFcn = 'purelin';
net.performFcn = 'mse';

% net.trainFcn = 'trainlm';
net.trainFcn = 'trainrp';
% net.trainFcn = 'traincgp';
% net.trainFcn = 'trainbr';

net.trainParam.epochs = 1000000;
net.trainParam.time = 60*20;
net.trainParam.lr = 0.2;
net.trainParam.min_grad = 10^-18;
net.trainParam.max_fail = 1000;

[net, tr] = train(net, P, T);

size_data = ((size(rio_01_Camargos, 1)-1)*size(rio_01_Camargos, 2));
xS=1:1:(size_data + 12);
PsA=[rio_01_Camargos(1,:)'; rio_02_Furnas(1, :)'; rio_03_Itutinga(1, :)'];
Ms=PsA;
for i=1:1:(size(rio_01_Camargos, 1)-1)
    PsD=sim(net,PsA);
    Ms=[Ms PsD];
    PsA=PsD;
end

yS=[];

for i=1:1:size(rio_01_Camargos, 1)
    yS=[yS Ms(:,i)'];
end

% Simulate the output answers - Camargos River

% Plot Training patterns
xP=1:1:size_data;
xF=size_data+1:1:(size_data + 12);

XcamargosP=[];

for i=1:1:(size(rio_01_Camargos, 1)-1)
    XcamargosP = [XcamargosP rio_01_Camargos(i,:)];
end

figure;
XcamargosF=rio_01_Camargos(size(rio_01_Camargos, 1),:);
plot(xP,XcamargosP,'k',xF,XcamargosF,'r')
xlabel('Months')
ylabel('Flow Rate')
title('Camargos River Flow Rate')
grid

% Plot Simulation Results
hold on
plot(xS,yS(1, 0*(size_data + 12)+1:1*(size_data + 12)),':m');
legend('Input data (real)', 'Output data (real)', 'Simulated results from the network');


% Simulate the output answers - Furnas River

% Plot Training patterns
XfurnasP=[];

for i=1:1:(size(rio_02_Furnas, 1)-1)
    XfurnasP = [XfurnasP rio_02_Furnas(i,:)];
end

figure;
XfurnasF=rio_02_Furnas(size(rio_02_Furnas, 1),:);
plot(xP,XfurnasP,'k',xF,XfurnasF,'r')
xlabel('Months')
ylabel('Flow Rate')
title('Furnas River Flow Rate')
grid

% Plot Simulation Results
hold on
plot(xS,yS(1, 1*(size_data + 12)+1:2*(size_data + 12)),':m');
legend('Input data (real)', 'Output data (real)', 'Simulated results from the network');

% Simulate the output answers - Itutinga River

% Plot Training patterns
XItutingaP=[];

for i=1:1:(size(rio_03_Itutinga, 1)-1)
    XItutingaP = [XItutingaP rio_03_Itutinga(i,:)];
end

figure;
XItutingaF=rio_03_Itutinga(size(rio_03_Itutinga, 1),:);
plot(xP,XItutingaP,'k',xF,XItutingaF,'r')
xlabel('Months')
ylabel('Flow Rate')

title('Itutinga River Flow Rate')
grid

% Plot Simulation Results
hold on
plot(xS,yS(1, 2*(size_data + 12)+1:3*(size_data + 12)),':m');
legend('Input data (real)', 'Output data (real)', 'Simulated results from the network');