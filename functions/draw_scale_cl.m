function [lb, rb, start_center] = draw_scale_cl(scale)

global theWindow lb1 rb1 lb2 rb2 H W scale_W anchor_lms anchor_middle anchor_vas korean alpnum space special bgcolor white orange red

%% Basic setting
lb = lb1;
rb = rb1;
start_center = false;


%% Drawing scale
switch scale
    
    case 'overall_int_strong_binary'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('아프지\n      않았음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('아팠음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
    
    case 'overall_int_strong'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('상상할 수 있는\n   가장 강한'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
        
    case 'overall_int_weak_binary'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('아프지\n      않았음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('아팠음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
    
    case 'overall_int_weak'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('전혀 느껴지지\n      않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('상상할 수 있는\n   가장 강한'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
        
    case 'overall_alertness'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('매우 졸림'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 또렷'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
        
    case 'overall_relaxed'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*2];
        DrawFormattedText(theWindow, double('매우 불편함'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 편함'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
        
    case 'overall_attention'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        winRect_L = [lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, lb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        winRect_R = [rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y*0, rb1+korean.x*3+space.x/2, H/2+scale_W+korean.y*4.4];
        DrawFormattedText(theWindow, double('전혀 집중되지\n않음'), 'center', 'center', white, [], [], [], 1.2, [], winRect_L);
        DrawFormattedText(theWindow, double('매우 집중\n잘 됨'), 'center', 'center', white, [], [], [], 1.2, [], winRect_R);
        
end

end


