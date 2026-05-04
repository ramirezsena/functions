function m = calcula_m_ISO9613(f, t_C, UR, pa)
% calcula_m_ISO9613
% Calcula o coeficiente m [1/m] usado na ISO 354,
% a partir do coeficiente de atenuação atmosférica da ISO 9613-1.
%
% Entradas:
% f    = frequência ou vetor de frequências [Hz]
% t_C  = temperatura do ar [°C]
% UR   = umidade relativa [%]  Exemplo: usar 78, não 0.78
% pa   = pressão atmosférica [kPa]
%
% Saída:
% m    = power attenuation coefficient [1/m]

% Constantes de referência
pr = 101.325;   % pressão atmosférica de referência [kPa]
T0 = 293.15;    % temperatura de referência [K]
T01 = 273.16;   % temperatura do ponto triplo da água [K]

% Temperatura em Kelvin
T = 273.15 + t_C;

% Pressão de saturação do vapor d'água
C = -6.8346 .* (T01 ./ T).^1.261 + 4.6151;
psat_sobre_pr = 10.^C;

% Concentração molar de vapor d'água [%]
h = UR .* psat_sobre_pr ./ (pa ./ pr);

% Frequência de relaxação do oxigênio [Hz]
frO = (pa ./ pr) .* ...
    (24 + 4.04e4 .* h .* (0.02 + h) ./ (0.391 + h));

% Frequência de relaxação do nitrogênio [Hz]
frN = (pa ./ pr) .* (T ./ T0).^(-1/2) .* ...
    (9 + 280 .* h .* exp(-4.170 .* ((T ./ T0).^(-1/3) - 1)));

% Coeficiente de atenuação atmosférica alpha [dB/m]
alpha = 8.686 .* f.^2 .* ...
    ( ...
    1.84e-11 .* (pr ./ pa) .* (T ./ T0).^(1/2) + ...
    (T ./ T0).^(-5/2) .* ...
    ( ...
    (0.01275 .* exp(-2239.1 ./ T)) ./ (frO + f.^2 ./ frO) + ...
    (0.1068  .* exp(-3352   ./ T)) ./ (frN + f.^2 ./ frN) ...
    ) ...
    );

% Conversão de alpha [dB/m] para m [1/m]
m = alpha ./ (10 * log10(exp(1)));

end

% % Exemplo de uso
% freq = [100 125 160 200 250 315 400 500 630 800 1000 1250 ...
%         1600 2000 2500 3150 4000 5000];
% 
% t_C = 23;       % temperatura [°C]
% UR = 78;        % umidade relativa [%]
% pa = 101.325;   % pressão atmosférica [kPa]
% 
% m = calcula_m_ISO9613(freq, t_C, UR, pa);