function [out,TS] = HexModel(fluid_h, P_h_su, in_h_su, m_dot_h, fluid_c, P_c_su, in_c_su, m_dot_c, param)

%% CODE DESCRIPTION
% ORCmKit - an open-source modelling library for ORC systems
% Remi Dickes - 27/04/2016 (University of Liege, Thermodynamics Laboratory)
% rdickes @ulg.ac.be
%
% HexModel is a single matlab code implementing six different modelling
% approaches to simulate counter-flow heat exchangers (see the Documentation/HexModel_MatlabDoc)
%
% The model inputs are:
%       - fluid_h: nature of the hot fluid                        	[-]
%       - P_h_su: inlet pressure of the hot fluid                   [Pa]
%       - in_h_su: inlet temperature or enthalpy of the hot fluid   [K or J/kg]
%       - m_dot_h: mass flow rate of the hot fluid                  [kg/s]
%       - fluid_c: nature of the cold fluid                        	[-]
%       - P_c_su: inlet pressure of the cold fluid                  [Pa]
%       - in_c_su: inlet temperature or enthalpy of the cold fluid  [K or J/kg]
%       - m_dot_c: mass flow rate of the cold fluid                 [kg/s]
%       - param: structure variable containing the model parameters
%
% The model paramters provided in 'param' depends of the type of model selected:
%
%       - if param.modelType = 'CstPinch':
%           param.pinch = pinch point value in the temperature profile [K]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'CstEff':
%           param.epsilon_th = effective thermal efficiency of the heat exchanger [-]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'PolEff':
%           param.CoeffPolEff = polynomial coefficients for calculating the effective thermal efficiency of the heat exchanger
%           param.m_dot_h_n = nominal hot fluid mass flow rate [kg/sec]
%           param.m_dot_c_n = nominal cold fluid mass flow rate [kg/sec]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'hConvCst':
%           param.hConv_h_liq = HF convective heat transfer coeff for liquid phase [W/m^2.K]
%           param.hConv_h_tp = HF convective heat transfer coeff for two-phase [W/m^2.K]
%           param.hConv_h_vap = HF convective heat transfer coeff for vapour phase [W/m^2.K]
%           param.hConv_c_liq = CF convective heat transfer coeff for liquid phase [W/m^2.K]
%           param.hConv_c_tp = CF convective heat transfer coeff for two-phase [W/m^2.K]
%           param.hConv_c_vap = CF convective heat transfer coeff for vapour phase [W/m^2.K]
%           param.A_tot (or param.A_h_tot && param.A_c_tot) = total surfac area of HEX [m^2]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'hConvVar':
%           param.m_dot_h_n = HF nominal mass flow rate [kg/s]
%           param.hConv_h_liq_n = HF nominal convective heat transfer coeff for liquid phase [W/m^2.K]
%           param.hConv_h_tp_n = HF nominal convective heat transfer coeff for two-phase [W/m^2.K]
%           param.hConv_h_vap_n = HF nominal convective heat transfer coeff for vapour phase [W/m^2.K]
%           param.m_dot_c_n = CF nominal mass flow rate [kg/s]
%           param.hConv_c_liq_n = CF nominal convective heat transfer coeff for liquid phase [W/m^2.K]
%           param.hConv_c_tp_n = CF nominal convective heat transfer coeff for two-phase [W/m^2.K]
%           param.hConv_c_vap_n = CF nominal convective heat transfer coeff for vapour phase [W/m^2.K]
%           param.A_tot (or param.A_h_tot && param.A_c_tot) = total surfac area of HEX [m^2]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'hConvCor':
%           param.correlation_h.type_1phase = type of correlation for the hot side (single phase)
%           param.correlation_h.type_2phase = type of correlation for the hot side (two phase)
%           param.correlation_c.type_1phase = type of correlation for the cold side (single phase)
%           param.correlation_c.type_1phase = type of correlation for the cold side (two phase)
%           param.CS_h / param.Dh_h = cross-section and hydraulic diameter of the hot fluid
%           param.CS_c / param.Dh_c = cross-section and hydraulic diameter of the cold fluid
%           param.A_tot (or param.A_h_tot && param.A_c_tot) = total surfac area of HEX [m^2]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
% The model outputs are:
%       - out: a structure variable which includes at miniumum the following information:
%               - x_vec =  vector of power fraction in each zone
%               - Qdot_vec =  vector of heat power in each zone [W]
%               - H_h_vec = HF enthalpy vector                  [J/kg]
%               - H_c_vec = CF enthalpy vector                  [J/kg]
%               - T_h_vec = HF temperature vector               [K]
%               - T_c_vec = CF temperature vector               [K]
%               - s_h_vec = HF entropy vector                   [J/kg.K]
%               - s_c_vec = HF entropy vector                   [J/kg.K]
%               - DT_vec = Temperature difference vector        [K]
%               - pinch =  pinch point value                  	[K]
%               - h_h_ex =  HF exhaust enthalpy                 [J/kg]
%               - T_h_ex =  HF exhaust temperature              [K]
%               - h_c_ex =  CF exhaust enthalpy                 [J/kg]
%               - T_c_ex =  CF exhaust temperature              [K]
%               - V_h_vec = HF volume vector                    [m^3]
%               - V_c_vec = CF volume vector                    [m^3]
%               - M_h_vec = HF mass vector                      [kg]
%               - M_c_vec = CF mass vector                      [kg]
%               - M_h = Mass of hot fluid in the HEX            [kg]
%               - M_c = Mass of hot fluid in the HEX            [kg]
%               - time = the code computational time          	[sec]
%               - flag = simulation flag                      	
%
%       - TS : a stucture variable which contains the vectors of temperature
%              and entropy of the fluid (useful to generate a Ts diagram
%              when modelling the entire ORC system
%
% Further details, contact rdickes@ulg.ac.be
% NOTE: the comments might not be up to date


%% DEMONSTRATION CASE
if nargin == 0    
    % Define a demonstration case if HexModel.mat is not executed externally  
    
    fluid_h = 'PiroblocBasic';                                               % Nature of the hot fluid           [-]
    m_dot_h = 0.09;                                                          % Mass flow rat of the hot fluid    [kg/s]
    P_h_su =  2e+05;                                                          % Supply pressure of the hot fluid  [Pa]
    in_h_su = 90+273.15;      % Supply h or T of the hot fluid  	[J/kg pr K]
    fluid_c = 'R245fa';                                                     % Nature of the cold fluid        	[-]
    m_dot_c = 0.0252;                                                      % Mass flow rat of the cold fluid  	[kg/s]
    P_c_su = 4.188e5;                                                           % Supply pressure of the cold fluid	[Pa]
    in_c_su = CoolProp.PropsSI('H','P',P_c_su,'T',20+273.15, fluid_c);      % Supply h or T of the cold fluid  	[J/kg pr K]
    
    % Example of impletenation in the case of a correlation-based model for a plate heat exchanger
    
     
    
    L_phex_ev = 0.519-0.06;
    W_phex_ev = 0.191;
    pitch_p_ev = 0.0022;
    th_p_ev = 0.0004;
    b_p_ev = pitch_p_ev-th_p_ev;
    Np_phex_ev = 100;
    Nc_wf_ev = ceil((Np_phex_ev-1)/2);
    Nc_sf_ev = floor((Np_phex_ev-1)/2);
    CS_ev = W_phex_ev*b_p_ev;
    A_eff_ev = 9.8;
    Np_eff_ev = Np_phex_ev-2;
    phi_ev = (A_eff_ev/Np_eff_ev)/(W_phex_ev*L_phex_ev);    
    pitch_co_ev = 0.007213; %computed based on phi_ev and b_phex_ev
    Dh_ev = 2*b_p_ev/phi_ev;
    param.theta = 30*pi/180;
    param.type_h = 'T';
    param.type_c = 'H';
    param.A_h_tot = A_eff_ev;
    param.A_c_tot = A_eff_ev;
    param.V_h_tot = 0.009;
    param.V_c_tot = 0.009;
    param.L_hex = L_phex_ev;
    param.pitch_co = pitch_co_ev;
    param.phi =  phi_ev;
    param.Dh_c = Dh_ev;
    param.Dh_h = Dh_ev;
    param.CS_c = CS_ev;
    param.CS_h = CS_ev;
    param.n_canals_c = Nc_wf_ev;
    param.n_canals_h = Nc_sf_ev;
    param.n_tp_disc = 2;
    param.modelType = 'hConvCor';
    param.correlation_h.type_1phase = 'Martin';
    param.correlation_h.type_2phase = 'Longo_condensation';
    param.correlation_c.type_1phase = 'Martin';
    param.correlation_c.type_2phase = 'Almalfi_boiling';
    param.correlation_h.void_fraction = 'Hughmark';
    param.correlation_c.void_fraction = 'Hughmark';
    
    param.fact_corr_sp_h = 0.268088007690337;
    param.fact_corr_2p_h = 1;
    param.fact_corr_sp_c = 0.268088007690337;
    param.fact_corr_2p_c = 1;  
    param.fact2_corr_sp_h = 1;
    param.fact2_corr_2p_h = 1;
    param.fact2_corr_sp_c = 1;
    param.fact2_corr_2p_c = 1;  
    param.displayResults = 0;
    param.displayTS = 0;
    param.generateTS = 1;

    % For another example of implementation, please load the .mat file
    % "HEX_param_examples" and select the desired modelling approach

end

tstart_hex = tic;

%% HEAT EXCHANGER MODELLING
% Modelling section of the code

if not(isfield(param,'displayResults'))
    param.displayResults = 0;
    param.displayTS = 0;
    %if nothing specified by the user, the results are not displayed by
    %default.
end


% Evaluation of the hot fluid (HF) supply temperature
if strcmp(param.type_h,'H')
    T_h_su = CoolProp.PropsSI('T','P',P_h_su,'H',in_h_su, fluid_h);
    h_h_l = CoolProp.PropsSI('H','P',P_h_su,'Q',0,fluid_h);
    h_h_v = CoolProp.PropsSI('H','P',P_h_su,'Q',1,fluid_h);
elseif strcmp(param.type_h,'T')
    T_h_su = in_h_su;
    h_h_l = NaN;
    h_h_v = NaN;
end

% Evaluation of the cold fluid (CF) supply temperature
if strcmp(param.type_c,'H')
    T_c_su = CoolProp.PropsSI('T','P',P_c_su,'H',in_c_su, fluid_c);
    h_c_l = CoolProp.PropsSI('H','P',P_c_su,'Q',0,fluid_c);
    h_c_v = CoolProp.PropsSI('H','P',P_c_su,'Q',1,fluid_c);
elseif strcmp(param.type_c,'T')
    T_c_su = in_c_su;
    h_c_l = NaN;
    h_c_v = NaN;
end
%T_h_su
%T_c_su  
flag_reverse = 0;
if T_h_su<T_c_su  
    if strcmp(param.modelType, 'CstEff')
        [fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, type_h_int,  V_h_int_tot ] = deal(fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.type_h, param.V_h_tot);
        [fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.type_h,  param.V_h_tot] = deal(fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.type_c, param.V_c_tot);
        [fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.type_c,  param.V_c_tot] = deal(fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, type_h_int,V_h_int_tot);
        flag_reverse = 1;
        
    elseif strcmp(param.modelType, 'PolEff')
        [fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, type_h_int,  V_h_int_tot] = deal(fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.type_h, param.V_h_tot);
        [fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.type_h, param.V_h_tot] = deal(fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.type_c,  param.V_c_tot);
        [fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.type_c, param.V_c_tot] = deal(fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, type_h_int, V_h_int_tot);
        param.CoeffPolEff = param.CoeffPolEff([1 3 2 6 5 4]);
        flag_reverse = 1;
        
    elseif strcmp(param.modelType, 'hConvVar')
        %[fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, hConv_h_int_liq_n, hConv_h_int_tp_n, hConv_h_int_vap_n, type_h_int, A_h_int_tot, V_h_int_tot, alpha_mass_h_int] = deal(fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.hConv_h_liq_n, param.hConv_h_tp_n, param.hConv_h_vap_n, param.type_h, param.A_h_tot, param.V_h_tot, param.alpha_mass_h);
        %[fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.hConv_h_liq_n, param.hConv_h_tp_n, param.hConv_h_vap_n, param.type_h, param.A_h_tot, param.V_h_tot, param.alpha_mass_h] = deal(fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.hConv_c_liq_n, param.hConv_c_tp_n, param.hConv_c_vap_n, param.type_c, param.A_c_tot, param.V_c_tot, param.alpha_mass_c);
        %[fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.hConv_c_liq_n, param.hConv_c_tp_n, param.hConv_c_vap_n, param.type_c, param.A_c_tot, param.V_c_tot, param.alpha_mass_c] = deal(fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, hConv_h_int_liq_n, hConv_h_int_tp_n, hConv_h_int_vap_n, type_h_int, A_h_int_tot, V_h_int_tot, alpha_mass_h_int);
         [fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, hConv_h_int_liq_n, hConv_h_int_tp_n, hConv_h_int_vap_n, type_h_int, A_h_int_tot, V_h_int_tot, h_h_l_int, h_h_v_int] = deal(fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.hConv_h_liq_n, param.hConv_h_tp_n, param.hConv_h_vap_n, param.type_h, param.A_h_tot, param.V_h_tot, h_h_l, h_h_v);
         [fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.hConv_h_liq_n, param.hConv_h_tp_n, param.hConv_h_vap_n, param.type_h, param.A_h_tot, param.V_h_tot, h_h_l, h_h_v] = deal(fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.hConv_c_liq_n, param.hConv_c_tp_n, param.hConv_c_vap_n, param.type_c, param.A_c_tot, param.V_c_tot, h_c_l, h_c_v);
        [fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.hConv_c_liq_n, param.hConv_c_tp_n, param.hConv_c_vap_n, param.type_c, param.A_c_tot, param.V_c_tot, h_c_l, h_c_v] = deal(fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, hConv_h_int_liq_n, hConv_h_int_tp_n, hConv_h_int_vap_n, type_h_int, A_h_int_tot, V_h_int_tot, h_h_l_int, h_h_v_int);
        flag_reverse = 1;
    end
end

if (T_h_su-T_c_su)>1e-2  && m_dot_h  > 0 && m_dot_c > 0;
    % Check if the operating conditions permit a viable heat transfer
    
    switch param.modelType
        %If yes, select the proper model paradigm chosen by the user
        
        case 'CstPinch' % Model which imposes a constant pinch
            if T_h_su-T_c_su > param.pinch
                
                % Power and enthalpy vectors calculation
                lb = 0; % Minimum heat power that can be transferred between the two media
                ub = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute maximum heat power that can be transferred between the two media
                f = @(Q_dot) HEX_CstPinch_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param.pinch, Q_dot, param); % function to solve in order to find Q_dot_eff in the heat exchanger
                Q_dot_eff = zeroBrent ( lb, ub, 1e-6, 1e-6, f ); % Solver driving residuals of HEX_CstPinch_res to zero
                out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
                out.Q_dot_tot = Q_dot_eff;
                out.h_h_ex = out.H_h_vec(1);
                out.h_c_ex = out.H_c_vec(end);
                out.T_h_ex = out.T_h_vec(1);
                out.T_c_ex = out.T_c_vec(end);
                out.resPinch = abs(1-out.pinch/param.pinch);
                
                % Entropy vector calculation
                [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
                if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_h_vec)
                        out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                    end
                end
                if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_c_vec)
                        out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                    end
                end
                
                % Mass calculation
                out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
                out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
                for i = 1: length(out.V_h_vec)
                    if strcmp(param.type_h,'H')
                        out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                    else
                        out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                    end
                    if strcmp(param.type_c,'H')
                        out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                    else
                        out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                    end
                end
                out.M_h = sum(out.M_h_vec);
                out.M_c = sum(out.M_c_vec);
                
                % Flag evaluation
                if out.resPinch <1e-4
                    out.flag = 1;
                else
                    out.flag = -1;
                end
                
            else
                
                % Power and enthalpy vectors calculation
                Q_dot_eff = 0;
                out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
                out.h_h_ex = out.H_h_vec(1);
                out.h_c_ex = out.H_c_vec(end);
                out.T_h_ex = out.T_h_vec(1);
                out.T_c_ex = out.T_c_vec(end);
                out.Q_dot_tot = Q_dot_eff;
                
                % Entropy vector calculation
                [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
                if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_h_vec)
                        out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                    end
                end
                if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_c_vec)
                        out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                    end
                end
                
                % Mass calculation
                out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
                out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
                for i = 1: length(out.V_h_vec)
                    if strcmp(param.type_h,'H')
                        out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                    else
                        out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                    end
                    if strcmp(param.type_c,'H')
                        out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                    else
                        out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                    end
                end
                out.M_h = sum(out.M_h_vec);
                out.M_c = sum(out.M_c_vec);
                
                % Flag evaluation                
                out.flag = 2;
            end
            
        case 'CstEff'   % Model which imposes a constant thermal efficiency
                        
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max
            Q_dot_eff = param.epsilon_th*Q_dot_max; %Effective heat transfer
            out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = Q_dot_eff;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);

            % Entropy vector calculation            
            [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
            if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_h_vec)
                    out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                end
            end
            if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_c_vec)
                    out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
            out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
            for i = 1: length(out.V_h_vec)
                if strcmp(param.type_h,'H')
                    out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                else
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end
                if strcmp(param.type_c,'H')
                    out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                else
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
            
            % Flag evaluation             
            if abs(out_max.pinch) < 1e-2 % Check that Q_dot_max correspond to the situation where the pinch is equal to zero
                out.flag = 1;
            else
                out.flag = -2;
            end        
            
        case 'PolEff'   % Model which computes the thermal efficiency  with a polynomial regressions
            
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max
            Q_dot_eff = Q_dot_max*max(1e-5,min(1, param.CoeffPolEff(1) + param.CoeffPolEff(2)*(m_dot_h/param.m_dot_h_n) + param.CoeffPolEff(3)*(m_dot_c/param.m_dot_c_n) + param.CoeffPolEff(4)*(m_dot_h/param.m_dot_h_n)^2 + param.CoeffPolEff(5)*(m_dot_h/param.m_dot_h_n)*(m_dot_c/param.m_dot_c_n) + param.CoeffPolEff(6)*(m_dot_c/param.m_dot_c_n)^2));
            out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = Q_dot_eff;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);
            
            % Entropy vector calculation            
            [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
            if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_h_vec)
                    out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                end
            end
            if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_c_vec)
                    out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
            out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
            for i = 1: length(out.V_h_vec)
                if strcmp(param.type_h,'H')
                    out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                else
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end
                if strcmp(param.type_c,'H')
                    out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                else
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
            
            % Flag evaluation 
            if abs(out_max.pinch) < 1e-2 % Check that Q_dot_max correspond to the situation where the pinch is equal to zero
                out.flag = 1;
            else
                out.flag = -2;
            end
            
        case 'hConvCst' % 3-zone moving-boundary model with constant convective heat transfer coefficients
            if isfield(param, 'A_tot')
                % if only one surface area is specified, then it is the
                % same for the hot and the cold fluid (ex: CPHEX)
                param.A_h_tot = param.A_tot;
                param.A_c_tot = param.A_tot;
            end
            
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max
            lb = 0; % Minimum heat power that can be transferred between the two media
            ub = Q_dot_max;
            f = @(Q_dot) HEX_hConvCst_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su,  Q_dot, param); % function to solve in order to find Q_dot_eff in the heat exchanger
            if f(ub) > 0
                Q_dot_eff = ub; % HEX so oversized that the effective heat power is equal to Q_dot_max
            else
                Q_dot_eff = zeroBrent ( lb, ub, 1e-6, 1e-6, f); % Solver driving residuals of HEX_hConvCst_res to zero
            end
            out = HEX_hConvCst(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = Q_dot_eff;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);
            
            % Entropy vector calculation
            [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
            if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_h_vec)
                    out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                end
            end
            if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_c_vec)
                    out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.A_h./param.A_h_tot);
            out.V_c_vec = param.V_c_tot*(out.A_h./param.A_h_tot);
            for i = 1: length(out.V_h_vec)
                if strcmp(param.type_h,'H')
                    out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                else
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end
                if strcmp(param.type_c,'H')
                    out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                else
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D',out. T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
            
            % Flag evaluation              
            if out.resA <1e-4
                out.flag = 1;
            else
                if abs(out_max.pinch) < 1e-2
                    if Q_dot_eff == Q_dot_max
                        out.flag = 2;
                    else
                        out.flag = -1;
                    end
                else
                    out.flag = -2;
                end
            end
            
        case 'hConvVar' % 3-zone moving-boundary model with mass-flow dependent convective heat transfer coefficients
            if isfield(param, 'A_tot')
               % if only one surface area is specified, then it is the
               % same for the hot and the cold fluid (ex: CPHEX)
               param.A_h_tot = param.A_tot;
               param.A_c_tot = param.A_tot;
            end
            if not(isfield(param, 'hugmark_simplified'))
                param.hugmark_simplified = 0;
            end
            if not(isfield(param, 'n_tp_disc'))
                param.n_tp_disc = 2;
            end
            
            
            if isfield(param,'n')
                param.n_h_liq = param.n;
                param.n_c_liq = param.n;
                param.n_h_tp = param.n;
                param.n_c_tp = param.n;
                param.n_h_vap = param.n;
                param.n_c_vap = param.n;
            end
            
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max
            lb = 0; % Minimum heat power that can be transferred between the two media
            ub = Q_dot_max; % Maximum heat power that can be transferred between the two media
            f = @(Q_dot) HEX_hConvVar_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su,  Q_dot, param, h_h_l, h_h_v, h_c_l, h_c_v); % function to solve in order to find Q_dot_eff in the heat exchanger
            f(ub)
            if f(ub) > 0
                Q_dot_eff = ub; % HEX so oversized that the effective heat power is equal to Q_dot_max
            else
                Q_dot_eff = zeroBrent ( lb, ub, 1e-8, 1e-8, f ); % Solver driving residuals of HEX_hConvVar_res to zero
            end
            out = HEX_hConvVar(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param, h_h_l, h_h_v, h_c_l, h_c_v); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = Q_dot_eff;
            out.epsilon_th = Q_dot_eff/Q_dot_max;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);           
            out.hConv_h_liq_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'liq')));
            out.hConv_h_tp_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'tp')));
            out.hConv_h_vap_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'vap')));
            out.hConv_c_liq_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'liq')));
            out.hConv_c_tp_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'tp')));
            out.hConv_c_vap_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'vap')));
            
            % Entropy vector calculation
            [out.s_h_vec, out.s_c_vec, out.q_h_vec, out.q_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
            if param.generateTS
                if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_h_vec)
                        out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                        out.q_h_vec(i) = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                    end
                end
                if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_c_vec)
                        out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                        out.q_c_vec(i) = CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                    end
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.A_h./sum(out.A_h));
            out.V_c_vec = param.V_c_tot*(out.A_h./sum(out.A_h));
            [out.M_h_vec, out.M_c_vec, out.Weight_c_vec, out.Weight_h_vec] = deal(NaN*ones(1, length(out.T_h_vec)-1));
                
            if strcmp(param.type_h,'H')
                rho_h_liq = CoolProp.PropsSI('D','P',P_h_su,'Q',0,fluid_h);
                rho_h_vap = CoolProp.PropsSI('D','P',P_h_su,'Q',1,fluid_h);
                
                for i = 1: length(out.V_h_vec)
                    
                    if strcmp(out.type_zone_h{i},  'tp')
                        
                        q_h_1iq = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                        q_h_vap = min(0.9999,CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h));
                        
                        switch param.correlation_h.void_fraction
                            case 'Homogenous'
                                f_void = @(q) VoidFraction_homogenous(q, rho_h_vap,  rho_h_liq);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                out.Weight_h_vec(i) = Weight_h;
                                out.M_h_vec(i) = out.V_h_vec(i)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                                
                            case 'Zivi'
                                f_void = @(q) VoidFraction_Zivi(q, rho_h_vap,  rho_h_liq);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                out.Weight_h_vec(i) = Weight_h;
                                out.M_h_vec(i) = out.V_h_vec(i)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                                
                            case 'Hughmark'
                                mu_h_liq = CoolProp.PropsSI('V','P',P_h_su,'Q',0,fluid_h);
                                mu_h_vap = CoolProp.PropsSI('V','P',P_h_su,'Q',1,fluid_h);
                                f_void = @(q) VoidFraction_Hughmark(q, rho_h_vap,  rho_h_liq, mu_h_vap, mu_h_liq, param.Dh_h,  m_dot_h/param.n_canals_h/param.CS_h);

                                if param.hugmark_simplified %== 1
                                    %nbr_step = param.nbr_divistion_voidFraction;
                                    %q_vec = linspace(q_h_1iq, q_h_vap, nbr_step);
                                    %Weight_h = 1/(q_h_vap-q_h_1iq)*trapz(q_vec, f_void(q_vec));
                                %elseif param.hugmark_simplified == 2
                                    x_int1 = 0.1;    
                                    x_int2 = 0.9;
                                    q_vec = [linspace(q_h_1iq, (1-x_int1)*q_h_1iq+x_int1*q_h_vap, 4) linspace((1-x_int1)*q_h_1iq+x_int1*q_h_vap, (1-x_int2)*q_h_1iq+x_int2*q_h_vap, 10) linspace((1-x_int2)*q_h_1iq+x_int2*q_h_vap, q_h_vap, 4)] ;
                                    Weight_h = 1/(q_h_vap-q_h_1iq)*trapz(q_vec, f_void(q_vec));
                                else
                                    Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                end
                                out.Weight_h_vec(i) = Weight_h;
                                out.M_h_vec(i) = out.V_h_vec(i)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                                
                            case 'LockMart'
                                mu_h_liq = CoolProp.PropsSI('V','P',P_h_su,'Q',0,fluid_h);
                                mu_h_vap = CoolProp.PropsSI('V','P',P_h_su,'Q',1,fluid_h);
                                f_void = @(q) VoidFraction_Lockhart_Martinelli(q, rho_h_vap,  rho_h_liq, mu_h_vap, mu_h_liq);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                out.Weight_h_vec(i) = Weight_h;
                                out.M_h_vec(i) = out.V_h_vec(i)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                                
                            case 'Premoli'
                                mu_h_liq = CoolProp.PropsSI('V','P',P_h_su,'Q',0,fluid_h);
                                sig_h = CoolProp.PropsSI('I','P',P_h_su,'H', 0.5*out.H_h_vec(i)+0.5*out.H_h_vec(i+1),fluid_h);
                                f_void = @(q) VoidFraction_Premoli(q, rho_h_vap,  rho_h_liq, mu_h_liq, sig_h, param.Dh_h,  m_dot_h/param.n_canals_h/param.CS_h);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                out.Weight_h_vec(i) = Weight_h;
                                out.M_h_vec(i) = out.V_h_vec(i)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                                
                            case 'SlipRatio'
                                f_void = @(q) VoidFraction_SlipRatio(q, rho_h_vap,  rho_h_liq, param.SlipRatio_h);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                out.Weight_h_vec(i) = Weight_h;
                                out.M_h_vec(i) = out.V_h_vec(i)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                                
                            case 'Zivi_integrated'
                                x2 = q_h_vap;
                                x1 = q_h_1iq;
                                S =  (rho_h_vap/rho_h_liq)^(-1/3);
                                K = rho_h_vap/rho_h_liq*S;
                                alpha_mass_h = -1*((K*(log(((x2-1)*K-x2)/((x1-1)*K-x1))+x2-x1))+(x1-x2))/(((x2-x1)*K^2)+(2*K*(x1-x2))+(x2-x1));
                                Weight_h = 1-alpha_mass_h;
                                out.Weight_h_vec(i) = Weight_h;
                                out.M_h_vec(i) = out.V_h_vec(i)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                                
                            case 'Personnal'
                                Weight_h = 1- param.alpha_mass_h;
                                out.Weight_h_vec(i) = Weight_h;
                                out.M_h_vec(i) = out.V_h_vec(i)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                        end
                        
                    else
                        out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                    end
                end
            else
                for i = 1: length(out.V_h_vec)
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end
            end
                         
            if strcmp(param.type_c,'H')
                rho_c_liq = CoolProp.PropsSI('D','P',P_c_su,'Q',0,fluid_c);
                rho_c_vap = CoolProp.PropsSI('D','P',P_c_su,'Q',1,fluid_c);
                for i = 1: length(out.V_c_vec)

                    if strcmp(out.type_zone_c{i},  'tp')
                        q_c_1iq = CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                        q_c_vap = min(0.99999,CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c));

                        switch param.correlation_c.void_fraction
                            case 'Homogenous'
                                f_void = @(q) VoidFraction_homogenous(q, rho_c_vap,  rho_c_liq);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                                out.Weight_c_vec(i) = Weight_c;
                                out.M_c_vec(i) = out.V_c_vec(i)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));

                            case 'Zivi'
                                f_void = @(q) VoidFraction_Zivi(q, rho_c_vap,  rho_c_liq);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                                out.Weight_c_vec(i) = Weight_c;
                                out.M_c_vec(i) = out.V_c_vec(i)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));
                                
                            case 'Hughmark'
                                mu_c_liq = CoolProp.PropsSI('V','P',P_c_su,'Q',0,fluid_c);
                                mu_c_vap = CoolProp.PropsSI('V','P',P_c_su,'Q',1,fluid_c);
                                f_void = @(q) VoidFraction_Hughmark(q, rho_c_vap,  rho_c_liq, mu_c_vap, mu_c_liq, param.Dh_c,  m_dot_c/param.n_canals_c/param.CS_c);  
                                if param.hugmark_simplified %== 1
                                    %nbr_step = param.nbr_divistion_voidFraction;
                                    %q_vec = linspace(q_c_1iq, q_c_vap, nbr_step);
                                    %Weight_c = 1/(q_c_vap-q_c_1iq)*trapz(q_vec, f_void(q_vec));
                                %elseif param.hugmark_simplified == 2
                                    x_int1 = 0.1;    
                                    x_int2 = 0.9;
                                    q_vec = [linspace(q_c_1iq, (1-x_int1)*q_c_1iq+x_int1*q_c_vap, 4) linspace((1-x_int1)*q_c_1iq+x_int1*q_c_vap, (1-x_int2)*q_c_1iq+x_int2*q_c_vap, 10) linspace((1-x_int2)*q_c_1iq+x_int2*q_c_vap, q_c_vap, 4)] ;
                                    Weight_c = 1/(q_c_vap-q_c_1iq)*trapz(q_vec, f_void(q_vec));
                                else
                                    Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);%, 'AbsTol',1e-5,'RelTol',1e-3);
                                end
                                out.Weight_c_vec(i) = Weight_c;
                                out.M_c_vec(i) = out.V_c_vec(i)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));
                                
                            case 'LockMart'
                                mu_c_liq = CoolProp.PropsSI('V','P',P_c_su,'Q',0,fluid_c);
                                mu_c_vap = CoolProp.PropsSI('V','P',P_c_su,'Q',1,fluid_c);
                                f_void = @(q) VoidFraction_Lockhart_Martinelli(q, rho_c_vap,  rho_c_liq, mu_c_vap, mu_c_liq);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                                out.Weight_c_vec(i) = Weight_c;
                                out.M_c_vec(i) = out.V_c_vec(i)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));

                            case 'Premoli'
                                mu_c_liq = CoolProp.PropsSI('V','P',P_c_su,'Q',0,fluid_c);
                                sig_c = CoolProp.PropsSI('I','P',P_c_su,'H', 0.5*out.H_c_vec(i)+0.5*out.H_c_vec(i+1),fluid_c);
                                f_void = @(q) VoidFraction_Premoli(q, rho_c_vap,  rho_c_liq, mu_c_liq, sig_c, param.Dh_c,  m_dot_c/param.n_canals_c/param.CS_c);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                                out.Weight_c_vec(i) = Weight_c;
                                out.M_c_vec(i) = out.V_c_vec(i)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));
                                
                            case 'SlipRatio'
                                f_void = @(q) VoidFraction_SlipRatio(q, rho_c_vap,  rho_c_liq, param.SlipRatio_c);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                                out.Weight_c_vec(i) = Weight_c;
                                out.M_c_vec(i) = out.V_c_vec(i)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));
     
                            case 'Zivi_integrated'
                                x2 = q_c_vap;
                                x1 = q_c_1iq;
                                S =  (rho_c_vap/rho_c_liq)^(-1/3);
                                K = rho_c_vap/rho_c_liq*S;
                                alpha_mass_c = -1*((K*(log(((x2-1)*K-x2)/((x1-1)*K-x1))+x2-x1))+(x1-x2))/(((x2-x1)*K^2)+(2*K*(x1-x2))+(x2-x1));
                                Weight_c = 1-alpha_mass_c;
                                out.Weight_c_vec(i) = Weight_c;
                                out.M_c_vec(i) = out.V_c_vec(i)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));
                                
                            case 'Personnal'
                                Weight_c = 1- param.alpha_mass_c;
                                out.Weight_c_vec(i) = Weight_c;
                                out.M_c_vec(i) = out.V_c_vec(i)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));
                        end
                    else
                        out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                    end
                end
            else
                for i = 1: length(out.V_c_vec)                    
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
            
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
            
            % Flag evaluation 
            if out.resA <1e-4
                out.flag = 1;
            else
                if abs(out_max.pinch) < 1e-2
                    if Q_dot_eff == Q_dot_max
                        out.flag = 2;
                    else
                        out.flag = -1;
                    end
                    
                else
                    out.flag = -2;
                end
            end
            
        case 'hConvCor' % 3-zone moving-boundary model with empirical correlations from the litterature 
            %if isfield(param, 'A_tot')
            %    % if only one surface area is specified, then it is the
            %    % same for the hot and the cold fluid (ex: CPHEX)
            %    param.A_h_tot = param.A_tot;
            %    param.A_c_tot = param.A_tot;
            %end
            if not(isfield(param, 'fact_corr_sp_h'))                
                param.fact_corr_sp_h = 1;
            end
            if not(isfield(param, 'fact_corr_2p_h'))                
                param.fact_corr_2p_h = 1;
            end            
            if not(isfield(param, 'fact_corr_sp_c'))                
                param.fact_corr_sp_c = 1;
            end
            if not(isfield(param, 'fact_corr_2p_c'))                
                param.fact_corr_2p_c = 1;
            end      
            if not(isfield(param, 'fact2_corr_sp_h'))                
                param.fact2_corr_sp_h = 1;
            end            
            if not(isfield(param, 'fact2_corr_sp_c'))                
                param.fact2_corr_sp_c = 1;
            end
            if not(isfield(param, 'fact2_corr_2p_h'))                
                param.fact2_corr_2p_h = 1;
            end            
            if not(isfield(param, 'fact2_corr_2p_c'))                
                param.fact2_corr_2p_c = 1;
            end            
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max;
            lb = 1; % Minimum heat power that can be transferred between the two media
            ub = Q_dot_max; % Maximum heat power that can be transferred between the two media
            f = @(Q_dot) HEX_hConvCor_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su,  Q_dot, param, h_h_l, h_h_v, h_c_l, h_c_v); % function to solve in order to find Q_dot_eff in the heat exchanger
            if f(ub) > 0
                Q_dot_eff = ub; % HEX so oversized that the effective heat power is equal to Q_dot_max
            else
                Q_dot_eff = zeroBrent ( lb, ub, 1e-6, 1e-6, f ); % Solver driving residuals of HEX_hConvVar_res to zero
            end
            out = HEX_hConvCor(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, real(Q_dot_eff), param, h_h_l, h_h_v, h_c_l, h_c_v); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = real(Q_dot_eff);
            out.epsilon_th = real(Q_dot_eff)/Q_dot_max;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);
            
            out.hConv_h_liq_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'liq')));
            out.hConv_h_tp_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'tp')));
            out.hConv_h_vap_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'vap')));
            out.hConv_c_liq_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'liq')));
            out.hConv_c_tp_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'tp')));
            out.hConv_c_vap_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'vap'))); 

            
            % Entropy vector calculation
            [out.s_h_vec, out.s_c_vec, out.q_h_vec, out.q_c_vec] = deal(NaN*ones(1, length(out.T_h_vec)));
            if param.generateTS
                if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_h_vec)
                        out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                        out.q_h_vec(i) = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                    end
                end
                if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_c_vec)
                        out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                        out.q_c_vec(i) = CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                    end
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.A_h./sum(out.A_h));
            out.V_c_vec = param.V_c_tot*(out.A_h./sum(out.A_h));
            [out.M_h_vec, out.M_c_vec, out.Weight_c_vec, out.Weight_h_vec] = deal(NaN*ones(1, length(out.T_h_vec)-1));
            
            if strcmp(param.type_h,'H')
                rho_h_liq = CoolProp.PropsSI('D','P',P_h_su,'Q',0,fluid_h);
                rho_h_vap = CoolProp.PropsSI('D','P',P_h_su,'Q',1,fluid_h);                
                for i = 1: length(out.V_h_vec)
                    if strcmp(out.type_zone_h{i},  'tp')                       
                        q_h_1iq = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                        q_h_vap = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h);                       
                        
                        switch param.correlation_h.void_fraction
                            case 'Homogenous'
                                f_void = @(q) VoidFraction_homogenous(q, rho_h_vap,  rho_h_liq);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                
                            case 'Zivi'
                                f_void = @(q) VoidFraction_Zivi(q, rho_h_vap,  rho_h_liq);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                
                            case 'Hughmark'
                                mu_h_liq = CoolProp.PropsSI('V','P',P_h_su,'Q',0,fluid_h);
                                mu_h_vap = CoolProp.PropsSI('V','P',P_h_su,'Q',1,fluid_h);
                                f_void = @(q) VoidFraction_Hughmark(q, rho_h_vap,  rho_h_liq, mu_h_vap, mu_h_liq, param.Dh_h,  m_dot_h/param.n_canals_h/param.CS_h);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                
                            case 'LockMart'
                                mu_h_liq = CoolProp.PropsSI('V','P',P_h_su,'Q',0,fluid_h);
                                mu_h_vap = CoolProp.PropsSI('V','P',P_h_su,'Q',1,fluid_h);
                                f_void = @(q) VoidFraction_Lockhart_Martinelli(q, rho_h_vap,  rho_h_liq, mu_h_vap, mu_h_liq);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                
                            case 'Premoli'
                                mu_h_liq = CoolProp.PropsSI('V','P',P_h_su,'Q',0,fluid_h);
                                sig_h = CoolProp.PropsSI('I','P',P_h_su,'H', 0.5*out.H_h_vec(i)+0.5*out.H_h_vec(i+1),fluid_h);
                                f_void = @(q) VoidFraction_Premoli(q, rho_h_vap,  rho_h_liq, mu_h_liq, sig_h, param.Dh_h,  m_dot_h/param.n_canals_h/param.CS_h);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                                
                            case 'SlipRatio'
                                f_void = @(q) VoidFraction_SlipRatio(q, rho_h_vap,  rho_h_liq, param.SlipRatio_h);
                                Weight_h = 1/(q_h_vap-q_h_1iq)*integral(f_void, q_h_1iq, q_h_vap);
                        end
                        out.Weight_h_vec(i) = Weight_h;
                        out.M_h_vec(i) = out.V_h_vec(i)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                    else
                        out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                    end
                end
            else
                for i = 1: length(out.V_h_vec)                    
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end
            end

            if strcmp(param.type_c,'H')
                rho_c_liq = CoolProp.PropsSI('D','P',P_c_su,'Q',0,fluid_c);
                rho_c_vap = CoolProp.PropsSI('D','P',P_c_su,'Q',1,fluid_c);
                
                for i = 1: length(out.V_c_vec)

                    if strcmp(out.type_zone_c{i},  'tp')
                        
                        q_c_1iq = CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                        q_c_vap = min(0.9999,CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c));

                        switch param.correlation_c.void_fraction
                            case 'Homogenous'
                                f_void = @(q) VoidFraction_homogenous(q, rho_c_vap,  rho_c_liq);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                                
                            case 'Zivi'
                                f_void = @(q) VoidFraction_Zivi(q, rho_c_vap,  rho_c_liq);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                                
                            case 'Hughmark'
                                mu_c_liq = CoolProp.PropsSI('V','P',P_c_su,'Q',0,fluid_c);
                                mu_c_vap = CoolProp.PropsSI('V','P',P_c_su,'Q',1,fluid_c);
                                f_void = @(q) VoidFraction_Hughmark(q, rho_c_vap,  rho_c_liq, mu_c_vap, mu_c_liq, param.Dh_c,  m_dot_c/param.n_canals_c/param.CS_c);   
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                            case 'LockMart'
                                mu_c_liq = CoolProp.PropsSI('V','P',P_c_su,'Q',0,fluid_c);
                                mu_c_vap = CoolProp.PropsSI('V','P',P_c_su,'Q',1,fluid_c);
                                f_void = @(q) VoidFraction_Lockhart_Martinelli(q, rho_c_vap,  rho_c_liq, mu_c_vap, mu_c_liq);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);

                            case 'Premoli'
                                mu_c_liq = CoolProp.PropsSI('V','P',P_c_su,'Q',0,fluid_c);
                                sig_c = CoolProp.PropsSI('I','P',P_c_su,'H', 0.5*out.H_c_vec(i)+0.5*out.H_c_vec(i+1),fluid_c);
                                f_void = @(q) VoidFraction_Premoli(q, rho_c_vap,  rho_c_liq, mu_c_liq, sig_c, param.Dh_c,  m_dot_c/param.n_canals_c/param.CS_c);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                                                                                               
                            case 'SlipRatio'
                                f_void = @(q) VoidFraction_SlipRatio(q, rho_c_vap,  rho_c_liq, param.SlipRatio_c);
                                Weight_c = 1/(q_c_vap-q_c_1iq)*integral(f_void, q_c_1iq, q_c_vap);
                        end
                        out.Weight_c_vec(i) = Weight_c;
                        out.M_c_vec(i) = out.V_c_vec(i)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));    

                    else
                        out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                    end
                end
            else
                for i = 1: length(out.V_c_vec)
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
            
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
            %out.M_cbis = sum(out.M_cbis_vec);

            %out.A_c_2p = sum(out.A_c(strcmp(out.type_zone_c, 'tp')));
            %out.V_c_2p = sum(out.V_c_vec(strcmp(out.type_zone_c, 'tp')));
            %out.M_c_2p = sum(out.M_c_vec(strcmp(out.type_zone_c, 'tp')));
            %out.Weight_c_2p = sum(out.Weight_c(strcmp(out.type_zone_c, 'tp')));
 
            
            % Flag evaluation 
            if out.resA <1e-4
                out.flag = 1;
            else
                if abs(out_max.pinch) < 1e-2
                    if Q_dot_eff == Q_dot_max
                        out.flag = 2;
                    else
                        %fluid_h, P_h_su, in_h_su, m_dot_h, fluid_c, P_c_su, in_c_su, m_dot_c, param
                        out.flag = -1;
                    end
                    
                else
                    out.flag = -2;
                end
            end
            
        otherwise
            disp('Wrong type of model input')
    end
    
