clear;
clc;

%%
% filename='The Rope River Blues Band - Capulet.mp3';
% filename='Flux Without Pause - Space Mothlight- A collaboration with Diana Norma Szokolyai (1).mp3';


%%
filename='sayitaintso.mp3';
[y,Fs]=audioread(filename);


if(false)
    disp('Error: the audio file isn''t encoded at 44.1 kHz');
else
    % the following code applies a lowpass filter and resamples the audio file
    [n,fo,ao,w] = firpmord([3900, 4050]/(Fs/2),[1, 0], [(10^(2/20)-1)/(10^(2/20)+1) 10^(-40/20)]);
    b = firpm(n, fo, ao, w);
    y=(y(:,1)+y(:,2));
    yfil=filter(b,1,y);
    
    
    yfil=y/max(abs(y));
    yfil = y;
    r=Fs/8000;
    
    samples=yfil(round(1:r:length(yfil)))';
    
    clear y Fs n fo ao w b yfil r filename
    
    disp('The audio is ready to be played');
end