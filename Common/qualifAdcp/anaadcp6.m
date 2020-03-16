%
% Routine MATLAB cree par H.Mercier
% analyse des donnees ADCP de mouillage a partir du fichier .mat cree par le soft RDI

% utilise les subroutines matlab traitement_madcp.m et running_mean.m
% tres long en machine (sur archaden) environ 6 heures.

% initialisations
% ---------------

	close all
	clear all

% lecture des donnees mouillage nord
% et reaffectation des variables
% ----------------------------------

	load p0n-adcp-brut.mat

	east = SerEmmpersec; clear SerEmmpersec;
	nord = SerNmmpersec; clear SerNmmpersec;
	vert = SerVmmpersec; clear SerVmmpersec;
	ampl = SerMagmmpersec; clear SerMagmmpersec;
	dire = SerDir10thDeg; clear SerDir10thDeg;
	err  = SerErmmpersec; clear SerErmmpersec;
	pgood4= SerPG4; clear SerPG4;
	pgood3= SerPG3; clear SerPG3;
	pgood2= SerPG2; clear SerPG2;
	pgood1= SerPG1; clear SerPG1;

% determination de la taille des matrices

	[maxdata maxcel] = size(east);

% detection des valeurs aberrentes -32568
% et remplacement par NaN
% ---------------------------------------

% affectation de la valeur erreur

	xignore = -32768;

% amplitude

	X = find(ampl == xignore);
	ampl(X) = NaN;

% composante east

	X = find(east == xignore);
	east(X) = NaN;


% composante nord

	X = find(nord == xignore);
	nord(X) = NaN;

% composante verticale

	X = find(vert == xignore);
	vert(X) = NaN;

% composante erreur

	X = find(err == xignore);
	err(X) = NaN;

	clear X


% generation d'une base de temps
% ------------------------------

	disp(' '); disp('generation d une base de temps approximative'); disp(' ');

	idata = 1:1:maxdata;
	mult  = 15 * 60 / 86400;
	base_temps = mult .* idata; clear idata; clear mult;

	base_temps = base_temps';


%
% Choix de la serie traitee
% -------------------------

% composante est


	icel = 1;
	[base_temps_valide east_valide_en_cours] = traitement_madcp(base_temps,east,err,vert,icel,'u');
	close all;

	east_valide = east_valide_en_cours;

	for icel=2:28

		[base_temps_valide east_valide_en_cours] = traitement_madcp(base_temps,east,err,vert,icel,'u');
		close all;
		east_valide = [east_valide east_valide_en_cours];

	end

	save MADCP-nord-u-valide  base_temps_valide east_valide;


% composante nord

	icel = 1;
	[base_temps_valide nord_valide_en_cours] = traitement_madcp(base_temps,nord,err,vert,icel,'v');
	close all;

	nord_valide = nord_valide_en_cours;

	for icel=2:28

		[base_temps_valide nord_valide_en_cours] = traitement_madcp(base_temps,nord,err,vert,icel,'v');
		close all;
		nord_valide = [nord_valide nord_valide_en_cours];

	end

	save MADCP-nord-v-valide  base_temps_valide nord_valide;


% homogeneisation des traitement sur composante Nord et composante est

	[kk,ll]  = find(isnan(east_valide));
	nord_valide(kk,ll)=NaN;
	[kk,ll]  = find(isnan(nord_valide));
	east_valide(kk,ll)=NaN;


% traitement de la composante verticale

	icel = 1;
	[base_temps_valide vert_valide_en_cours] = traitement_madcp(base_temps,vert,err,vert,icel,'w');
	close all;

	vert_valide = vert_valide_en_cours;

	for icel=2:28

		[base_temps_valide vert_valide_en_cours] = traitement_madcp(base_temps,vert,err,vert,icel,'w');
		close all;
		vert_valide = [vert_valide vert_valide_en_cours];

	end

	save MADCP-nord-w-valide  base_temps_valide vert_valide;