else
    %If no, there is not any heat power transfered
    Q_dot_eff = 0;
    out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param);
    out.h_h_ex = out.H_h_vec(1);
    out.h_c_ex = out.H_c_vec(end);
    out.T_h_ex = out.T_h_vec(1);
    out.T_c_ex = out.T_c_vec(end);
    out.Q_dot_tot = Q_dot_eff;
    
    % Entropy calculation
    [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
    if param.generateTS
        if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
            for i = 1: length(out.H_h_vec)
                out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
            end
        end
        if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
            for i = 1: length(out.H_c_vec)
                out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
            end
        end
    end
    % Mass calculation
    out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
    out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
    for i = 1: length(out.V_h_vec)
        if strcmp(param.type_h,'H')
            out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
        else
            out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
        end
        if strcmp(param.type_c,'H')
            out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
        else
            out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', T_c_vec(i),  T_c_vec(i+1), P_c_su, fluid_c);
        end
    end
    out.M_h = sum(out.M_h_vec);
    out.M_c = sum(out.M_c_vec);
    
    if (T_h_su-T_c_su)<1e-2  && (T_h_su-T_c_su >0)  && m_dot_h  > 0 && m_dot_c > 0
        out.flag = 3;
    else
        out.flag = -3;
    end
end
out.flag_reverse = flag_reverse;

if flag_reverse
    out.Qdot_vec = flip(out.Qdot_vec);
    [out.H_h_vec, out.H_c_vec] = deal(flip(out.H_c_vec), flip(out.H_h_vec));
    [out.T_h_vec, out.T_c_vec] = deal(flip(out.T_c_vec), flip(out.T_h_vec));    
    out.DT_vec = flip(out.DT_vec);


    [out.h_h_ex, out.h_c_ex] = deal(out.h_c_ex, out.h_h_ex);    
    [out.T_h_ex, out.T_c_ex] = deal(out.T_c_ex, out.T_h_ex);    
    [out.s_h_vec, out.s_c_vec] = deal(flip(out.s_c_vec), flip(out.s_h_vec));
    [out.V_h_vec, out.V_c_vec] = deal(flip(out.V_c_vec), flip(out.V_h_vec));
    [out.M_h_vec, out.M_c_vec] = deal(flip(out.M_c_vec), flip(out.M_h_vec));   
    [out.M_h, out.M_c] = deal(out.M_c, out.M_h);          
    out.x_vec = (out.H_h_vec-out.H_h_vec(1))./(out.H_h_vec(end)-out.H_h_vec(1));
    if strcmp(param.modelType, 'hConvVar') && out.flag ~= 3 &&  out.flag ~= -3
        [out.hConv_h, out.hConv_c] = deal(flip(out.hConv_c), flip(out.hConv_h));
        out.DTlog = flip(out.DTlog);
        [out.eff_h, out.eff_c] = deal(flip(out.eff_c), flip(out.eff_h));
        [out.A_h, out.A_c] = deal(flip(out.A_c), flip(out.A_h));
        out.U = flip(out.U);
        [out.type_zone_h, out.type_zone_c] = deal(flip(out.type_zone_c), flip(out.type_zone_h));
    end
end

out.time = toc(tstart_hex);

%% TS DIAGRAM and DISPLAY

% Generate the output variable TS
if param.generateTS
    TS.T_h = out.T_h_vec;
    TS.T_c = out.T_c_vec;
    TS.s_h = out.s_h_vec;
    TS.s_c = out.s_c_vec;
    TS.x = out.x_vec;
    TS.x_geom = [0 cumsum(out.V_h_vec)./param.V_h_tot];
else
    TS = NaN;
end
% If the param.displayTS flag is activated (=1), the temperature profile is
% plotted in a new figure
if param.displayTS == 1
    figure
    %subplot(2,1,1)
    hold on
    plot(TS.x_geom, TS.T_c-273.15,'s-' ,'linewidth',2)
    plot(TS.x_geom, TS.T_h-273.15,'o-' ,'linewidth',2)
    grid on
    xlabel('Heat power fraction [-]','fontsize',14,'fontweight','bold')
    ylabel('Temperature [�C]','fontsize',14,'fontweight','bold')
    set(gca,'fontsize',14,'fontweight','bold')
    
    %subplot(2,1,2)
    %hold on
    %plot(TS.x_geom, cumsum([0 out.V_c_vec]),'s-' ,'linewidth',2)
    %plot(TS.x_geom(strcmp(out.type_zone_c, 'tp')), out.Weight_c(strcmp(out.type_zone_c, 'tp')),'s-' ,'linewidth',2)
    %axis([0.25 0.4 0 0.1])
    %grid on
    %xlabel('Length [-]','fontsize',14,'fontweight','bold')
    %ylabel('Mass provile [�C]','fontsize',14,'fontweight','bold')
    %set(gca,'fontsize',14,'fontweight','bold')
end

% If the param.displayResults flag is activated (=1), the results are displayed on the
% command window
if param.displayResults ==1
    in.fluid_h = fluid_h;
    in.m_dot_h = m_dot_h;
    in.in_h_su = in_h_su;
    in.type_h = param.type_h;
    in.P_h_su = P_h_su;
    in.fluid_c = fluid_c;
    in.m_dot_c = m_dot_c;
    in.in_c_su = in_c_su;
    in.type_c = param.type_c;
    in.P_c_su = P_c_su;
    in.modelType= param.modelType;
    
    if nargin ==0
        fprintf ( 1, '\n' );
        disp('-------------------------------------------------------')
        disp('--------------------   Demo Code   --------------------')
        disp('-------------------------------------------------------')
        fprintf ( 1, '\n' );
    end
    disp('Working conditions:')
    fprintf ( 1, '\n' );
    disp(in)
    disp('Results')
    disp(out)
    
end

end


function res = HEX_CstPinch_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, pinch, Q_dot, info)
% function giving the residual committed on the pinch for a given Q_dot
out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
res = pinch - out.pinch;
end

