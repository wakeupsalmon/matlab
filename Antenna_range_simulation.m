clear all; close all;
f = 125e3

% let's calculate the received power as a function of distance r
dist = 0.1:0.05:0.6; % this is a vector with log spaced points
mu0 = 4e-7*pi;              % permeability
Rtx = 10;                   % transmitter resistance (ohms)
Rrx = 1000;                 % receiver input resistance (ohms)
Vcc = 12;                    % supply voltage (volts)
Itx = (Vcc-0.7)/Rtx/sqrt(2);   % approximate RMS current (Amps)

wire_length = 4;            % provided wire length in meters
wire_diameter = 0.4e-3;     % diameter of the AWG #26
Nturns_tx = 30;             


% evaluation of the magnetic field as a function of (Ntx, range)
for i = 1:size(Nturns_tx, 2)        % for each number of turns
    
    % evaluate the maximum coil radius that can be built
    max_radius_tx(i) = wire_length/(2*pi*Nturns_tx(i)); 
    
    % evaluate the received magnetic field as a function of distance
    Brx(i, :) = mu0*Itx*Nturns_tx(i)*(max_radius_tx(i)).^2./(2.*(dist.^2+max_radius_tx(i).^2).^1.5);
end


Nturns_rx = 5:40;           % vector of turns, starts at 5, increments by one up to 40

% evaluate the maximum radius that I can build with the wire provided
max_radius_rx = wire_length./(2*pi*Nturns_rx);

% calculate the received inductance 
Lrx = Nturns_rx.^2*mu0.*max_radius_rx.*(log(8*max_radius_rx./(wire_diameter/2))-2);
Crx = 1./((2*pi*f).^2.*Lrx); % capacitor to tune the receiver

Q = Rrx./(2*pi*f.*Lrx);  % parallel equivalent quality factor

% graphically represent the inductance and geometry of the receiver coil
% as a function of number of turns.
figure
[ax, h1, h2] = plotyy(Nturns_rx, Lrx, Nturns_rx, max_radius_rx);
set(get(ax(1), 'XLabel') ,'String', 'Number turns') 
set(get(ax(1), 'YLabel') ,'String', 'Inductance (H)') 
set(get(ax(2), 'YLabel') ,'String', 'radius (meters)') 

% calculation of the output voltage for a tuned receiver. vs. (Nrx, range) 
for i = 1:size(Nturns_rx, 2) 
    
    % for each received coil geometry, we calculate the output voltage
    Vo(i, :) = 2*pi*f.*Nturns_rx(i).*pi.*max_radius_rx(i).^2.*Brx*Q(i);
end


% 3D plot of the output voltage as a function of range, and Nrx
figure
mesh(dist, Nturns_rx, Vo)
xlabel('distance (meters)')
ylabel('Number of turns')
zlabel('Vout (VRMS)')


figure
mesh(dist, Nturns_rx, 20*log10(Vo./50))
xlabel('distance (meters)')
ylabel('Number of turns')
zlabel('Vout (in dBm)')
