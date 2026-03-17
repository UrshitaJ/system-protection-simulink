clc;
clear;
close all;

%%MODE
current_mode = 'auto';
fault_log = [];

% --- Overcurrent thresholds ---
OC_TRIP  = 8;      % Amps (trip)
OC_RESET = 7.2;    % Amps (reset)

% --- Undervoltage thresholds ---
UV_TRIP  = 180;    % Volts (trip)
UV_RESET = 190;    % Volts (reset)


%% PARAMETERS
f = 50;                 % AC frequency (Hz)
fs = 5000;              % Sampling frequency (Hz)
t = 0:2/fs:2.0;         % Time vector

V_rated = 230;          % Rated voltage (RMS)
I_rated = 5;            % Rated current (RMS)

V_peak = V_rated*sqrt(2);
I_peak = I_rated*sqrt(2);

phi = pi/6;             % Phase angle (30 degrees lag)

%% GENERATE VOLTAGE & CURRENT
voltage = V_peak * sin(2*pi*f*t);
current = I_peak * sin(2*pi*f*t - phi);

%% INTRODUCE FAULT (Overcurrent at 0.15s)
cfault_index = (t >= 0.15) & (t<=0.40);
current(cfault_index) = 2.5 * current(cfault_index);  % Overcurrent fault

%% INTRODUCE FAULT (Undervoltage Fault at 0.80s)
vfault_index = (t>= 0.80) & (t<=1.20);
voltage(vfault_index) = 0.5 * voltage(vfault_index);  % Undervoltage fault


%% RMS CALCULATION (Sliding Window)
window_size = fs/f;     % One cycle window

Vrms = zeros(size(t));
Irms = zeros(size(t));

for k = window_size:length(t)
    Vrms(k) = sqrt(mean(voltage(k-window_size+1:k).^2));
    Irms(k) = sqrt(mean(current(k-window_size+1:k).^2));
end

%% POWER CALCULATION
instantaneous_power = voltage .* current;

P_real = movmean(instantaneous_power, window_size);
S_apparent = Vrms .* Irms;
power_factor = P_real ./ S_apparent;

%% PROTECTION LOGIC
OVERCURRENT_LIMIT = 8;     % Amps RMS
UNDERVOLT_LIMIT = 180;     % Volts RMS

fault_flag = zeros(size(t));
relay_state = ones(size(t));   % 1 = ON, 0 = OFF

% Automatic mode protection logic
auto_trip = 0;              %initially not tripped
reset_counter = 0;
RESET_DELAY = window_size;
fault_active = 0;   % 0 = no fault, 1 = fault ongoing

fault_type = strings(length(t),1);   % Store fault labels

for k = window_size:length(t)

    oc_fault = Irms(k) > OC_TRIP;   %condition for oc fault
    uv_fault = Vrms(k) < UV_TRIP;   %condition for uv fault

    % -------- Fault Detection (TRIP) --------
    if oc_fault || uv_fault

        auto_trip = 1;
        relay_state(k) = 0;
        fault_flag(k) = 1;
        reset_counter = 0;

        % Print ONLY when fault starts
        if fault_active == 0
            fault_active = 1;     %indicating fault started

            if oc_fault && uv_fault
                fault_type(k) = "OVERCURRENT + UNDERVOLTAGE";
            elseif oc_fault
                fault_type(k) = "OVERCURRENT";
            else
                fault_type(k) = "UNDERVOLTAGE";
            end

            fprintf('Fault (%s) STARTED at %.2f s\n', fault_type(k), t(k));
        end
    
            
            
    % -------- Reset Logic (HYSTERESIS) --------
    elseif auto_trip == 1       %lower than oc_trip and uv_trip now

        oc_clear = Irms(k) < OC_RESET;
        uv_clear = Vrms(k) > UV_RESET;

        if oc_clear && uv_clear     %lower than oc_clear and uv_clear now
            reset_counter = reset_counter + 1;

            if reset_counter >= RESET_DELAY
                auto_trip = 0;              % set parameters back to initial (no fault)
                relay_state(k) = 1;
                fault_active = 0;
                fault_type(k) = "RESET";

                fprintf('Fault CLEARED at %.2f s\n', t(k));
            else
                relay_state(k) = 0;
            end
        else                % case in which fault never gets cleared
            reset_counter = 0;
            relay_state(k) = 0;
        end
    else     % no fault detected throughout, relay remains on
            relay_state(k) = 1;
    end

end

%% PLOTS
figure;

subplot(4,1,1)
plot(t, voltage, 'b')
title('Voltage Waveform')
ylabel('Volts')
grid on

subplot(4,1,2)
plot(t, current, 'r')
title('Current Waveform')
ylabel('Amps')
grid on

subplot(4,1,3)
plot(t, Vrms, 'b', t, Irms, 'r')
title('RMS Values')
ylabel('RMS')
legend('V_{rms}', 'I_{rms}')
grid on

subplot(4,1,4)
plot(t, relay_state, 'b', 'LineWidth', 2)
title('Relay State (Protection Action)')
ylabel('ON / OFF')
xlabel('Time (s)')
grid on

%% DISPLAY RESULTS
fprintf('Final Vrms: %.2f V\n', Vrms(end));
fprintf('Final Irms: %.2f A\n', Irms(end));
fprintf('Final Real Power: %.2f W\n', mean(P_real(end-window_size:end)));
fprintf('Final Power Factor: %.2f\n', mean(power_factor(end-window_size:end)));
