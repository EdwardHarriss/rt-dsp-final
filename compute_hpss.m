function [h,p] = hpssfunc(input,frameSize,fs)
win1 = sqrt(hann(frameSize,"periodic"));
overlapLength1 = floor(numel(win1)/2);
fftLength1 = 2^nextpow2(numel(win1) + 1);

y = stft(input, ...
        "Window",win1, ...
        "OverlapLength",overlapLength1, ...
        "FFTLength",fftLength1, ...
        "Centered",true);
halfIdx = 1:ceil(size(y,1)/2); %get range for 1-sided specturm
yhalf = y(halfIdx,:); %convert to 1-sided spectrum
ymag = abs(yhalf); %get absolute values

%apply median smoothing on time axis
timeFilterLength = 0.1;
timeFilterLengthInSamples = timeFilterLength/((numel(win1) - overlapLength1)/fs); %this must be kept small for real time processing
ymagharm = movmedian(ymag,timeFilterLengthInSamples,2); %change this to dsp.MovingMedian

frequencyFilterLength = 500;
frequencyFilterLengthInSamples = frequencyFilterLength/(fs/fftLength1);
ymagperc = movmedian(ymag,frequencyFilterLengthInSamples,1);

totalMagnitudePerBin = ymagharm + ymagperc;

harmonicMask = ymagharm > (totalMagnitudePerBin*0.5);
percussiveMask = ymagperc > (totalMagnitudePerBin*0.5);

yharm = harmonicMask.*yhalf;
yperc = percussiveMask.*yhalf;

yharm = cat(1,yharm,flipud(conj(yharm)));
yperc = cat(1,yperc,flipud(conj(yperc)));

h = istft(yharm, ...
    "Window",win1, ...
    "OverlapLength",overlapLength1, ...
    "FFTLength",fftLength1, ...
    "ConjugateSymmetric",true);
p = istft(yperc, ...
    "Window",win1, ...
    "OverlapLength",overlapLength1, ...
    "FFTLength",fftLength1, ...
    "ConjugateSymmetric",true);


%STAGE 1 COMPLETE