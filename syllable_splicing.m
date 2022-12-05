
listLang = ls('./lpc/');
A = size(listLang);
num_lang = A(1)-2;
count=0;
countsyll=0;
countword=0;
countsent=0;
 
telugu = zeros(1,1601);
guj = zeros(1,1601);

correct=zeros(5,7);
wrong=zeros(5,7);

tol = 0.30;

syll=0.81;
word=11.1;
offset = 0.15;
limit = 0.6;

c1_avg = zeros(1,7);
c2_avg = zeros(1,7);
c3_avg = zeros(1,7);
c4_avg = zeros(1,7);
c5_avg = zeros(1,7);

c1_emp = [0.86,0.40,1.59,0.91,0.58,1.36,1.61];
c2_emp = [0.34,0.15,0.79,0.41,0.23,0.67,0.83];
c3_emp = [1.17,0.55,1.60,1.12,0.74,1.36,1.62];
c4_emp = [1.73,0.84,2.06,1.52,1.19,1.77,1.97];
c5_emp = [0.71,0.34,0.84,0.57,0.37,0.91,0.76];



combgaps = 0;

PLOT = 0;
if(PLOT==1)
figure;
end

for i=1:24
    transpitch(i)=(i-25)*(i-25)/700;
end

outputarr = [];
arrpos = 1;

outputsyll = [];
outsyllpos = 1;

