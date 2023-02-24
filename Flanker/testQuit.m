function testQuit()

cleanupObj = onCleanup(@cleanMeUp);

try
    fh = figure;
    ah = axes(fh);
    ph = plot(ah, 1,1);
    ah.XLim = [1 1000];
    ah.YLim = [1 1000];
    for i = 1:1000
        ph.YData = 1:i;
        ph.XData = 1:i;
        pause(.025)
        drawnow
    end

catch
    close(fh)
end

% fires when main function terminates
    function cleanMeUp()
        objs = findall();
        objs
    end

end


