%% Set python venv 'nanocompute'
% terminate(pyenv); % Comment this line on Mac and Uncomment on Windows
pyenv('Version', ...
'C:\Users\chena\miniconda3\envs\nanocompute\python.exe', ...
'ExecutionMode','OutOfProcess');

%% Matlab call python script
clear;
close all;
clc;

tStart = tic;

% Calculate reflection of the nanostructure 
phc = py.importlib.import_module('matlab_py_cosim');
results = phc.calc_rspace();

% Use user-defined function 'pylist2double' on Windows,
% for MATLAB 2021b, matching the conda env 'S4' with python3.7;
% Use build-in function 'double' on Mac for MATLAB >=2022 versions,
% or you can also use 'pylistdouble'
omegaSpace = pylist2double(results{1});
RSpace = pylist2double(results{2});


% Plot the R spectrum
figure(1);
plot(omegaSpace, RSpace, 'r'); 
grid on;
xlabel('Frequency (2\pic/a)');
ylabel('Reflectance');

% Calculate the elapsed time
elapsedTime = toc(tStart);
fprintf('Code running time: %.6f seconds\n', elapsedTime);