for lang=3:num_lang+2
    
    nowlang = lang-2;
    
    xaxis = [];
    yaxis = [];
            
    
    %figure;
    if(lang==3)
        plotcolor = 'red';
        plotlang = 'assamese';
    end
    if(lang==4)
        plotcolor = 'green';
        plotlang = 'bengali';
    end
    if(lang==5)
        plotcolor = 'yellow';
        plotlang = 'gujarati';
    end
    if(lang==6)
        plotcolor = 'blue';
        plotlang = 'manipuri';
    end
    if(lang==7)    
        plotcolor = 'pink';
        plotlang = 'marathi';
    end
    if(lang==8)    
        plotcolor = 'black';
        plotlang = 'odiya';
    end
    if(lang==9)    
        plotcolor = 'brown';
        plotlang = 'telugu';
    end
    
    pieces = 0;
    
    dir_name = deblank(listLang(lang, :));
    langaddr = strcat('./lpc/', dir_name, '/');
    listSpeaker = ls(langaddr);
    B = size(listSpeaker);
    num_speaker = B(1)-2;
    for speaker=3:num_speaker+2
        sp_name = deblank(listSpeaker(speaker, :));
        csvaddr = strcat(langaddr, sp_name, '/*.csv*');
        listcsv = ls(csvaddr);
        wavaddr = strcat('./lid/', dir_name, '/', sp_name, '/*.wav*');
        listwav = ls(wavaddr);
        C = size(listcsv);
        num_wav = C(1);
        temp = 40;
        
        if(lang==7)
            temp=25;
        end
        if(lang~=7)
            temp=num_wav;
        end
        
        if(temp>num_wav)
            temp=num_wav;
        end
        
        pieces = pieces+temp;
        
        for audio=1:temp
            csvfile = deblank(listcsv(audio, :));
            wavfile = deblank(listwav(audio, :));
            audioaddr = strcat('./lid/', dir_name, '/', sp_name, '/', wavfile);
            [audinput, Fs]= audioread(audioaddr);

            ticket = temp;
            audpitchvec = zeros(1,24);
            audvec2 = zeros(1,24);
            kframes = 0;
            kframes2 = 0;

            check1 = 0;
            check1val = 0;
            check2 = 0;
            check2val = 0;
            check3 = 0;
            check3val = 0;
            check4 = 0;
            check4val = 0;
            check5 = 0;
            check5val = 0;
            
            predict = zeros(5,7);
            decision = zeros(1,5);
            
            fileaddr = strcat(langaddr, sp_name, '/', csvfile); 
            fid = fopen(fileaddr);
            vop_ind = cell2mat(textscan(fid, '%d', 'Delimiter','\n'));
            fclose(fid);
            indsize = length(vop_ind);
            
            ticket = indsize-1;
            
            gaps = zeros(1, indsize-1);
            for iter=2:indsize-1
                gaps(iter-1)= vop_ind(iter)-vop_ind(iter-1);
            end
            
            count= count+indsize;
            gaps = sort(gaps);
            %gaps = movmean(gaps, 5);
            gaps = gaps.^1;
            gaps = gaps-median(gaps);
            gaps = gaps./mean(gaps);
            gaps = gaps.^1;
            combgaps = [combgaps gaps];
            
            for iter=1:indsize-1
                if(gaps(iter)<0)
                    gaps(iter)=0;
                end
                if(gaps(iter)>16)
                    gaps(iter)=16;
                end
                if(gaps(iter)<syll)
                    countsyll=countsyll+1;
                end
                if(gaps(iter)<word && gaps(iter)>syll)
                    countword=countword+1;
                end
                if(gaps(iter)>word)
                    countsent=countsent+1;
                end
                    
            end
            
            wordsize=0;
            sentsize=0;
            
            for i=1:indsize-1
                if(gaps(i)>syll)
                    wordsize=wordsize+1;
                end
                if(gaps(i)>word)
                    sentsize=sentsize+1;
                end
            end
            
            word_ind = zeros(1,wordsize);
            sent_ind = zeros(1,sentsize);
            worditer = 1;
            sentiter = 1;
            
            for i=1:indsize-1
                if(gaps(i)>syll)
                    word_ind(worditer) = vop_ind(i+1);
                    worditer=worditer+1;
                end
                if(gaps(i)>word)
                    sent_ind(sentiter) = vop_ind(i+1);
                    sentiter=sentiter+1;
                end
            end
            
            syllpitchvec = 0;
            for frame=1:indsize-1
                
                offset = 0.241;
                limit = 0.51;


                [syllpitchvec, sylags] = autocorr(audinput(vop_ind(frame):vop_ind(frame+1)), NumLags=1600);
                pitchvector = pitchvec(audinput(vop_ind(frame):vop_ind(frame+1)));
                
                outputsyll(outsyllpos,:) = [pitchvector nowlang];
                outsyllpos = outsyllpos+1;
                
                audpitchvec = audpitchvec+pitchvector;
                kframes = kframes+1;
                
                %xlen = 1:24;
                %xaxis = [xaxis xlen];
                %yaxis = [yaxis pitchvector];
                
                %syllpitchvec = movmean(syllpitchvec, 10);
                savedpitchvec = syllpitchvec;
                syllpitchvec= syllpitchvec-offset;
            
            for i=1:1601
                if(syllpitchvec(i)<0)
                    syllpitchvec(i)=0;
                end
                if(syllpitchvec(i)>limit)
                    syllpitchvec(i)=0;
                end
            end
            
            
            for i=650:1601
                if(syllpitchvec(i)>0.01)
                    check1=sum(syllpitchvec(i:1601));
                    check1val=check1val+sum(syllpitchvec(i:1601));
                    break;
                end
            end
            
            for i=800:1601
                if(syllpitchvec(i)>0.01)
                    check2=sum(syllpitchvec(i:1601));
                    check2val=check2val+sum(syllpitchvec(i:1601));
                    break;
                end
            end
            
            for i=550:800
                if(syllpitchvec(i)>0.01)
                    check3=sum(syllpitchvec(i:800));
                    check3val=check3val+sum(syllpitchvec(i:800));
                    break;
                end
            end
            
            limit = 0.5;
            offset = 0.24;
            
            syllpitchvec= savedpitchvec-offset;
            
            for i=1:1601
                if(syllpitchvec(i)<0)
                    syllpitchvec(i)=0;
                end
                if(syllpitchvec(i)>limit)
                    syllpitchvec(i)=0;
                end
            end
            
            
            for i=400:550
                if(syllpitchvec(i)>0.01)
                    check4=sum(syllpitchvec(i:550));
                    check4val=check4val+sum(syllpitchvec(i:550));
                    break;
                end
            end
            
            limit=0.8;
            offset = 0.34;
            
            syllpitchvec= savedpitchvec-offset;
            
            for i=1:1601
                if(syllpitchvec(i)<0)
                    syllpitchvec(i)=0;
                end
                if(syllpitchvec(i)>limit)
                    syllpitchvec(i)=0;
                end
            end
            
            
            for i=300:370
                if(syllpitchvec(i)>0.01)
                    check5=sum(syllpitchvec(i:370));
                    check5val=check5val+sum(syllpitchvec(i:370));
                    break;
                end
            end
            
            %hold on;
            %plot(sylags, abs(syllpitchvec));
            %title(plotlang);
              
            end
            
            for frame=1:wordsize
                pitchvector2 = pitchvec( audinput(vop_ind(frame):vop_ind(frame+1)) );
                audvec2 = audvec2+pitchvector2;
                kframes2 = kframes2+1;
            end
            
            audvec2 = audvec2./kframes2;
            
            audpitchvec = audpitchvec./kframes;
            %audpitchvec = audpitchvec./transpitch;
            
            xlen = 1:24;
            xaxis = [xaxis xlen];
            yaxis = [yaxis audpitchvec];
            
            outputarr(arrpos,:) = [audpitchvec nowlang];
            arrpos = arrpos+1;
                
            
            check1val= check1val/ticket;
            check2val= check2val/ticket;
            check3val= check3val/ticket;
            check4val= check4val/ticket;
            check5val= check5val/ticket;
            
            for pred=1:7
                    if( abs(c1_emp(pred)-check1val)/c1_emp(pred) < tol )
                        predict(1,pred) = predict(1,pred)+1;
                    end
                    if( abs(c2_emp(pred)-check2val)/c2_emp(pred) < tol )
                        predict(2,pred) = predict(2,pred)+1;
                    end
                    if( abs(c3_emp(pred)-check3val)/c3_emp(pred) < tol )
                        predict(3,pred) = predict(3,pred)+1;
                    end
                    if( abs(c4_emp(pred)-check4val)/c4_emp(pred) < tol )
                        predict(4,pred) = predict(4,pred)+1;
                    end
                    if( abs(c5_emp(pred)-check5val)/c5_emp(pred) < tol )
                        predict(5,pred) = predict(5,pred)+1;
                    end
            end
            
            for i11=1:5
                maxval = max( predict(i11,:) );
                for j=1:7
                    if( predict(i11,j)== maxval )
                        decision(i11)=j;
                    end
                end
            end
            
            tablename1 = strcat('./out/', dir_name, '/', sp_name, '/', csvfile);
            %fileID = fopen(tablename1, 'w');
            for p=1:5
               % fprintf(fileID, '%d\n', decision(p));
                
            end
            %fclose(fileID);
            
            
            for i12=1:5
                if( nowlang==decision(i12) )
                    correct(i12,nowlang)=correct(i12,nowlang)+1;
                end
                if( nowlang~=decision(i12) )
                    wrong(i12,nowlang)=wrong(i12,nowlang)+1;
                end
            end
            
            c1_avg(lang-2)= c1_avg(lang-2)+check1val;
            c2_avg(lang-2)= c2_avg(lang-2)+check2val;
            c3_avg(lang-2)= c3_avg(lang-2)+check3val;
            c4_avg(lang-2)= c4_avg(lang-2)+check4val;
            c5_avg(lang-2)= c5_avg(lang-2)+check5val;
            
            if(PLOT==1)
            axis = ones(1,indsize-1)*(lang+-1+((100+audio)/(100+num_wav)));
            
            plot(axis, gaps, 'o');
            hold on;
            plot(linspace(2.7,9), ones(1,100).*syll);
            plot(linspace(2.7,9), ones(1,100).*word);
            end
            
            %mkdir( strcat('./lpc/', dir_name, '/', sp_name, '/', audfile) );
            
            
            
        end
    end
    
    c1_avg(lang-2) = c1_avg(lang-2)/pieces;
    c2_avg(lang-2) = c2_avg(lang-2)/pieces;
    c3_avg(lang-2) = c3_avg(lang-2)/pieces;
    c4_avg(lang-2) = c4_avg(lang-2)/pieces;
    c5_avg(lang-2) = c5_avg(lang-2)/pieces;
    
    knum(lang-2)=pieces;
    
    figure;
    plot(xaxis, yaxis, 'o');
    ylim([0 0.7]);
    title(plotlang);
    %hold on;
    
end

for i=1:7
    accuracy(i) = 100*max( correct(:,i) )/knum(i);
end

if(PLOT==1)
figure;
histogram(combgaps, 1000, 'BinLimits',[0.06,17]);
end
