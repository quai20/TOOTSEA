function VELF = tide_filter_LM(UCUR,VCUR,WCUR,Nfd)
% Filtrage de la maree avec chebychev 
% Credit : Louis Marie
% Tweaked for TOOTSEA : K.BALEM 2017
% INPUT :   UCUR, VCUR, WCUR arrays
%           Ndf : order for cheby
% OUTPUT :  VELF : containing filtered U,V,W arrays
%

% On prepare les filtres pour virer la maree.
[Bd , Ad]=cheby2(Nfd,20,2/pi*atan(cos(pi/2/Nfd)*tan(pi/2*(1/12.43)/(3/2))));  % Il y a un "pre-warping" des frequences e la noix dans cheby2...
[Bd2,Ad2]=cheby2(Nfd,20,2/pi*atan(cos(pi/2/Nfd)*tan(pi/2*(1/12   )/(3/2))));
liABd=max([length(Ad),length(Bd)])-1;

[ax ,ay ] = size(Ad);
[axb,ayb] = size(Ad2);

matA =full(spdiags(repmat(fliplr(Ad ),[ay 1]), -ay+1:0,ay ,ay ));
matB =full(spdiags(repmat(fliplr(Bd ),[ay 1]), -ay+1:0,ay ,ay ));
matA2=full(spdiags(repmat(fliplr(Ad2),[ay 1]),-ayb+1:0,ayb,ayb));
matB2=full(spdiags(repmat(fliplr(Bd2),[ay 1]),-ayb+1:0,ayb,ayb));

% On filtre la maree.
%Composante vers l'Est
D=UCUR';
%M2
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
%S2
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
D =flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
DE=flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));

%Composante vers le Nord
D=VCUR';
%M2
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
%S2
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
D =flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
DN=flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));

%Composante vers le haut
D=WCUR';
%M2
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA*repmat(m,[ay  1])-matB*D(1:ay ,1);Zi=Zi(1:liABd);
D=flipud(filter(Bd ,Ad ,D,Zi(1:liABd)));
%S2
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
D =flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));
m=mean(D(1:24*3));Zi=matA2*repmat(m,[ayb 1])-matB2*D(1:ayb,1);Zi=Zi(1:liABd);
DU=flipud(filter(Bd2,Ad2,D,Zi(1:liABd)));

VELF=[DE';DN';DU'];

end

