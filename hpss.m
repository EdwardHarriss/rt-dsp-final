[audio0,fs0] = audioread("John Bovey - Passive Aggressive.wav");
[audio1pre,fs1] = audioread("sayitaintso.wav");
audio1 = audio1pre(:,1) + audio1pre(:,2);
fs1 = 44000;
[audio2,fs2] = audioread("John Bovey - Passive Aggressive.wav");
[audio0,fs3] = audioread("John Bovey - Passive Aggressive.wav");
audio = audio0;
fs = fs0;

%we will need to 

spectrogram(audio,1024,512,1024,fs,"yaxis")
title("Harmonic-Percussive Audio")

win = sqrt(hann(1024,"periodic"));
overlapLength = floor(numel(win)/2);
fftLength = 2^nextpow2(numel(win) + 1);
y = stft(audio, ...
        "Window",win, ...
        "OverlapLength",overlapLength, ...
        "FFTLength",fftLength, ...
        "Centered",true);
halfIdx = 1:ceil(size(y,1)/2);
yhalf = y(halfIdx,:);
ymag = abs(yhalf);

timeFilterLength = 0.2;
timeFilterLengthInSamples = timeFilterLength/((numel(win) - overlapLength)/fs);
ymagharm = movmedian(ymag,timeFilterLengthInSamples,2);

surf(flipud(log10(ymagharm.^2)),"EdgeColor","none")
title("Harmonic Enhanced Audio")
view([0,90])
axis tight

frequencyFilterLength = 500;
frequencyFilterLengthInSamples = frequencyFilterLength/(fs/fftLength);
ymagperc = movmedian(ymag,frequencyFilterLengthInSamples,1);

surf(flipud(log10(ymagperc.^2)),"EdgeColor","none")
title("Percussive Enhanced Audio")
view([0,90])
axis tight

totalMagnitudePerBin = ymagharm + ymagperc;

harmonicMask = ymagharm > (totalMagnitudePerBin*0.5);
percussiveMask = ymagperc > (totalMagnitudePerBin*0.5);

yharm = harmonicMask.*yhalf;
yperc = percussiveMask.*yhalf;

yharm = cat(1,yharm,flipud(conj(yharm)));
yperc = cat(1,yperc,flipud(conj(yperc)));

h = istft(yharm, ...
    "Window",win, ...
    "OverlapLength",overlapLength, ...
    "FFTLength",fftLength, ...
    "ConjugateSymmetric",true);
p = istft(yperc, ...
    "Window",win, ...
    "OverlapLength",overlapLength, ...
    "FFTLength",fftLength, ...
    "ConjugateSymmetric",true);

%sound(h,fs)

spectrogram(h,1024,512,1024,fs,"yaxis")
title("Recovered Harmonic Audio")

