// Clear already defined variables
clear;

// funcprot(0) prevents from getting a warning message about already defined/loaded functions
funcprot(0);

function new_graphic_window()
    AllCurrentFiguresId = get('figures_id');

    if isempty(AllCurrentFiguresId) then
      NewFigureId = 0;
    else
      CurrentFigure = get('current_figure');
      CurrentFigureId = CurrentFigure.figure_id;
      NewFigureId = CurrentFigureId + 1;
    end

    scf(NewFigureId);
    clf(NewFigureId);
endfunction

function I = MonteCarloMethod(fct, a, b, c, d, N)
    // Generate N x N random numbers
    X = a + (b - a) * rand(1, N);
    Y = c + (d - c) * rand(1, N);
    Z = [X; Y];

    SuccessPointCount = 0; FailPointCount = 0;
    for i = 1:N
        if Z(2, i) > 0 & Z(2, i) <= fct(Z(1, i)) then
            SuccessPointCount = SuccessPointCount + 1;
        elseif Z(2, i) < 0 & Z(2, i) >= fct(Z(1, i)) then
            FailPointCount = FailPointCount + 1;
        else
            SuccessPointCount = SuccessPointCount;
            FailPointCount = FailPointCount;
        end
    end

    I = (b - a) * (d - c) * ((SuccessPointCount - FailPointCount) / N);

    new_graphic_window();
    // Draw the curve
    v = linspace(a, b, 100); plot(v, fct);
    mod_axes = get('current_axes');
    // Determine the axes' size
    mod_axes.data_bounds = [a, c; b, d];
    // Force float writing
    mod_axes.ticks_format = ['%3.1f', '%3.1f'];
    // Force the axes' size to what was defined through data_bounds
    mod_axes.tight_limits = 'on';
    xgrid;

    // Compute the vector fct(Z(1,i)) for i = 1, ..., N
    FctX = feval(Z(1, :), fct);

    // Look for the "success" and "fail" points
    SuccessPointsLocations = find((Z(2, :) <= FctX & Z(2, :) >= 0) | (Z(2, :) >= FctX & Z(2, :) < 0));
    FailPointsLocations = find((Z(2, :) > FctX & Z(2, :) >= 0) | (Z(2, :) < FctX & Z(2, :) < 0));

    // Draw "success" and "fail" points
    plot(Z(1, SuccessPointsLocations), Z(2, SuccessPointsLocations), '+g');
    plot(Z(1, FailPointsLocations), Z(2, FailPointsLocations), '+r');

    // Display a figure's key (-1 is for +, 3 and 5 are for green and red in this order)
    legends(['Success points', 'Fail points'], [-1, -1; 3, 5], 1);

    // Display the approximate value of I
    disp(I);
endfunction

// Define function(s)
deff('[y]=f0(x)', 'y=sqrt(1-x^2e)');

// Call MonteCarloMethod()
I = MonteCarloMethod(f0, 0, 1, 0, 1, 100000);
