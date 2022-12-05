function y = pitchvec(X)
    vec = autocorr(X, NumLags=1600);
    %vec = movmean(vec, 10);
    y = zeros(1,24);
    for i=4:27
        y(i-3) = max(vec( 50*i:50*(i+1) ) );
    end

end