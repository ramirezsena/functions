function resultado = classifica_ASTM_C423(freq, alpha_s)
% classifica_ASTMC423
% Calcula SAA e NRC conforme ASTM C423.
%
% Entradas:
% freq    = vetor de frequências em bandas de 1/3 de oitava [Hz]
% alpha_s = vetor de coeficientes de absorção sonora [-]
%
% Saída:
% resultado = estrutura com SAA, NRC, tabelas auxiliares e texto final

% Garantir vetores coluna
freq = freq(:);
alpha_s = alpha_s(:);

% Verificar tamanhos
if length(freq) ~= length(alpha_s)
    error('freq e alpha_s devem ter o mesmo número de elementos.')
end

% Tolerância para encontrar frequências próximas
% Exemplo: aceita 635 Hz como equivalente prático de 630 Hz
tolerancia_relativa = 0.02; % 2%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 01 Cálculo do SAA - Sound Absorption Average
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Bandas de 1/3 de oitava usadas no SAA pela ASTM C423
freq_SAA = [200; 250; 315; 400; 500; 630; ...
            800; 1000; 1250; 1600; 2000; 2500];

alpha_SAA = nan(size(freq_SAA));
freq_SAA_encontradas = nan(size(freq_SAA));

for i = 1:length(freq_SAA)

    f_alvo = freq_SAA(i);

    [erro_freq, idx] = min(abs(freq - f_alvo));

    if erro_freq <= tolerancia_relativa*f_alvo
        alpha_SAA(i) = alpha_s(idx);
        freq_SAA_encontradas(i) = freq(idx);
    end

end

% Verificar se faltou alguma banda obrigatória
if any(isnan(alpha_SAA))
    disp(table(freq_SAA, freq_SAA_encontradas, alpha_SAA))
    error('Faltam bandas necessárias para calcular o SAA pela ASTM C423.')
end

% A ASTM pede arredondamento dos coeficientes para 0,01 antes da média
alpha_SAA_arred = arredonda_para_passo(alpha_SAA, 0.01);

% Média e arredondamento final do SAA para 0,01
SAA_bruto = mean(alpha_SAA_arred);
SAA = arredonda_para_passo(SAA_bruto, 0.01);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 02 Cálculo do NRC - Noise Reduction Coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Bandas usadas no NRC
freq_NRC = [250; 500; 1000; 2000];

alpha_NRC = nan(size(freq_NRC));
freq_NRC_encontradas = nan(size(freq_NRC));

for i = 1:length(freq_NRC)

    f_alvo = freq_NRC(i);

    [erro_freq, idx] = min(abs(freq - f_alvo));

    if erro_freq <= tolerancia_relativa*f_alvo
        alpha_NRC(i) = alpha_s(idx);
        freq_NRC_encontradas(i) = freq(idx);
    end

end

% Verificar se faltou alguma banda obrigatória
if any(isnan(alpha_NRC))
    disp(table(freq_NRC, freq_NRC_encontradas, alpha_NRC))
    error('Faltam bandas necessárias para calcular o NRC pela ASTM C423.')
end

% Média e arredondamento para o múltiplo mais próximo de 0,05
NRC_bruto = mean(alpha_NRC);
NRC = arredonda_para_passo(NRC_bruto, 0.05);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 03 Tabelas auxiliares
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tabela_SAA = table( ...
    freq_SAA, ...
    freq_SAA_encontradas, ...
    alpha_SAA, ...
    alpha_SAA_arred, ...
    'VariableNames', {'Frequencia_nominal_Hz', ...
                      'Frequencia_encontrada_Hz', ...
                      'alpha_s', ...
                      'alpha_s_arredondado_0_01'} ...
);

Tabela_NRC = table( ...
    freq_NRC, ...
    freq_NRC_encontradas, ...
    alpha_NRC, ...
    'VariableNames', {'Frequencia_nominal_Hz', ...
                      'Frequencia_encontrada_Hz', ...
                      'alpha_s'} ...
);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 04 Texto final
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

texto_resultado = sprintf('ASTM C423: SAA = %.2f; NRC = %.2f', SAA, NRC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 05 Guardar saídas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resultado.SAA = SAA;
resultado.SAA_bruto = SAA_bruto;
resultado.NRC = NRC;
resultado.NRC_bruto = NRC_bruto;

resultado.freq_SAA = freq_SAA;
resultado.freq_SAA_encontradas = freq_SAA_encontradas;
resultado.alpha_SAA = alpha_SAA;
resultado.alpha_SAA_arred = alpha_SAA_arred;

resultado.freq_NRC = freq_NRC;
resultado.freq_NRC_encontradas = freq_NRC_encontradas;
resultado.alpha_NRC = alpha_NRC;

resultado.Tabela_SAA = Tabela_SAA;
resultado.Tabela_NRC = Tabela_NRC;
resultado.texto_resultado = texto_resultado;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função auxiliar para arredondar para passos específicos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = arredonda_para_passo(x, passo)
% Arredonda x para o múltiplo mais próximo de "passo".
% Em caso de ponto médio, arredonda para cima.

y = floor(x./passo + 0.5).*passo;

end