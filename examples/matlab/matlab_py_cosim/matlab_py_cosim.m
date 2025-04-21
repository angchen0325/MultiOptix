%% Set python venv 'nanocompute'
pyenv('Version', ...
'/Users/apple/VenvPy/nanocompute/bin/python3', ...
'ExecutionMode','OutOfProcess');

%% Matlab call python script
clear;
close all;
clc;

tStart = tic;

% Calculate reflection of the nanostructure 
phc = py.importlib.import_module('matlab_py_cosim');
results = phc.calc_rspace();
omegaSpace = double(results{1});
RSpace = double(results{2});

% Plot the R spectrum
figure(1);
plot(omegaSpace, RSpace, 'r'); 
grid on;
xlabel('Frequency (2\pic/a)');
ylabel('Reflectance');

% Calculate the elapsed time、
elapsedTime = toc(tStart);
fprintf('Code running time: %.6f seconds\n', elapsedTime);