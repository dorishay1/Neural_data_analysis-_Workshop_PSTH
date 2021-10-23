clear; close all; clc;
% Ex - 2


    
%% question #1    
% Get the data
load 'SpikesX10U12D.mat';
[n_neuron, n_direc, n_repeat] = size(SpikesX10U12D);                    %set the size of neurons, direction and repetitions.
spike_time=[] ;                                                         %an empty vector, that will contain the spikes time.
bin_size=0.02;                                                          %set bin size for the PSTH plot in seconds.
time_exp = 1.28;                                                        %time of the experimant in seconds
bins= (0:bin_size:time_exp);                                            %bins vector, will be used for the PSTH plot.
str = [  "\theta   =  0°"   ,"\theta   = 30°","\theta   = 60°" ...
    ,"\theta   = 90°","\theta   = 120°","\theta   = 150°", ...
    "\theta   = 180°","\theta   = 210°","\theta   = 240°",...
    "\theta   = 270°","\theta   = 300°","\theta   = 330°"];
data = zeros(n_neuron,n_direc,n_repeat);                                %matrix that will contain the number of spikes in each neuron, direction and repetition.
unit = 3;                                                               %set the number of neuron that the code will produce a PSTH plot for him.

for i = 1:n_neuron                                                      %loop that go on each neuron.  
    for j = 1:n_direc                                                   %loop that go on each direction.
         spike_time=[];                                                 %"spikes_time" vector wiil include the spikes time and will reset after each direction.
         
         for k = 1:n_repeat                                             %loop that go on each repetition.

            t_vec =  SpikesX10U12D(i,j,k).TimeList;                     %new vector that contain the spikes time in the (i, j, k) place, namely, 
                                                                        %the spikes time of the i neuron, in the j direction and the k repetition.
          
                spike_time = [spike_time,t_vec'];                       %connect the spike times in each "t_vec" vector, in to a one long vector name "spike_time".
                data(i,j,k) = length(t_vec);                            %the number of spikes in the current neurons, direction and repetition, will preserve in the appropriate indexes in q matrix.
                                          
         end
         
         if i == unit                                                   %if the number of neuron is equal to the set number of the variable "unit", the code Will produce
                                                                        % subplot for each direction.
             subplot(2,6,j)
             spikes_counter = histcounts(spike_time,length(bins));      %partitions the values in "spike_time" returns the count in each bin
             spikes_counter = (spikes_counter/n_repeat)/bin_size;       %calculation of the mean firing rate (Hz) in each bin.
             bar(bins, spikes_counter);                                 %produce plot with the mean firing rate (Hz) in each bin in the i neuron and the j direction.
             xlabel({'time','(seconds)'})
             ylabel({'rate','(Hz)'})                                  
             hold off;
             
             set(gca,'YLim',[0 35],'XLim',[0 1.28]);
             title(str(j))
             
             txt = ['Unit #',num2str(unit),'- PSTH per direction'];
             sgtitle(txt)
             
         elseif i ~= unit                                               %if the number of neuron is not equal to the set number of the variable "unit", continue.
                          
             continue
         end
        
         
    end
end




%setting figure size
x0=10;
y0=10;
width=1850;
height=400;
set(gcf,'position',[x0,y0,width,height])

%% question #2

data = data/time_exp;                                                   %we divide the number of spikes per unit&direction with the experimant time in order to get the avarage firring rate in Hz.                        
mean_spikes = mean(data,3);                                             %mean the firring rate regarding the number of repitations.
sd_spikes = std(data,1,3);                                              %standart deviation for the firring rate regarding the number of repitations.

X_vec = 0:0.01:2*pi;                                                    %the input for the function that we will find that fits the data.
x = 0:pi/6:(11/6)*pi;                                                   %the input of the original data.



figure ('Color', 'w', 'Units', 'centimeters', 'Position', [0 0 25 10]); hold on;

%setting the equations
l1 = 'A*exp(k*cos(x-PO))';
l2 = 'A * exp (k * cos (2*(x- PO)))';

My_equations = char(l1, l2);


%for each neuron, the code takes the mean spikes and fitting it the first
%equation and plot it. after that, the code fits the second equation, if
%the RMSE is lower than the first fit (lower RMSE means better fit) the
%code plots the curve for the second eqution insteat of the first one.

for i = 1:n_neuron
    y = mean_spikes(i,:);                       
    rmse_check = 200;
    for z = 1:2
     myEquation = My_equations(z,:);
     
     %Define the independent variable and the coefficients to be fitted
     FitDeff = fittype(myEquation, ...
                  'coefficients', {'A', 'k', 'PO'}, ...
                  'independent', 'x');
              %Define the coefficients' exploration space and the starting point
              fitOpt = fitoptions (FitDeff);
              fitOpt.Lower       = [0,   0,      -pi];
              fitOpt.Upper       = [inf,    inf,       pi];
              fitOpt.Startpoint  = [pi/3,    pi/3,           pi/3];
              [fitResult, GoF] = fit(x', y', FitDeff, fitOpt); % GOF = goodness of fit
              if rmse_check > GoF.rmse
                  rmse_check = GoF.rmse;
                  txt = ["'Unit #',num2str(i)"];
                  hold off;
                  subplot(2,5,i)
                  errorbar (x, y, sd_spikes(i,:), 'o');hold on;
                  plot (X_vec, fitResult(X_vec), 'r');
                  xticks([0:pi/2:2*pi])                                 
                  xticklabels({'0','90','180','270','360'})             %shows the units on the x axes as degrees (and not radians)
                  xlabel({'direction','(deg)'})
                  ylabel({'rate','(Hz)'})
                  xlim([0 pi*2])
                  title(['Unit #',num2str(i)])
                  hold off;
                  
              else
                  continue
              end
              %headline and legend for the plots
                  sgtitle('Direction/orientation selectivity - Von Mises fit per unit')
                  if i == 5
                  legend('rate','VM fit','FontSize', 5)
                  else
                      continue
                  end
    
    end
end
