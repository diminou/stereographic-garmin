import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class StereographicView extends WatchUi.WatchFace {
    
    hidden var h, w, pixsample, fifth, depthmap, font;
    hidden var digitHeight = 10;
    hidden var digitWidth = 7;
    hidden var fontWidth = 35;
    hidden var fontHeight = 20;
    hidden var redepthH, redepthh, redepthM, redepthm, hmiddle, vmiddle;
    hidden var fontChunks = new[10];
    hidden var currentMinutes, minutes;

    function initialize() {
        WatchFace.initialize();
        pixsample = 9;

        font = [
            [0,3,3,3,3,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,3,0,3,3,3,3,3,0,3,3,0,0,3,3,0],
            [0,3,3,3,3,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,3,0,3,3,3,3,3,0,3,3,0,0,3,3,0],
            [0,3,3,0,0,3,3,0,0,0,0,3,3,3,0,0,0,0,0,3,3,0,0,0,0,3,3,0,3,3,0,0,3,3,0],
            [0,3,3,0,0,3,3,0,0,0,0,0,3,3,0,0,0,0,0,3,3,0,0,0,0,3,3,0,3,3,0,0,3,3,0],
            [0,3,3,0,0,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,3,0,0,0,3,3,3,0,3,3,3,3,3,3,0],
            [0,3,3,0,0,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,3,0,0,0,3,3,3,0,3,3,3,3,3,3,0],
            [0,3,3,0,0,3,3,0,0,0,0,0,3,3,0,3,3,0,0,0,0,0,0,0,0,3,3,0,0,0,0,0,3,3,0],
            [0,3,3,3,3,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,3,0,3,3,3,3,3,0,0,0,0,0,3,3,0],
            [0,3,3,3,3,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,3,0,3,3,3,3,3,0,0,0,0,0,3,3,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,3,3,3,3,3,3,0,3,3,3,3,3,3,0,3,3,3,3,3,3,0,3,3,3,3,3,0,3,3,3,3,3,3,0],
            [0,3,3,3,3,3,3,0,3,3,3,3,3,3,0,3,3,3,3,3,3,0,3,3,3,3,3,0,3,3,3,3,3,3,0],
            [0,3,3,0,0,0,0,0,3,3,0,0,0,0,0,0,0,0,0,3,3,0,3,3,0,3,3,0,3,3,0,0,3,3,0],
            [0,3,3,0,0,0,0,0,3,3,0,0,0,0,0,0,0,0,0,3,3,0,3,3,0,3,3,0,3,3,0,0,3,3,0],
            [0,3,3,3,3,3,3,0,3,3,3,3,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,0,3,3,3,3,3,3,0],
            [0,3,3,3,3,3,3,0,3,3,3,3,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,0,3,3,3,3,3,3,0],
            [0,0,0,0,0,3,3,0,3,3,0,0,3,3,0,0,0,0,0,3,3,0,3,3,0,3,3,0,0,0,0,0,3,3,0],
            [0,3,3,3,3,3,3,0,3,3,3,3,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,0,3,3,3,3,3,3,0],
            [0,3,3,3,3,3,3,0,3,3,3,3,3,3,0,0,0,0,0,3,3,0,3,3,3,3,3,0,3,3,3,3,3,3,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        ];
        
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        currentMinutes = System.getClockTime().min;
        h = 1 + (dc.getHeight() / pixsample);
        w = 1 + (dc.getWidth() / pixsample);
        fifth = w / 5;
        vmiddle = h / 2;
        hmiddle = 2 + w / 2;
        redepthH = [hmiddle - digitWidth - 1, hmiddle - 1, vmiddle - digitHeight, vmiddle];
        redepthh = [hmiddle + 1, hmiddle + digitWidth + 1, vmiddle - digitHeight, vmiddle];
        redepthM = [hmiddle - digitWidth - 1, hmiddle - 1, vmiddle + 1, vmiddle + digitHeight + 1];
        redepthm = [hmiddle + 1, hmiddle + digitWidth + 1, vmiddle + 1, vmiddle + digitHeight + 1];
        
        for (var fci = 0; fci < 10; fci ++) {
            var fc = new[4];
            if (fci < 5) {
                fc[0] = 0;
                fc[1] = digitHeight;
                fc[2] = fci * digitWidth;
                fc[3] = (fci + 1) * digitWidth;
            } else {
                fc[0] = digitHeight;
                fc[1] = 2 * digitHeight;
                fc[2] = (fci - 5) * digitWidth;
                fc[3] = (fci + 1 - 5) * digitWidth;
            }
            fontChunks[fci] = fc;
        }

        depthmap = new[w * h];

        for (var c = 0; c < w; c++) {
            for (var r = 0; r < h; r++) {
                depthmap[r * w + c] = 0;
            }
        }

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function putDigitDM(digit, remap) as Void {
        var horizmin = remap[0];
        var horizmax = remap[1];
        var vertmin = remap[2];
        var vertmax = remap[3];
        var fc = fontChunks[digit];
        for (var y = 0; y < (vertmax - vertmin); y++) {
            var yy = w * (vertmin + y);
            for (var x = 0; x < (horizmax - horizmin); x++) {
                depthmap[horizmin + x + yy] =
                    font[fc[0] + y][fc[2] + x];
            }
        }
    }

    function recomputeDepth(hh, mm) as Void {
        var H = Math.floor(hh/10);
        var hr = hh % 10;
        var M = Math.floor(mm/10);
        var m = mm % 10;

        putDigitDM(hr, redepthh);
        putDigitDM(H, redepthH);

        putDigitDM(m, redepthm);
        putDigitDM(M, redepthM);

    }

    function mod(x as Lang.Number, o as Lang.Number) as Lang.Number {
        var res = x;
        while (res < 0) {
            res += o;
        }

        while (res >= o) {
            res -= o;
        }

        return res;
    }

    function drawGrid(dc as Dc) as Void {
        View.onUpdate(dc);
        for (var r = 0; r < h; r++) {
            var patternC = 0;
            var offsetAdj = 0;
            var rw = r * w;
            for (var cc = w >> 1; cc >= 0; cc -= fifth) {
                offsetAdj -= depthmap [cc + rw];
            }
            
            for (var c = 0; c < w; c++) {
                var offset = offsetAdj;
                if (patternC >= fifth) {
                    patternC = 0;
                }


                for (var cc = c; cc >= 0; cc -= fifth) {
                        offset += depthmap[cc + rw];
                }

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(patternC + 2);
                dc.drawPoint(c*pixsample - offset,
                             r*pixsample);

                patternC += 1;
            }
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;

        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }

        minutes = clockTime.min;

        if (minutes != currentMinutes) {
            recomputeDepth(hours, minutes);
            drawGrid(dc);
            minutes = currentMinutes;
        }
        
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