function res = HEX_hConvCst_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info)
% function giving the residual committed on the HEX surface area for a given Q_dot
out = HEX_hConvCst(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info);
res = out.resA;
end

function out = HEX_hConvCst(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info)
out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
[out.hConv_h, out.hConv_c, out.DTlog, out.eff_h, out.eff_c, out.A_h, out.A_c, out.U] = deal(NaN*ones(1,length(out.T_h_vec)-1));
for j = 1:length(out.T_h_vec)-1
    % Hot side heat transfer coefficient
    if strcmp(info.type_h, 'H')
        if isempty(strfind(fluid_h, 'INCOMP:'))
            if (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) < CoolProp.PropsSI('H','P',P_h_su,'Q',0,fluid_h)
                out.hConv_h(j) = info.hConv_h_liq;
            elseif (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) > CoolProp.PropsSI('H','P',P_h_su,'Q',1,fluid_h)
                out.hConv_h(j) = info.hConv_h_vap;
            else
                out.hConv_h(j) = info.hConv_h_tp;
            end
        else
            out.hConv_h(j) = info.hConv_h_liq;
        end
    elseif strcmp(info.type_h, 'T')
        out.hConv_h(j) = info.hConv_h_liq;
    end
    % Cold side heat transfer coefficient
    if strcmp(info.type_c, 'H')
        if isempty(strfind(fluid_c, 'INCOMP:'))
            if (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) < CoolProp.PropsSI('H','P',P_c_su,'Q',0,fluid_c)
                out.hConv_c(j) = info.hConv_c_liq;
            elseif (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) > CoolProp.PropsSI('H','P',P_c_su,'Q',1,fluid_c)
                out.hConv_c(j) = info.hConv_c_vap;
            else
                out.hConv_c(j) = info.hConv_c_tp;
            end
            out.hConv_c(j) = info.hConv_c_liq;
        else
            out.hConv_c(j) = info.hConv_c_liq;
        end
    elseif strcmp(info.type_c, 'T')
        out.hConv_c(j) = info.hConv_c_liq;
    end
    out.DTlog(j) = deltaT_log(out.T_h_vec(j+1), out.T_h_vec(j),out.T_c_vec(j), out.T_c_vec(j+1));
    
    % Hot side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_h'))
        out.eff_h(j) = 1;
    elseif strcmp(info.fin_h, 'none')
        out.eff_h(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_h(j),info.fin_h.k, info.fin_h.th, info.fin_h.r, info.fin_h.B, info.fin_h.H);
        out.eff_h(j) = 1-info.fin_h.omega_f*(1-eta_eff);
    end
    
    % Cold side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_c'))
        out.eff_c(j) = 1;
    elseif strcmp(info.fin_c, 'none')
        out.eff_c(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_c(j), info.fin_c.k, info.fin_c.th, info.fin_c.r, info.fin_c.B, info.fin_c.H);
        out.eff_c(j) = 1-info.fin_c.omega_f*(1-eta_eff);
    end
    
    % Global heat transfer coefficient and zone surface area
    out.U(j) = (1/out.hConv_h(j)/out.eff_h(j) + 1/out.hConv_c(j)/out.eff_c(j)/(info.A_c_tot/info.A_h_tot))^-1;
    out.A_h(j) = out.Qdot_vec(j)/out.DTlog(j)/out.U(j);
    out.A_c(j) = out.A_h(j)*info.A_c_tot/info.A_h_tot;
