%% Inicializacion del Programa

%Abrimos el explorador de archivos
[file,path] = uigetfile({'*.mp3;*.wav','Audio Files (*.mp3;*.wav)';'*.*','All Files (*.*)'},...
    'Select a Audio File',...
    'C:\Users\emili\OneDrive\Documents\GitHub\Proyecto_PS\Audio_Prueba_2.wav');

if isequal(file,0)
   disp('User selected Cancel');
else
   Full_Path = fullfile(path,file);
   disp(['User selected ', Full_Path]);
end

%Convertimos el archivo a una matriz en Matlab
[Audio_lines, Fs] = audioread(Full_Path);
player = audioplayer(Audio_lines, Fs);
%play(player);

%Separamos en lineas la matriz del audio abierto
line_1 = Audio_lines(:,1);
line_2 = Audio_lines(:,2);

%% FILTRO BPF IIR

%VARIABLES FILTRO BPF IIR / PAGINA 273
BPF1_Fc = 500;
BPF1_K = tan((pi*BPF1_Fc)/Fs);
BPF1_Q = 0.2;
BPF1_delta = ((BPF1_K^2)*BPF1_Q)+BPF1_K+BPF1_Q;
BPF1_A0 = BPF1_K/BPF1_delta;
BPF1_A1 = 0;
BPF1_A2 = -BPF1_K/BPF1_delta;
BPF1_B1 = (2*BPF1_Q*((BPF1_K^2)-1))/BPF1_delta;
BPF1_B2 = (((BPF1_K^2)*BPF1_Q)-BPF1_K+BPF1_Q)/BPF1_delta;
BPF1_C0 = 1.0;
BPF1_D0 = 0.0;

%ECUACION DE DIFERENCIA / PAGINA 270
[size_m,size_n] = size(line_1); %Encontramos el tamaño de la columna de la matriz de la linea
for n=1:size_m
    if n == 1
        y1(n,:)= BPF1_D0*line_1(n)+BPF1_C0*(BPF1_A0*line_1(n));
    elseif n == 2
        y1(n,:)= BPF1_D0*line_1(n)+BPF1_C0*((BPF1_A0*line_1(n))+(BPF1_A1*line_1(n-1))-(BPF1_B1*y1(n-1)));
    else
        y1(n,:)= BPF1_D0*line_1(n)+BPF1_C0*((BPF1_A0*line_1(n))+(BPF1_A1*line_1(n-1))+(BPF1_A2*line_1(n-2))-(BPF1_B1*y1(n-1))-(BPF1_B2*y1(n-2)));
    end
end

soundsc(y1,Fs)

%% REVERB / PAGINA 464 - 17.3

%VARIABLES REVERB
Reverb_DelayRequerido = 0.5; %Esto esta en SEGUNDOS 
Reverb_G = 0.92;

%ECUACION DE DIFERENCIA / 464 - 17.3
TotalTime = length(line_1)./Fs; %Encontramos la duracion total del archivo abierto
[Reverb_size_m,size_n] = size(line_1); %Encontramos el tamaño de la columna dentro matriz de la linea
Reverb_D = (Reverb_size_m*Reverb_DelayRequerido)/TotalTime; %Convertimos el delay requerido de segundos a Samples
Reverb_x_D = 0;
Reverb_y_D = 0;

for n=1:Reverb_size_m
    if n>Reverb_D % 𝑥[𝑘] = 0 si 𝑘 < 0.
       Reverb_x_D = y1(n-Reverb_D);
       Reverb_y_D = Reverb_G*y1(n-Reverb_D);
    end
    y2(n,:)= Reverb_x_D + Reverb_y_D;    
end

soundsc(y2,Fs)

%% DELAY

%VARIABLES DELAY / PAGINA 391 - 14.2
Delay_DelayRequerido = 0.5; %Esto esta en SEGUNDOS 

%ECUACION DE DIFERENCIA / PAGINA 391 - 14.2
TotalTime = length(line_1)./Fs; %Encontramos la duracion total del archivo abierto
[Delay_size_m,size_n] = size(line_1); %Encontramos el tamaño de la columna dentro matriz de la linea
Delay_D = (Delay_size_m*Delay_DelayRequerido)/TotalTime; %Convertimos el delay requerido de segundos a Samples
Delay_x_D = 0;

for n=1:Delay_size_m
    if n>Delay_D % 𝑥[𝑘] = 0 si 𝑘 < 0.
       Delay_x_D = y1(n-Delay_D);
    end
    y3(n,:)= y1(n)+Delay_x_D;    
end

soundsc(y3,Fs)


