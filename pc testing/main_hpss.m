% #############################################
% ############## FIRST STAGE ##################
% #############################################

%declaring first stage variable widths
stft_sample_size = 256; 
window_size = stft_sample_size/2; 
iteration = window_size/2; 
beta = 2;

audio_in = 'John Bovey - Passive Aggressive.wav';   %name of input file

x = dsp.AudioFileReader(audio_in,'SamplesPerFrame',iteration);
fs = x.SampleRate;  %should be at 8kHz;
stage_one_harm = dsp.AudioFileWriter('harm_first_stage.wav','FileFormat','WAV','SampleRate',fs);
stage_one_perc = dsp.AudioFileWriter('perc_first_stage.wav','FileFormat','WAV','SampleRate',fs);

window = sqrt(hann(window_size, "periodic")); %always hann window, see document

hpss_function(x, stage_one_perc, stage_one_harm, stft_sample_size, window_size, iteration, beta, fs, window);

release(stage_one_perc);
release(stage_one_harm);
release(x);

stft_sample_size = 4096; 
window_size = stft_sample_size/2; 
iteration = window_size/2;

x_second_stage = dsp.AudioFileReader('harm_first_stage.wav','SamplesPerFrame',iteration);
fs = x.SampleRate;  %should be at 8kHz;
harmonic = dsp.AudioFileWriter('backing_track.wav','FileFormat','WAV','SampleRate',fs);
percussive = dsp.AudioFileWriter('vocal_track.wav','FileFormat','WAV','SampleRate',fs);

window2 = sqrt(hann(window_size, "periodic"));

hpss_function(x_second_stage, percussive, harmonic, stft_sample_size, window_size, iteration, beta, fs, window2);

release(percussive);
release(harmonic);
release(x_second_stage);

backing = audioread('backing_track.wav');
percussive = audioread('perc_first_stage.wav');
voice = audioread('vocal_track.wav');

shorter = min(numel(backing),numel(percussive));
newh = backing(1:shorter);
newp = percussive(1:shorter);
newv = voice(1:shorter);

output = (newh + newp) - 10.*newv;
audiowrite('output.wav',output,fs);









