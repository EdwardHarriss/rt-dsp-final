[audio0,fs0] = audioread("John Bovey - Passive Aggressive.wav");
%[audio1pre,fs1] = audioread("sayitaintso.wav");
%audio1 = audio1pre(:,1) + audio1pre(:,2);
%fs1 = 44000;
[audio2,fs2] = audioread("John Bovey - Passive Aggressive.wav");
[audio0,fs3] = audioread("John Bovey - Passive Aggressive.wav");
audio = audio0;
fs = fs0;



[h1,p] = compute_hpss(audio,256,fs);
[h2,v] = compute_hpss(h1,4096,fs);

shorter = min(numel(h2),numel(p));
newh = h2(1:shorter);
newp = p(1:shorter);
newv = v(1:shorter);

output = newh + newp - 30*newv;

sound(output)
