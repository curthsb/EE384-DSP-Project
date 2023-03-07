% Load audio from file
filename = uigetfile('.mp3','Select an Audio File')
if(~filename) error("No input file selected.  Terminating."); end

try
    [y, Fs] = audioread(filename);
catch
    error("Error loading file.  Terminating.");
end

   % test signal
%{
Fs = 44100;
t = 0:1/Fs:15;
y = zeros(1,length(t));

for i = 1:length(y)
    y(i) = sin(2*pi*(6000*(1-(i*(1/length(y))))*t(i)));
end
%}

    % player object
% player = audioplayer(y,Fs)

    % data length in samples
length_y = length(y);
    % data length in 
dur_y = length_y/Fs;
    % time vector
%t = linspace(0, (length_y)/Fs, length_y);
    % waveform interval in seconds
time_delta = 0.01;

    %initialize values
window = [0 0];         
time = 0;
wy_max = 1;
fy_max = 1;
f = zeros(1,1024);


    % configure display window
figure(1);
set(gcf, 'Color', 'black');
set(gcf, 'MenuBar', 'None');
set(gcf, 'ToolBar', 'None');
set(gcf, 'WindowState', 'Maximized');
set(gcf, 'Name', 'Visualizer', 'NumberTitle', 'off');
ax1 = subplot(2,1,1);
set(gca, 'Color', 'none');
set(gca, 'Visible', 'off');
ax2 = subplot(2,1,2);
set(gca,'Color','none','XColor',[0 0 0],'YColor',[0 0 0]);

    % set timer start point
start = tic;
    % start and run loop until song ends
player.play;

while(time < dur_y)
        % get window around current time +/- time delta
    time = toc(start);
    window = [ceil((time-time_delta)*Fs) ceil((time+time_delta)*Fs)];
        % bounds-check window
    if(window(1) < 1) window(1) = 1; end
    if(window(2) > length_y) window(2) = length_y; end
        % extend window vector
    window = [window(1):window(2)];

        % generate fft of data in window
    nfft = 2^nextpow2(length(window));
    y_fft = fft(y(window), nfft);
    f = (Fs/2)*linspace(0, 1, nfft/2+1);
        % convert to power by multiplying complex conjugates
    y_pow = y_fft.*conj(y_fft);
        % convert to dB scale
    y_pow = 10*log10(y_pow);
        % trim negative values for cleaner display
    neg = find(y_pow < 0);
    y_pow(neg) = 0;

        % find index of 8KHz upper display limit
    f_limit = round((8000/(Fs/2))*(nfft/2))+1;

        %check upper bound for plot y-axes
    temp = max(y_pow);
    if(temp > fy_max) fy_max = temp; end
    temp = max(abs(y(window)));
    if(temp > wy_max) wy_max = temp; end

        % waveform plot
    subplot(ax1);
    plot(y(window));
    set(gca,'Color','none','XColor',[0 0 0],'YColor',[0 0 0]);
    ylim([-wy_max wy_max]);

        % plot frequency spectrum of window
    subplot(ax2);
    hold off;
    bar(f(1:f_limit), 2*y_pow(1:f_limit));
    set(gca,'Color','none','XColor',[0 0 0],'YColor',[0 0 0]);
    hold on;
    bar(f(1:f_limit), -1*y_pow(1:f_limit));
    set(gca,'Color','none','XColor',[0 0 0],'YColor',[0 0 0]);
    xlim([0 8000]);
    ylim([-fy_max 2*fy_max]);

    pause(2*time_delta);
end

close(figure(1));
