function resultado = classifica_ISO11654(freq, alpha_s)
% classifica_ISO11654
% Calcula alpha_p, alpha_w, indicadores de forma e classe de absorção
% conforme ISO 11654.
%
% Entradas:
% freq    = vetor de frequências em terços de oitava [Hz]
% alpha_s = vetor de coeficientes de absorção sonora medidos [-]
%
% Saída:
% resultado = estrutura com alpha_p, alpha_w, classe, indicadores e tabela

% Garantir vetores coluna
freq = freq(:);
alpha_s = alpha_s(:);

% Verificar tamanhos
if length(freq) ~= length(alpha_s)
    error('freq e alpha_s devem ter o mesmo número de elementos.')
end

% Bandas de oitava usadas na ISO 11654
freq_oct = [250; 500; 1000; 2000; 4000];

% Bandas de terço de oitava usadas para calcular cada alpha_p
bandas_terco = [
    200   250   315;
    400   500   630;
    800   1000  1250;
    1600  2000  2500;
    3150  4000  5000
];

% Tolerância para procurar frequências
% Útil caso o vetor tenha, por exemplo, 5011.9 em vez de 5000
tolerancia_relativa = 0.02; % 2%

% Matriz para guardar os alpha_s usados em cada banda de oitava
alpha_tercos_usados = nan(5,3);
freq_tercos_encontradas = nan(5,3);

for i = 1:5

    for j = 1:3

        f_alvo = bandas_terco(i,j);

        % Procurar frequência mais próxima
        [erro_freq, idx] = min(abs(freq - f_alvo));

        % Verificar se está dentro da tolerância
        if erro_freq <= tolerancia_relativa*f_alvo
            alpha_tercos_usados(i,j) = alpha_s(idx);
            freq_tercos_encontradas(i,j) = freq(idx);
        end

    end

end

% Verificar se alguma banda necessária ficou sem dado
if any(isnan(alpha_tercos_usados), 'all')
    warning('Algumas bandas necessárias para a ISO 11654 não foram encontradas. Verifique freq_tercos_encontradas.')
end

% Calcular alpha_p como média dos três terços de oitava
alpha_p_bruto = mean(alpha_tercos_usados, 2, 'omitnan');

% Verificar se todos os alpha_p foram calculados
if any(isnan(alpha_p_bruto))
    error('Não foi possível calcular todos os alpha_p. Faltam bandas de frequência necessárias.')
end

% Arredondar alpha_p para duas casas decimais
alpha_p_2dec = round(alpha_p_bruto*100)/100;

% Arredondar alpha_p para o múltiplo mais próximo de 0.05
alpha_p = round(alpha_p_2dec/0.05)*0.05;

% Limitar alpha_p ao máximo 1.00
alpha_p(alpha_p > 1.00) = 1.00;

% Curva de referência inicial da ISO 11654
% Frequências: 250, 500, 1000, 2000 e 4000 Hz
curva_ref_base = [0.80; 1.00; 1.00; 1.00; 0.90];

% Deslocar a curva de referência em passos de 0.05
deslocamentos = 0:-0.05:-1.00;

alpha_w = NaN;
curva_ref_final = nan(5,1);
soma_desvios_final = NaN;

for k = 1:length(deslocamentos)

    curva_ref = curva_ref_base + deslocamentos(k);

    % Evitar valores negativos na curva de referência
    curva_ref(curva_ref < 0) = 0;

    % Desvios desfavoráveis: quando alpha_p fica abaixo da curva
    desvios_desfavoraveis = curva_ref - alpha_p;
    desvios_desfavoraveis(desvios_desfavoraveis < 0) = 0;

    soma_desvios = sum(desvios_desfavoraveis);

    if soma_desvios <= 0.10
        curva_ref_final = curva_ref;
        alpha_w = curva_ref(2); % valor da curva ajustada em 500 Hz
        soma_desvios_final = soma_desvios;
        break
    end

end

% Garantir alpha_w entre 0 e 1
alpha_w = max(0, min(alpha_w, 1));

% Classificação de absorção sonora
if alpha_w >= 0.90
    classe_absorcao = 'A';
elseif alpha_w >= 0.80
    classe_absorcao = 'B';
elseif alpha_w >= 0.60
    classe_absorcao = 'C';
elseif alpha_w >= 0.30
    classe_absorcao = 'D';
elseif alpha_w >= 0.15
    classe_absorcao = 'E';
else
    classe_absorcao = 'Não classificado';
end

% Indicadores de forma L, M e H
excesso = alpha_p - curva_ref_final;

indicadores = "";

if excesso(1) >= 0.25
    indicadores = indicadores + "L";
end

if excesso(2) >= 0.25 || excesso(3) >= 0.25
    indicadores = indicadores + "M";
end

if excesso(4) >= 0.25 || excesso(5) >= 0.25
    indicadores = indicadores + "H";
end

% Texto final
if strlength(indicadores) > 0
    texto_resultado = sprintf('alpha_w = %.2f(%s), Classe %s', ...
        alpha_w, indicadores, classe_absorcao);
else
    texto_resultado = sprintf('alpha_w = %.2f, Classe %s', ...
        alpha_w, classe_absorcao);
end

% Tabela principal
Tabela_ISO11654 = table( ...
    freq_oct, ...
    alpha_p_bruto, ...
    alpha_p, ...
    curva_ref_final, ...
    excesso, ...
    'VariableNames', {'Frequencia_Hz', 'alpha_p_bruto', 'alpha_p', ...
                      'Curva_referencia_final', 'Excesso'} ...
);

% Guardar tudo na saída
resultado.freq_oct = freq_oct;
resultado.bandas_terco = bandas_terco;
resultado.freq_tercos_encontradas = freq_tercos_encontradas;
resultado.alpha_tercos_usados = alpha_tercos_usados;
resultado.alpha_p_bruto = alpha_p_bruto;
resultado.alpha_p = alpha_p;
resultado.curva_ref_base = curva_ref_base;
resultado.curva_ref_final = curva_ref_final;
resultado.alpha_w = alpha_w;
resultado.classe_absorcao = classe_absorcao;
resultado.indicadores = indicadores;
resultado.excesso = excesso;
resultado.soma_desvios_final = soma_desvios_final;
resultado.texto_resultado = texto_resultado;
resultado.Tabela_ISO11654 = Tabela_ISO11654;

end