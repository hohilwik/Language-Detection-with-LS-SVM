
listLang = ls('./lid/');
A = size(listLang);
num_lang = A(1)-2;

g = zeros(1,800);
sigma = 100;
wo = 0.0114;
pi = 3.1415926535;
nancount=0;

for i=1:800
    g(i) = (1/sqrt(2*pi*sigma*sigma))*exp( (-1*i*i)/(2*sigma*sigma) )*cos(wo*i);
end

for lang=3:num_lang+2
    dir_name = deblank(listLang(lang, :));
    langaddr = strcat('./lid/', dir_name, '/');
    listSpeaker = ls(langaddr);
    B = size(listSpeaker);
    num_speaker = B(1)-2;
    for speaker=3:num_speaker+2
        sp_name = deblank(listSpeaker(speaker, :));
        wavaddr = strcat(langaddr, sp_name, '/*.wav*');
        listwav = ls(wavaddr);
        C = size(listwav);
        num_wav = C(1);
        for audio=1:num_wav
            audfile = deblank(listwav(audio, :));
            fileaddr = strcat(langaddr, sp_name, '/', audfile); 
            [audinput, Fs]= audioread(fileaddr);
            frames = size(audinput)/(Fs/50);
            step = floor(Fs/50);
            gpart = g(1:step-1);
            %mkdir( strcat('./lpc/', dir_name, '/', sp_name, '/', audfile) );
            
            for frame=1:frames(1)-1
                audframe = audinput( ( ((frame-1)*step)+1): (frame*step)+1);
                audlpc = lpc(audframe, 10);
                if(frame==1)
                    %audproc = transpose(audlpc);
                end
                %audproc = [audproc transpose(audlpc)];
                
                audfft = fft(audframe, step);
                rw = zeros(1,step);
                rhw = zeros(1,step);
                halfstep = step/2;
                for z=1:step
                    h = zeros(1, step);
                    for k=1:11
                        h(z) = h(z)+(audlpc(k)*(z^(-k)) );
                    end
                    h(z) = h(z)+1;
                    rw(z) = audfft(z)*h(z);
                    rhw(z) = rw(z);
                    if(z<halfstep)
                        rhw(z) = rhw(z)*(-1j);
                    end
                    if(z>=halfstep)
                        rhw(z) = rhw(z)*(1j);
                    end
                    
                end
                
                r = ifft(rw, step);
                rh = ifft(rhw, step);
                h_env = zeros(1,step);
                
                for pos=1:step
                   r(pos) = abs(r(pos));
                   rh(pos) = abs(r(pos));
                   h_env(pos) = sqrt( abs(r(pos)*r(pos))+abs(rh(pos)*rh(pos)) );
                end
                
                vop_frame = conv(h_env, gpart, 'same');
                %vop_frame = ifft( fft(h_env, step).*fft(gpart, step), step);
                
                % throw away first frame as it gives NaN
                if(frame<2)
                    vop_evidence = vop_frame;
                end
                
                if(frame>=2)
                    vop_evidence = [vop_evidence vop_frame];
                end
                
            end
            
            vop_last_valid = 0;
            
            for p=1:length(vop_evidence)
                if( isnan(vop_evidence(p)) )
                    vop_evidence(p) = vop_last_valid;
                end
                if( ~isnan(vop_evidence(p)) )
                    vop_last_valid = vop_evidence(p);
                end
            end
            
            meanvop = mean(vop_evidence);
            minvop = min(vop_evidence);
            
            if(isnan(meanvop))
                meanvop=-2
            end
            
            for iter=1:length(vop_evidence)
               if(vop_evidence(iter)<meanvop)
                   vop_evidence(iter)=minvop;
               end
            end
            
            
            vop_evidence = movmean(vop_evidence, step*10);
            meanvop = mean(vop_evidence);
            if(isnan(meanvop))
                meanvop=-2;
                nancount = nancount+1
                
            end
                
            
                
                
            
            [pks, locs] = findpeaks(vop_evidence, 'MinPeakDistance', step*5, 'MinPeakHeight', meanvop);
            
            %figure;
            %plot(1:length(vop_evidence), vop_evidence);
            %hold on;
            %plot(locs, pks, 'o');
            
            
            tablename1 = strcat('./lpc/', dir_name, '/', sp_name, '/', audfile, '.csv');
            %T1 = table(locs');
            %writetable(T1, tablename1);
            fileID = fopen(tablename1, 'w');
            for p=1:length(locs)
                fprintf(fileID, '%d\n', locs(p));
                
            end
            fclose(fileID);
        end
    end
end
