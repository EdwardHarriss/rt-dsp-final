[audio0,fs0] = audioread("John Bovey - Passive Aggressive.wav");
%[audio1pre,fs1] = audioread("sayitaintso.wav");
%audio1 = audio1pre(:,1) + audio1pre(:,2);
%fs1 = 44000;
[audio2,fs2] = audioread("John Bovey - Passive Aggressive.wav");
[audio0,fs3] = audioread("John Bovey - Passive Aggressive.wav");
audio = audio0;
fs = fs0;

%we will need to 

%spectrogram(audio,1024,512,1024,fs,"yaxis")
%title("Harmonic-Percussive Audio")

win1 = sqrt(hann(256,"periodic"));
overlapLength1 = floor(numel(win1)/2);
fftLength1 = 2^nextpow2(numel(win1) + 1);

y = stft(audio, ...
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

%surf(flipud(log10(ymagharm.^2)),"EdgeColor","none")
%title("Harmonic Enhanced Audio")
%view([0,90])
%axis tight

frequencyFilterLength = 500;
frequencyFilterLengthInSamples = frequencyFilterLength/(fs/fftLength1);
ymagperc = movmedian(ymag,frequencyFilterLengthInSamples,1);

%surf(flipud(log10(ymagperc.^2)),"EdgeColor","none")
%title("Percussive Enhanced Audio")
%view([0,90])
%axis tight

totalMagnitudePerBin = ymagharm + ymagperc;

harmonicMask = ymagharm > (totalMagnitudePerBin*0.5);
percussiveMask = ymagperc > (totalMagnitudePerBin*0.5);

yharm = harmonicMask.*yhalf;
yperc = percussiveMask.*yhalf;

yharm = cat(1,yharm,flipud(conj(yharm)));
yperc = cat(1,yperc,flipud(conj(yperc)));

h1 = istft(yharm, ...
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

%STAGE 2:

win2 = sqrt(hann(4096,"periodic"));
overlapLength2 = floor(numel(win2)/2);
fftLength2 = 2^nextpow2(numel(win2) + 1);

y2 = stft(h1, ...
        "Window",win2, ...
        "OverlapLength",overlapLength2, ...
        "FFTLength",fftLength2, ...
        "Centered",true);
halfIdx2 = 1:ceil(size(y2,1)/2); %get range for 1-sided specturm
y2half = y2(halfIdx2,:); %convert to 1-sided spectrum
y2mag = abs(y2half); %get absolute values

%apply median smoothing on time axis
timeFilterLength2 = 0.1;
timeFilterLengthInSamples2 = timeFilterLength2/((numel(win2) - overlapLength2)/fs); %this must be kept small for real time processing
y2magharm = movmedian(y2mag,timeFilterLengthInSamples2,2); %change this to dsp.MovingMedian

frequencyFilterLength2 = 500;
frequencyFilterLengthInSamples2 = frequencyFilterLength2/(fs/fftLength2);
y2magperc = movmedian(y2mag,frequencyFilterLengthInSamples2,1);

totalMagnitudePerBin2 = y2magharm + y2magperc;

harmonicMask2 = y2magharm > (totalMagnitudePerBin2*0.5);
percussiveMask2 = y2magperc > (totalMagnitudePerBin2*0.5);

yharm2 = harmonicMask2.*y2half;
yperc2 = percussiveMask2.*y2half;

yharm2 = cat(1,yharm2,flipud(conj(yharm2)));
yperc2 = cat(1,yperc2,flipud(conj(yperc2)));

h2 = istft(yharm2, ...
    "Window",win2, ...
    "OverlapLength",overlapLength2, ...
    "FFTLength",fftLength2, ...
    "ConjugateSymmetric",true);
v = istft(yperc2, ...
    "Window",win2, ...
    "OverlapLength",overlapLength2, ...
    "FFTLength",fftLength2, ...
    "ConjugateSymmetric",true);



shorter = min(numel(h2),numel(p));
newh = h2(1:shorter);
newp = p(1:shorter);
newv = v(1:shorter);

output = newh + newp - 20*newv;
%sound(output)



%voice = newh-instr;
%shorter = min(numel(voice),numel(h));
%newh = h(1:shorter);
%newp = p(1:shorter);
%melody = newh + newp - 3*voice;