end
out.A_h_tot = sum(out.A_h);
out.resA = 1 - out.A_h_tot/info.A_h_tot;
end

function res = HEX_hConvVar_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info, h_h_l, h_h_v, h_c_l, h_c_v)
% function giving the residual committed on the HEX surface area for a given Q_dot
out = HEX_hConvVar(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info, h_h_l, h_h_v, h_c_l, h_c_v);
res = out.resA;
end

function out = HEX_hConvVar(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info, h_h_l, h_h_v, h_c_l, h_c_v)
out = HEX_profile_3(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info, h_h_l, h_h_v, h_c_l, h_c_v); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
[out.hConv_h, out.hConv_c, out.DTlog, out.eff_h, out.eff_c, out.A_h, out.A_c, out.U] = deal(NaN*ones(1,length(out.H_h_vec)-1));
for j = 1:length(out.T_h_vec)-1
    % Hot side heat transfer coefficient
    if strcmp(info.type_h, 'H')
        if isempty(strfind(fluid_h, 'INCOMP:'))
            if (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) < h_h_l
                out.hConv_h(j) = info.hConv_h_liq_n*(m_dot_h/info.m_dot_h_n)^info.n_h_liq;
                out.type_zone_h{j} = 'liq';
            elseif (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) > h_h_v
                out.hConv_h(j) = info.hConv_h_vap_n*(m_dot_h/info.m_dot_h_n)^info.n_h_vap;
                out.type_zone_h{j} = 'vap';
            else
                out.hConv_h(j) = info.hConv_h_tp_n*(m_dot_h/info.m_dot_h_n)^info.n_h_tp;
                out.type_zone_h{j} = 'tp';
            end
        else
            out.hConv_h(j) = info.hConv_h_liq_n*(m_dot_h/info.m_dot_h_n)^info.n_h_liq;
            out.type_zone_h{j} = 'liq';
        end
    elseif strcmp(info.type_h, 'T')
        out.hConv_h(j) = info.hConv_h_liq_n*(m_dot_h/info.m_dot_h_n)^info.n_h_liq;
        out.type_zone_h{j} = 'liq';
    end
    
    % Cold side heat transfer coefficient
    if strcmp(info.type_c, 'H')
        if isempty(strfind(fluid_c, 'INCOMP:'))
            if (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) < h_c_l
                out.hConv_c(j) = info.hConv_c_liq_n*(m_dot_c/info.m_dot_c_n)^info.n_c_liq;
                out.type_zone_c{j} = 'liq';
            elseif (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) > h_c_v
                out.hConv_c(j) = info.hConv_c_vap_n*(m_dot_c/info.m_dot_c_n)^info.n_c_vap;
                out.type_zone_c{j} = 'vap';
            else
                out.hConv_c(j) = info.hConv_c_tp_n*(m_dot_c/info.m_dot_c_n)^info.n_c_tp;
                out.type_zone_c{j} = 'tp';
            end
        else
            out.hConv_c(j) = info.hConv_c_liq_n*(m_dot_c/info.m_dot_c_n)^info.n_c_liq;
            out.type_zone_c{j} = 'liq';
        end
    elseif strcmp(info.type_c, 'T')
        out.hConv_c(j) = info.hConv_c_liq_n*(m_dot_c/info.m_dot_c_n)^info.n_c_liq;
        out.type_zone_c{j} = 'liq';
    end
    out.DTlog(j) = deltaT_log(out.T_h_vec(j+1), out.T_h_vec(j),out.T_c_vec(j), out.T_c_vec(j+1));
    
    % Hot side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_h'))
        out.eff_h(j) = 1;
    elseif strcmp(info.fin_h, 'none')
        out.eff_h(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_h(j), info.fin_h.k, info.fin_h.th, info.fin_h.r, info.fin_h.B, info.fin_h.H);
        out.eff_h(j) = 1-info.fin_h.omega_f*(1-eta_eff);
    end
    
    % Cold side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_c'))
        out.eff_c(j) = 1;
    elseif strcmp(info.fin_c, 'none')
        out.eff_c(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_c(j), info.fin_c.k, info.fin_c.th, info.fin_c.r, info.fin_c.B, info.fin_c.H);
        out.eff_c(j) = 1-info.fin_c.omega_f*(1-eta_eff);
    end
    
    % Global heat transfer coefficient and zone surface area
    out.U(j) = (1/out.hConv_h(j)/out.eff_h(j) + 1/out.hConv_c(j)/out.eff_c(j)/(info.A_c_tot/info.A_h_tot))^-1;
    out.A_h(j) = out.Qdot_vec(j)/out.DTlog(j)/out.U(j);
    out.A_c(j) = out.A_h(j)*info.A_c_tot/info.A_h_tot;
