function [ lin_fit, afine_fit, pwl_fit ] = HeatrateFitCompare( power, heatrate, incr_hr )
%HEATRATEFITCOMPARE Plot various heatrate linear fit comparisons
%
%   Computes alternative fuel usage curve fits from a collection of heat
%   rate data & plots comparison to output assuming piecewise-linear
%   heatrates (this fit will be quadratic in power output so is not
%   suitable for linear models)
%
%   Usage:
%    [ lin_fit, afine_fit, pwl_fit ] = ...
%                   HeatrateFitCompare( power, heatrate, incr_hr )
%
%   computes fits (see below) from (output) power and (net) heatrate
%   (column vectors). The optional parameter incr_hr, containing
%   incremental heatrates, is used for the pwl_fit if available.
%   Alternatively, these 2 or 3 parameters can be passed as columns in a
%   single input array.
%
%   Returns fits for FuelUse = f(Power):
%     lin_fit:   best fit constant heatrate (slope)
%     afine_fit: [slope, intercept] for a line with non-zero y intercept
%     pwl_fit:   [slopevector, intercept_vector] a piecewise-linear fit in
%                 Fuel use space
%
% Note: For piecewise linear, if we don't have the incremental heatrates,
% we simply use the net_heatrate but for the preceding sections of the
% curve. This will be coincident with the fuel at defined verticies by
% construct, but will tend to diverge between resulting in a fit that is
% always below the "actual" (where actual assumes piecewise linear
% heatrates rather than fuel use).
%   When the incremental heatrate is also available, we use it for the
% slopes and assume the slope transition occur halfway between the defined
% verticies for an improved fit. This also provides an extra slope,
% intercept pair.

% HISTORY
% ver     date    time        who      changes made
% ---  ---------- -----  ------------- ---------------------------------------
%   1  2011-09-25 22:20  BryanP        Initial code

%Set flag for use of incremental heatrate (or not)
%
% Note: check this first so that we can override if the incr_hr data is
% included as a 3rd column in a single input parameter.
if nargin <3 || isempty(incr_hr)
    use_incr_hr = false;
else
    use_incr_hr = true;
end    

%If we only have one arguement, assume we have a 2 (or 3) column table of
%the corresponding input data
if nargin == 1
    heatrate = power(:,2);
    if size(power, 2) > 2
        incr_hr = power(:,3);
        use_incr_hr = true;
    end
    power = power(:,1);
end

%compute fuel use (Y) for our desired fits
fuel = power.*heatrate;

% linear fit through zero... yes the magic \ operator does a least squares
% fit assuming both power & fuel are column vectors
lin_fit = power\fuel;

% polyfit does just what we need when we also want a non-zero intercept
afine_fit = polyfit(power,fuel,1);

%Compute the piecewise linear equations
if not(use_incr_hr)
    % Without the incremental heatrates, we just estimate the heatrates
    % from the verticies provided resulting in an underestimate for fuel
    % use for power outputs between vertices
    
    pwl_slopes = [heatrate(1); diff(fuel)./diff(power)];
    pwl_x = [0; power(1:(end-1))];
else
    % With the incremental heatrates, we assume the incremental rates start
    % halfway between the vertices providing a hopefully better fit (and
    % providing an extra slope, intercept pair)
    pwl_slopes = [heatrate(1); incr_hr];
    pwl_x = [0; power(1); ( power(1:(end-1))+power(2:end) )/2];
end

pwl_fit = pwl_slopes;
pwl_fit = [pwl_fit, EqFromSlope(pwl_x',pwl_slopes')'];
%Remove first segment which will be too high since it largely captures the
%intercept offset
pwl_fit(1,:)=[];

%-- Now create our plot
figure
hold on
p = linspace(power(1), power(end), 100)';

% Uncomment to use piecewise linear heatrate (& change the legend)
f = p.*interp1q(power,heatrate,p);

% OR Uncomment to use quadratic heatrate fit (& change the legend)
% quad_hr_fit = polyfit(power,heatrate,2);
% f = p.* polyval(quad_hr_fit,p);


%Plot result assuming piecewise linear heat rate
plot(p, f,'b');

%Plot constant heatrate fit
plot([0,power(end)], [0, power(end) * lin_fit], 'g')

%Plot afine fit
plot([0, power(end)], afine_fit(2)+[0, power(end) * afine_fit(1)], 'r')

%Plot piece-wise linear fit
% first plot just the segments when they are in use (needed for legend)
[y, x] = FunFromSlope(pwl_x',pwl_slopes', power(end));
plot(x(2:end),y(2:end)','m')

% and now plot the full lines
for idx = 1: size(pwl_fit, 1)
    plot([0,power(end)], pwl_fit(idx, 2)+[0, pwl_fit(idx, 1)*power(end)], 'y--')
end

% and finally replot the segments so they are more clearly visable
plot(x(2:end),y(2:end)','m')

legend('pwl-heatrate','const-heatrate', 'afine-fit', 'pwl-fueluse', ...
    'Location', 'NorthWest')

%Also add on the known data points
plot(power,fuel,'bo')

%Add labels
xlabel('Power Output (MW)')
ylabel('Fuel Use kBTU/hr')

grid on

end