end
out.A_h_tot = sum(out.A_h);
out.resA = 1 - out.A_h_tot/info.A_h_tot;
end

function res = HEX_hConvCor_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info, h_h_l, h_h_v, h_c_l, h_c_v)
% function giving the residual committed on the HEX surface area for a given Q_dot
out = HEX_hConvCor(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, real(Q_dot), info, h_h_l, h_h_v, h_c_l, h_c_v);
res = out.resA;

end

function out = HEX_hConvCor(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info, h_h_l, h_h_v, h_c_l, h_c_v)

out = HEX_profile_3(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info, h_h_l, h_h_v, h_c_l, h_c_v); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
[out.A_h, out.A_c, out.hConv_h, out.hConv_c, out.DTlog] = deal(NaN*ones(1,length(out.H_h_vec)-1));

for j = 1:length(out.T_h_vec)-1

    % LMTD for the current cell
    out.DTlog(j) = deltaT_log(out.T_h_vec(j+1), out.T_h_vec(j),out.T_c_vec(j), out.T_c_vec(j+1));
    
    % What type of cells for hot side (1phase or 2phase?)    
    if strcmp(info.type_h, 'H')
        if isempty(strfind(fluid_h, 'INCOMP:'))
            if (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) < h_h_l
                out.type_zone_h{j} = 'liq';
            elseif (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) > h_h_v
                out.type_zone_h{j} = 'vap';
            else
                out.type_zone_h{j} = 'tp';
            end
        else
            out.type_zone_h{j} = 'liq';
        end
    elseif strcmp(info.type_h, 'T')
        out.type_zone_h{j} = 'liq';
    end
        
    % What type of cells for cold side (1phase or 2phase?)
    if strcmp(info.type_c, 'H')
        if isempty(strfind(fluid_c, 'INCOMP:'))
            if (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) < h_c_l
                out.type_zone_c{j} = 'liq';
            elseif (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) > h_c_v
                out.type_zone_c{j} = 'vap';
            else
                out.type_zone_c{j} = 'tp';
            end
        else
            out.type_zone_c{j} = 'liq';
        end
    elseif strcmp(info.type_c, 'T')
        out.type_zone_c{j} = 'liq';
    end
    
    % Hot-side convective heat transfer coefficient
    if strcmp(out.type_zone_h{j}, 'liq') || strcmp(out.type_zone_h{j}, 'vap')
        
        switch info.correlation_h.type_1phase
            case 'Martin'
                if strcmp(info.type_h, 'H')
                    mu_h = CoolProp.PropsSI('V', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    Pr_h = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    k_h = CoolProp.PropsSI('L', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                elseif strcmp(info.type_h, 'T')
                    cp_h = sf_PropsSI_bar('C', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    k_h = sf_PropsSI_bar('L', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    mu_h = sf_PropsSI_bar('V', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    Pr_h = cp_h*mu_h/k_h;
                end
                G_h = m_dot_h/info.n_canals_h/info.CS_h;
                Re_h = G_h*info.Dh_h/mu_h;
                if Re_h < 2000
                    f_0 = 16/Re_h;
                    f_90 = 149.25/Re_h+0.9625;
                else
                    f_0 = (1.56*log(Re_h)-3)^-2;
                    f_90 = 9.75/Re_h^0.289;
                end               
                f_h = (((cos(info.theta))/sqrt(0.045*tan(info.theta) + 0.09*sin(info.theta) + f_0/cos(info.theta)))+((1-cos(info.theta))/(sqrt(3.8*f_90))))^(-0.5);
                Nu_h = info.fact_corr_sp_h*0.205*(Pr_h^0.33333333)*(f_h*Re_h^2*sin(2*info.theta))^(info.fact2_corr_sp_h*0.374);
                out.hConv_h(j) = Nu_h*k_h/info.Dh_h;
                
            case 'Wanniarachchi'
                if strcmp(info.type_h, 'H')
                    mu_h = CoolProp.PropsSI('V', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    Pr_h = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    k_h = CoolProp.PropsSI('L', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                elseif strcmp(info.type_h, 'T')
                    cp_h = sf_PropsSI_bar('C', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    k_h = sf_PropsSI_bar('L', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    mu_h = sf_PropsSI_bar('V', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    Pr_h = cp_h*mu_h/k_h;
                end
                G_h = m_dot_h/info.n_canals_h/info.CS_h;
                Re_h = G_h*info.Dh_h/mu_h;
                j_Nu_h_t = 12.6*(90-info.theta*180/pi)^(-1.142)*Re_h^(info.fact2_corr_sp_h*(0.646+0.00111*(90-info.theta*180/pi)));                
                j_Nu_h_l = 3.65*(90-info.theta*180/pi)^(-0.455)*Re_h^(info.fact2_corr_sp_h*-0.339);
                Nu_h = info.fact_corr_sp_h*(j_Nu_h_l^3 + j_Nu_h_t^3)^(1/3)*Pr_h^(1/3);
                out.hConv_h(j) = Nu_h*k_h/info.Dh_h;
                
            case 'Thonon'
                if strcmp(info.type_h, 'H')
                    mu_h = CoolProp.PropsSI('V', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    Pr_h = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    k_h = CoolProp.PropsSI('L', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                elseif strcmp(info.type_h, 'T')
                    cp_h = sf_PropsSI_bar('C', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    k_h = sf_PropsSI_bar('L', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    mu_h = sf_PropsSI_bar('V', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    Pr_h = cp_h*mu_h/k_h;
                end
                G_h = m_dot_h/info.n_canals_h/info.CS_h;
                Re_h = G_h*info.Dh_h/mu_h;
                if info.theta <= 15*pi/180
                    C = 0.1;
                    m = 0.687;
                elseif info.theta > 15*pi/180 && info.theta <= 30*pi/180
                    C = 0.2267;
                    m = 0.631;
                elseif  info.theta > 30*pi/180 && info.theta <= 45*pi/180
                    C = 0.2998;
                    m = 0.645;
                elseif info.theta > 45*pi/180 && info.theta <= 60*pi/180
                    C = 0.2946;
                    m = 0.7;
                end
                Nu_h = info.fact_corr_sp_h*C*Re_h^(info.fact2_corr_sp_h*m)*Pr_h^0.33333333;
                out.hConv_h(j) = Nu_h*k_h/info.Dh_h;
                
            case 'Gnielinski_and_Sha'
                if strcmp(info.type_h, 'H')
                    mu_h = CoolProp.PropsSI('V', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    Pr_h = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    k_h = CoolProp.PropsSI('L', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                elseif strcmp(info.type_h, 'T')
                    cp_h = sf_PropsSI_bar('C', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    k_h = sf_PropsSI_bar('L', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    mu_h = sf_PropsSI_bar('V', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    Pr_h = cp_h*mu_h/k_h;
                end
                G_h = m_dot_h/info.n_canals_h/info.CS_h;
                
                Re_h = G_h*info.Dh_h/mu_h;
                if Re_h > 2300 %source: VDI section G1 - 4.1, page 696 
                    f_h = (1.8*log10(Re_h)-1.5)^-2; %Konakov correlation 
                    Nu_h = ((f_h/8)*(Re_h-1000)*Pr_h)/(1+12.7*sqrt(f_h/8)*(Pr_h^(2/3)-1)); % Gnielinski
                else %source: VDI section G1 - 3.2.1, page 695 
                    Nu_1 = 4.364;
                    Nu_2 = 1.953*(Re_h*Pr_h*info.Dh_h/info.Lt_h)^0.33333333333333333333333333333;
                    Nu_h = (Nu_1^3 + 0.6^3 + (Nu_2-0.6)^3)^0.3333333333333333333333;
                end
                out.hConv_h(j) = info.fact_corr_sp_h*Nu_h*k_h/info.Dh_h;
                
            case 'Manual'
                out.hConv_h(j) = info.hConv_h_sp;
        end
        
    elseif strcmp(out.type_zone_h{j}, 'tp') 
        
        switch info.correlation_h.type_2phase
            case 'Han_condensation'
                mu_h_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_h_su, fluid_h);
                k_h_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_h_su, fluid_h);
                x_h = CoolProp.PropsSI('Q', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                Pr_h_l = CoolProp.PropsSI('Prandtl', 'Q', 0, 'P', P_h_su, fluid_h);
                rho_h_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_h_su, fluid_h);
                rho_h_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_h_su, fluid_h);
                G_h = (m_dot_h/info.n_canals_h)/info.CS_h;
                G_h_eq = G_h * ( (1 - x_h) + x_h * (rho_h_l/rho_h_v)^0.5);
                Re_h_eq = G_h_eq*info.Dh_h/mu_h_l;                
                Ge1 = 11.22*(info.pitch_co/info.Dh_h)^-2.83*(info.theta)^(-4.5);
                Ge2 = 0.35*(info.pitch_co/info.Dh_h)^0.23*(info.theta)^(1.48);
                Nu_h = info.fact_corr_2p_h*Ge1*Re_h_eq^(info.fact2_corr_2p_h*Ge2)*Pr_h_l^0.33333333;
                out.hConv_h(j) = Nu_h*k_h_l/info.Dh_h;
            
            case 'Longo_condensation'
                mu_h_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_h_su, fluid_h);
                k_h_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_h_su, fluid_h);
                Pr_h_l = CoolProp.PropsSI('Prandtl', 'Q', 0, 'P', P_h_su, fluid_h);
                x_h = CoolProp.PropsSI('Q', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                rho_h_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_h_su, fluid_h);
                rho_h_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_h_su, fluid_h);
                G_h = (m_dot_h/info.n_canals_h)/info.CS_h;
                G_h_eq = G_h * ( (1 - x_h) + x_h * (rho_h_l/rho_h_v)^0.5);
                Re_h_eq = G_h_eq*info.Dh_h/mu_h_l;
                i_fg_h = CoolProp.PropsSI('H', 'Q', 1, 'P', P_h_su, fluid_h) - CoolProp.PropsSI('H', 'Q', 0, 'P', P_h_su, fluid_h);
                g = 9.81;               
                if Re_h_eq < 1600
                    T_sat = (0.5*out.T_h_vec(j)+0.5*out.T_h_vec(j+1));
                    T_wall = (0.25*out.T_h_vec(j)+0.25*out.T_h_vec(j+1) + 0.25*out.T_c_vec(j)+0.25*out.T_c_vec(j+1));
                    out.hConv_h(j) = info.fact_corr_2p_h*info.phi*0.943*((k_h_l^3*rho_h_l^2*g*i_fg_h)/(mu_h_l*(T_sat-T_wall)*info.L_hex))^0.25;
                else
                    out.hConv_h(j) = info.fact_corr_2p_h*1.875*info.phi*k_h_l/info.Dh_h*Re_h_eq^(info.fact2_corr_2p_h*0.445)*Pr_h_l^0.3333333;
                end
                
            case 'Cavallini_condensation'
                mu_h_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_h_su, fluid_h);
                mu_h_v = CoolProp.PropsSI('V', 'Q', 1, 'P', P_h_su, fluid_h);
                rho_h_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_h_su, fluid_h);
                rho_h_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_h_su, fluid_h);
                Pr_h_l = CoolProp.PropsSI('Prandtl', 'Q', 0, 'P', P_h_su, fluid_h);
                x_h = CoolProp.PropsSI('Q', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                k_h_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_h_su, fluid_h);                
                d_i = info.Dh_h;
                g = 9.81;
                C_T = 2.6; %1.6 for HC or 2.6 for other refrigerant
                X_tt = ((mu_h_l/mu_h_v)^0.1)*((rho_h_v/rho_h_l)^0.5)*((1-x_h)/x_h)^0.9; %Martinelli factor
                             
                G_h = (m_dot_h/info.n_canals_h)/info.CS_h;
                Re_h_l = G_h*info.Dh_h/mu_h_l;              
                J_v = x_h*G_h/sqrt(g*d_i*rho_h_v*(rho_h_l-rho_h_v)); 
                J_v_T = (((7.5/(4.3*X_tt^1.111 + 1))^-3) + ((C_T)^-3) )^-0.333333333333333333;
                h_h_lo = 0.023*Re_h_l^(info.fact2_corr_2p_h*0.8)*Pr_h_l^0.4*k_h_l/d_i;
                h_h_a = h_h_lo*(1 + (1.128*x_h^0.817)*((rho_h_l/rho_h_v)^0.3685)*((mu_h_l/mu_h_v)^0.2363)*((1-mu_h_v/mu_h_l)^2.144)*(Pr_h_l^-0.1));                
                
                if J_v > J_v_T %delta_T-independent flow regime
                    out.hConv_h(j) = info.fact_corr_2p_h*h_h_a;
                elseif J_v <= J_v_T %delta_T-dependent flow regime
                    i_fg_h = CoolProp.PropsSI('H', 'Q', 1, 'P', P_h_su, fluid_h) - CoolProp.PropsSI('H', 'Q', 0, 'P', P_h_su, fluid_h);
                    T_sat = (0.5*out.T_h_vec(j)+0.5*out.T_h_vec(j+1));
                    T_wall = (0.25*out.T_h_vec(j)+0.25*out.T_h_vec(j+1) + 0.25*out.T_c_vec(j)+0.25*out.T_c_vec(j+1));
                    h_strat = 0.725*((1+0.741*((1-x_h)/x_h)^0.3321)^-1)*(((k_h_l^3*rho_h_l*(rho_h_l-rho_h_v)*g*i_fg_h)/(mu_h_l*d_i*(T_sat-T_wall)))^0.25)+((1-x_h^0.087)*h_h_lo);
                    h_h_d = J_v/J_v_T*(h_h_a*(J_v_T/J_v)^0.8 - h_strat) + h_strat;
                    out.hConv_h(j) = info.fact_corr_2p_h*h_h_d;
                end
                
            case 'Shah_condensation'
                mu_h_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_h_su, fluid_h);
                p_h_star = P_c_su/CoolProp.PropsSI('Pcrit', 'Q', 1, 'P', P_c_su, fluid_c);              
                x_h = CoolProp.PropsSI('Q', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                k_h_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_h_su, fluid_h);                
                G_h = (m_dot_h/info.n_canals_h)/info.CS_h;
                Re_h_l = G_h*info.Dh_h/mu_h_l;  
                Pr_h_l = CoolProp.PropsSI('Prandtl', 'Q', 0, 'P', P_h_su, fluid_h);
                out.hConv_h(j) = info.fact_corr_2p_h*0.023*(k_h_l/info.Dh_h)*(Re_h_l^(info.fact2_corr_2p_h*0.8))*(Pr_h_l^0.4)*(((1-x_h)^0.8)+ ((3.8*(x_h^0.76)*(1-x_h)^0.04)/(p_h_star^0.38)));
                
            case 'Manual'
                out.hConv_h(j) = info.hConv_h_2p;
        end
        
    end
    
    % Cold-side convective heat transfer coefficient
    if strcmp(out.type_zone_c{j}, 'liq') || strcmp(out.type_zone_c{j}, 'vap')
        
        switch info.correlation_c.type_1phase
            case 'Martin'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c;
                Re_c = G_c*info.Dh_c/mu_c;               
                if Re_c < 2000
                    f_0 = 16/Re_c;
                    f_90 = 149.25/Re_c+0.9625;
                else
                    f_0 = (1.56*log(Re_c)-3)^-2;
                    f_90 = 9.75/Re_c^0.289;
                end
                f_c = (((cos(info.theta))/sqrt(0.045*tan(info.theta) + 0.09*sin(info.theta) + f_0/cos(info.theta)))+((1-cos(info.theta))/(sqrt(3.8*f_90))))^(-0.5);
                Nu_c = info.fact_corr_sp_c*0.205*(Pr_c^0.33333333)*(f_c*Re_c^2*sin(2*info.theta))^(info.fact2_corr_sp_c*0.374);
                out.hConv_c(j) = Nu_c*k_c/info.Dh_c;                
                
            case 'Wanniarachchi'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c;
                Re_c = G_c*info.Dh_c/mu_c;
                j_Nu_c_t = 12.6*(90-info.theta*180/pi)^(-1.142)*Re_c^(info.fact2_corr_sp_c*(0.646+0.00111*(90-info.theta*180/pi)));
                j_Nu_c_l = 3.65*(90-info.theta*180/pi)^(-0.455)*Re_c^(info.fact2_corr_sp_c*-0.339);
                Nu_c = info.fact_corr_sp_c*(j_Nu_c_l^3 + j_Nu_c_t^3)^(1/3)*Pr_c^(1/3);
                out.hConv_c(j) = Nu_c*k_c/info.Dh_c;
                
            case 'Thonon'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c;
                Re_c = G_c*info.Dh_c/mu_c;
                if info.theta <= 15*pi/180
                    C = 0.1;
                    m = 0.687;
                elseif info.theta > 15*pi/180 && info.theta <= 30*pi/180
                    C = 0.2267;
                    m = 0.631;
                elseif  info.theta > 30*pi/180 && info.theta <= 45*pi/180
                    C = 0.2998;
                    m = 0.645;
                elseif info.theta > 45*pi/180 && info.theta <= 60*pi/180
                    C = 0.2946;
                    m = 0.7;
                end
                Nu_c = info.fact_corr_sp_c*C*Re_c^(info.fact2_corr_sp_c*m)*Pr_c^0.33333333;
                out.hConv_c(j) = Nu_c*k_c/info.Dh_c;
  
                
            case 'Gnielinski'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c;
                Re_c = G_c*info.Dh_c/mu_c;
                if Re_c > 2300
                    f_c = (1.8*log10(Re_c)-1.5)^-2; %Konakov correlation
                    Nu_c = ((f_c/8)*(Re_c-1000)*Pr_c)/(1+12.7*sqrt(f_c/8)*(Pr_c^(2/3)-1));
                else
                    Nu_c = 3.66;
                end
                out.hConv_c(j) = info.fact_corr_sp_c*Nu_c*k_c/info.Dh_c;
                
            case 'Gnielinski_and_Sha'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c;
                
                Re_c = G_c*info.Dh_c/mu_c;
                if Re_c > 2300 %source: VDI section G1 - 4.1, page 696
                    f_c = (1.8*log10(Re_c)-1.5)^-2; %Konakov correlation
                    Nu_c = ((f_c/8)*(Re_c-1000)*Pr_c)/(1+12.7*sqrt(f_c/8)*(Pr_c^(2/3)-1)); % Gnielinski
                else %source: VDI section G1 - 3.2.1, page 695
                    Nu_1 = 4.364;
                    Nu_2 = 1.953*(Re_c*Pr_c*info.Dh_c/info.Lt_c)^0.33333333333333333333333333333;
                    Nu_c = (Nu_1^3 + 0.6^3 + (Nu_2-0.6)^3)^0.3333333333333333333333;
                end
                out.hConv_c(j) = info.fact_corr_sp_c*Nu_c*k_c/info.Dh_c;
                
            case 'VDI_finned_tubes_staggered' %source: VDI Heat Atlas, section M1 - 2.6, page 1275
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c; % Warning, CS_c is the minimum free flow surface area and n_canals_c is taken equal to 1               
                Re_c = G_c*info.Dh_c/mu_c; % Warning, Dh_c is the externel diameter of the tubes forming the bank
                Nu_c = info.fact_corr_sp_c*0.38*Re_c^(info.fact2_corr_sp_c*0.6)*Pr_c^0.33333333*info.fin_c.omega_t^-0.15;
                out.hConv_c(j) = Nu_c*k_c/info.Dh_c;
                
            case 'Wang_finned_tubes_staggered'
                
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                N = info.n_row_tubes;
                F_p = info.fin_pitch;
                D_c = info.Dh_c; %Dh_c is the externel diameter of the tubes forming the bank (tube diameter +2*fin thickness)
                P_l = info.tube_longitudital_pitch;
                D_h = info.Dh_c_bis; %Dh_c_bis is the actual hydraulic diameter = 4*(A_c/A_o)*L with L : longitudinal depth of the heat exchanger / Ac = minimal flow area/ Ao = total surface area
                G_c = m_dot_c/info.n_canals_c/info.CS_c; % Warning, CS_c is the minimum free flow surface area and n_canals_c is taken equal to 1
                Re_c_Dc = G_c*D_c/mu_c;                
                p1 = -0.361-0.042*N/log(Re_c_Dc)+0.158*log(N*(F_p/D_c)^0.41);
                p2 = -1.224-((0.076*(P_l/D_h)^1.42)/(log(Re_c_Dc)));
                p3 = -0.083+0.058*N/log(Re_c_Dc);
                p4 = -5.735 +1.21*log(Re_c_Dc/N);
                p5 = -0.93;
                j_c = 0.086*(Re_c_Dc^p1)*(N^p2)*((F_p/D_c)^p3)*((F_p/D_h)^p4)*((F_p/P_l)^p5);
                Nu_c = info.fact_corr_sp_c*(j_c*Re_c_Dc)^(info.fact2_corr_sp_c)*Pr_c^0.33333333333333333333;
                out.hConv_c(j) = Nu_c*k_c/D_c;
                
            case 'Manual'
                out.hConv_c(j) = info.hConv_c_sp;
        end
        
        
    elseif strcmp(out.type_zone_c{j}, 'tp')
        switch info.correlation_c.type_2phase
            case 'Han_boiling'
                mu_c_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_c_su, fluid_c);
                k_c_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_c_su, fluid_c);
                x_c = CoolProp.PropsSI('Q', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                Pr_c_l = CoolProp.PropsSI('Prandtl', 'Q', 0, 'P', P_c_su, fluid_c);
                rho_c_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_c_su, fluid_c);
                rho_c_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_c_su, fluid_c);
                i_fg_c = CoolProp.PropsSI('H', 'Q', 1, 'P', P_c_su, fluid_c) - CoolProp.PropsSI('H', 'Q', 0, 'P', P_c_su, fluid_c);
                G_c = (m_dot_c/info.n_canals_c)/info.CS_c;
                G_c_eq = G_c * ( (1 - x_c) + x_c * (rho_c_l/rho_c_v)^0.5);
                Re_c_eq = G_c_eq*info.Dh_c/mu_c_l;
                AU_tp = out.Qdot_vec(j)/out.DTlog(j);
                Ge1 = 2.81*(info.pitch_co/info.Dh_c)^-0.041*(info.theta)^(-2.83);
                Ge2 = 0.746*(info.pitch_co/info.Dh_c)^-0.082*(info.theta)^(0.61);
                Bo = 1;
                k = 0;
                err_Bo = 1;
                while k <= 10 && err_Bo > 5e-2 %iterate for boiling number
                    Nu = info.fact_corr_2p_c*Ge1*Re_c_eq^(info.fact2_corr_2p_c*Ge2)*Bo^0.3*Pr_c_l^0.4;
                    h = Nu*k_c_l/info.Dh_c;
                    U = (1/h +  1/out.hConv_h(j))^-1;
                    A_tp = AU_tp/U;
                    q = out.Qdot_vec(j)/A_tp;
                    Bo_new = q/(G_c_eq*i_fg_c);
                    err_Bo = abs(Bo_new-Bo)/Bo;
                    Bo = Bo_new;
                end
                if err_Bo > 5e-2
                    display('Han boiling: Wrong boiling number')
                end
                
                out.hConv_c(j) = h;
                
                
            case 'Almalfi_boiling'
                g = 9.81;
                rho_c_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_c_su, fluid_c);
                rho_c_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_c_su, fluid_c);
                rho_c = CoolProp.PropsSI('D', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                sigma_c = CoolProp.PropsSI('I', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                x_c = CoolProp.PropsSI('Q', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                k_c_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_c_su, fluid_c);
                G_c = (m_dot_c/info.n_canals_c)/info.CS_c;
                G_c_eq = G_c * ( (1 - x_c) + x_c * (rho_c_l/rho_c_v)^0.5);
                i_fg_c = CoolProp.PropsSI('H', 'Q', 1, 'P', P_c_su, fluid_c) - CoolProp.PropsSI('H', 'Q', 0, 'P', P_c_su, fluid_c);               
                Bd = (rho_c_l-rho_c_v)*g*info.Dh_c^2/sigma_c;
                beta_star = info.theta/(70*pi/180);
                rho_star = rho_c_l/rho_c_v;
                AU_tp = out.Qdot_vec(j)/out.DTlog(j);

                if Bd < 4
                    We = (G_c^2*info.Dh_c)/(rho_c*sigma_c);
                    Bo = 1;
                    k = 0;
                    err_Bo = 1;
                    while k <= 10 && err_Bo > 5e-2 %iterate for boiling number
                        k = k+1;
                        Nu_c = info.fact_corr_2p_c*982*beta_star^1.101*We^(info.fact2_corr_2p_c*0.315)*Bo^0.32*rho_star^-0.224;%
                        h = Nu_c*k_c_l/info.Dh_c;
                        U = (1/h +  1/out.hConv_h(j))^-1;
                        A_tp = AU_tp/U;
                        q = out.Qdot_vec(j)/A_tp;
                        Bo_new = q/(G_c_eq*i_fg_c);
                        err_Bo = abs(Bo_new-Bo)/Bo;
                        Bo = Bo_new;
                    end
                    if err_Bo > 5e-2
                    display('Almalfi boiling: Wrong boiling number')
                    end

                    out.hConv_c(j) = h;
                else
                    mu_c_v = CoolProp.PropsSI('V', 'Q', 1, 'P', P_c_su, fluid_c);
                    mu_c_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_c_su, fluid_c);
                    Re_c_v = G_c*x_c*info.Dh_c/mu_c_v;
                    Re_c_lo = G_c*info.Dh_c/mu_c_l;
                    Bo = 1;
                    k = 0;
                    err_Bo = 1;
                    while k <= 10 && err_Bo > 5e-2 %iterate for boiling number
                        k = k+1;       
                        Nu_c = info.fact_corr_2p_c*18.495*beta_star^0.248*Re_c_v^(info.fact2_corr_2p_c*0.135)*Re_c_lo^(info.fact2_corr_2p_c*0.351)*Bd^0.235*Bo^0.198*rho_star^-0.223;
                        h = Nu_c*k_c_l/info.Dh_c;
                        U = (1/h +  1/out.hConv_h(j))^-1;
                        A_tp = AU_tp/U;
                        q = out.Qdot_vec(j)/A_tp;
                        Bo_new = q/(G_c_eq*i_fg_c);
                        err_Bo = abs(Bo_new-Bo)/Bo;
                        Bo = Bo_new;
                    end
                    if err_Bo > 5e-2
                    display('Almalfi boiling: Wrong boiling number')
                    end

                    out.hConv_c(j) = h;
                end
                
            case 'Cooper_boiling'
                p_star = P_c_su/CoolProp.PropsSI('Pcrit', 'Q', 1, 'P', P_c_su, fluid_c);
                M = 1e3*CoolProp.PropsSI('M', 'Q', 1, 'P', P_c_su, fluid_c);
                Rp = 0.4; % roughness in �m
                AU_tp = out.Qdot_vec(j)/out.DTlog(j);
                q = out.Qdot_vec(j)/info.A_c_tot;
                err_q = 1;
                k = 0;
                while k <= 10 && err_q > 5e-2 %iterate for boiling number
                    k = k+1;
                    h = info.fact_corr_2p_c*55*(p_star^(0.12-0.2*log10(Rp)))*((-log10(p_star))^(-0.55*info.fact2_corr_2p_c))*(q^(info.fact2_corr_2p_c*0.67))*(M^(-0.5));
                    U = (1/h +  1/out.hConv_h(j))^-1;
                    A_tp = AU_tp/U;
                    q_new = out.Qdot_vec(j)/A_tp;
                    err_q = abs(q_new-q)/q;
                    q = q_new;
                end
                
                if err_q > 5e-2
                    display('Cooper boiling: Wrong heat flux')
                end
                out.hConv_c(j) = h;
                
            case 'Manual'
                out.hConv_c(j) = info.hConv_c_2p;
        end  
        
    end
    
    
    % Hot side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_h'))
        out.eff_h(j) = 1;
    elseif strcmp(info.fin_h, 'none')
        out.eff_h(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_h(j), info.fin_h.k, info.fin_h.th, info.fin_h.r, info.fin_h.B, info.fin_h.H);
        out.eff_h(j) = 1-info.fin_h.omega_f*(1-eta_eff);
    end
    
    % Cold side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_c'))
        out.eff_c(j) = 1;
    elseif strcmp(info.fin_c, 'none')
        out.eff_c(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_c(j), info.fin_c.k, info.fin_c.th, info.fin_c.r, info.fin_c.B, info.fin_c.H);
        out.eff_c(j) = 1-info.fin_c.omega_f*(1-eta_eff);
    end
    
    % Global heat transfer coefficient and zone surface area
    out.U(j) = (1/out.hConv_h(j)/out.eff_h(j) + 1/out.hConv_c(j)/out.eff_c(j)/(info.A_c_tot/info.A_h_tot))^-1;
    out.A_h(j) = out.Qdot_vec(j)/out.DTlog(j)/out.U(j);
    out.A_c(j) = out.A_h(j)*info.A_c_tot/info.A_h_tot;
end

out.A_h_tot = sum(out.A_h);
out.resA = 1 - out.A_h_tot/info.A_h_tot;

end

function [DT_log, DTh, DTc ]= deltaT_log(Th_su, Th_ex, Tc_su, Tc_ex)
% function that provides the mean logarithm temperature difference between two fluids
DTh = max(Th_su-Tc_ex,1e-2);
DTc = max(Th_ex-Tc_su,1e-2);
if DTh ~= DTc;
    DT_log = (DTh-DTc)/log(DTh/DTc);
else
    DT_log = DTh;
end
end

function eta_fin = FinSchmidt(hConv, k, th, r, B, H)
% functions that compute the fin efficiency based on Schmidt's theory and geometrical data of the HEX
m = sqrt(2*hConv/k/th);
phi_f = B/r;
beta_f = H/B;
R_e = r*1.27*phi_f*(beta_f-0.3)^0.5;
phi = (R_e/r - 1)*(1+0.35*log(R_e/r));
eta_fin = tanh(m*R_e*phi)/(m*R_e*phi);
end

function one_alpha = VoidFraction_Lockhart_Martinelli(q, rho_v, rho_l, mu_v, mu_l)
one_alpha = NaN*ones(size(q));
for i = 1:length(q)
    X_tt = (((1-q(i))/q(i))^0.9)*sqrt(((mu_l/mu_v)^0.1)*(rho_v/rho_l));
    if X_tt <= 10
        alpha = (1+X_tt^0.8)^-0.378;
    else
        alpha = 0.823-0.157*log(X_tt);
    end
    one_alpha(i) = 1-alpha;
end
end

function one_alpha = VoidFraction_Hughmark(q, rho_v, rho_l, mu_v, mu_l, D, G)
one_alpha = NaN*ones(size(q));
for i = 1:length(q)    
    q1 = q(i);
    beta = 1/(1+(((1-q1)/q1)*(rho_v/rho_l)));   
    f = @(x) residualVoidFraction_Hughmark(x,q1, beta, rho_v, mu_v, mu_l, D, G);
    alpha = zeroBrent (0, 1, 1e-8, 1e-8, f );    
    res_alpha = f(alpha);      
    if res_alpha > 1e-3
        display(['Error in Hughmark void fraction model, residual : ' num2str(res_alpha)])
        disp(['q1 = ' num2str(q1)]);        
        disp(['beta = ' num2str(beta)]);       
        disp(['rho_v = ' num2str(rho_v)]);       
        disp(['mu_v = ' num2str(mu_v)]);        
        disp(['mu_l = ' num2str(mu_l)]);        
        disp(['D = ' num2str(D)]);       
        disp(['G = ' num2str(G)]);
    end
    one_alpha(i) = 1-alpha;
end
%figure;
%hold on
%plot(q, one_alpha, 'o-')
end

function res = residualVoidFraction_Hughmark(x,q1, beta, rho_v, mu_v, mu_l, D, G)
Z = (((D*G)/(mu_l+x*(mu_v-mu_l)))^(1/6))*(((1/9.81/D)*(G*q1/(rho_v*beta*(1-beta)))^2)^(1/8));
ln_Z = log(Z);
p1 = -0.010060658854755;
p2 = 0.155594796014726;
p3 = -0.870912508715887;
p4 = 2.167004115373165;
p5 = -2.224608445535130;
ln_Kh = p1*ln_Z^4 + p2*ln_Z^3 + p3*ln_Z^2 + p4*ln_Z + p5;
Kh = exp(ln_Kh);
alpha_new = Kh*beta;
res= (x-alpha_new);
end

function one_alpha = VoidFraction_Zivi(q, rho_v, rho_l)
S_zivi = (rho_v/rho_l)^(-1/3);
alpha = 1./(1+(((1-q)./q).*(rho_v/rho_l)*S_zivi));
one_alpha = 1-alpha;
end

function one_alpha = VoidFraction_Premoli(q, rho_v, rho_l, mu_l, sig, D, G)
Re_f = G*D/mu_l;
We_f = G^2*D/sig/rho_l;
y = (rho_l/rho_v)*(q./(1-q));
F1 = 1.578*(Re_f^-0.19)*(rho_l/rho_v)^0.22;
F2 = 0.0273*We_f*(Re_f^-0.51)*(rho_l/rho_v)^-0.08;
S_Premoli = 1+F1*sqrt(max(0,y./(1+y*F2) -y.*F2));
alpha = 1./(1+(((1-q)./q).*(rho_v/rho_l).*S_Premoli));
one_alpha = 1-alpha;
end

function one_alpha = VoidFraction_homogenous(q, rho_v, rho_l)
alpha = 1./(1+((1-q)./q).*(rho_v/rho_l));
one_alpha = 1-alpha;
end

function one_alpha = VoidFraction_SlipRatio(q, rho_v, rho_l, S)
alpha = 1./(1+(((1-q)./q).*(rho_v/rho_l)*S));
one_alpha = 1-alpha;
end