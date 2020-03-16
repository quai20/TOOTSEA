 function indice_final =  traitement_madcp(base_temps,east,err,vert,icel,serr,sver)
%
% debut de traitement de la cellule icel 
	%fprintf(1,'traitement cellule %6.0f \n', icel)
%
	[maxdata maxcel] = size(east);
% quelques statistiques
% 	kk = find( isnan(east(:,icel)) );
% 	nbr_point_bad_initial=size(kk,1);
% 	fprintf(1, 'Nombre de points dans la serie :  %10.0f \n', maxdata);
% 	fprintf(1, 'Nombre de points errones       :  %10.0f \n', size(kk,1));

% statistiques sur les donnees manquantes
% ---------------------------------------
% 	kk = find(isnan(east(:,icel)) );
% 	size_trou_en_cours = 1; size_trou = NaN;
% 	nbr_trou = 0;
% 
% 	for i=1:size(kk,1)-1;
% 		if ( kk(i+1) == kk(i)+1);
% 			size_trou_en_cours = size_trou_en_cours + 1;
% 		else
% 			size_trou = [size_trou size_trou_en_cours];
% 			size_trou_en_cours = 1;
% 			nbr_trou = nbr_trou + 1;
% 		end
% 	end
% 	fprintf(1,'nombre de trous avant seuillages %8.0f \n', nbr_trou);
% 	N = hist(size_trou,1:1:50);
% 	figure;
% 	bar(N);
% 	hold on;
% 	title('histogramme des trous dans la serie avant seuillages')

% seuillage en erreur velocity et vitesse verticale
	seuil_err = serr;
	seuil_vert = sver;
    
	east_seuil=east(:,icel);  vert_seuil=vert(:,icel); err_seuil=err(:,icel);
	kk = find( (~isnan(east(:,icel))) & ( (abs(err(:,icel)) >= seuil_err)...
		 | (abs(vert(:,icel)) >= seuil_vert)) );
	east_seuil(kk)=NaN; nord_seuil(kk)=NaN; vert_seuil(kk)=NaN; err_seuil(kk)=NaN;
	kk = find( isnan(east_seuil) );
% 	fprintf(1, 'Nombre de points errones avant seuillages :  %10.0f \n',nbr_point_bad_initial);
% 	fprintf(1, 'Nombre de points errones apres seuillages :  %10.0f \n', size(kk,1));

% seuillage par comparaison avec la valeur mediane 
	k_median = 2 * 12 + 1; 
	east_seuil_median = east_seuil;
	for I = 1:1:maxdata - k_median
		interm = east_seuil(I:I+k_median);
		jj = find(~isnan(interm));
		I_center = I + (k_median-1)/2;
		if ~isempty(jj)
			east_median = median(interm(jj));
			east_std    = mean(abs( interm(jj) - (ones(size(jj,1),1)*east_median)) );
			if(abs(east_seuil(I_center)- (ones(k_median+1,1)*east_median)) >= 2.3 * east_std);
				east_seuil_median(I_center) = NaN; 
            end
        end
    end
	kk = find( isnan(east_seuil_median) );
% 	fprintf(1, 'Nombre de points errones apres seuillages median :  %10.0f \n', size(kk,1));


% generation d'une serie avec moyenne glissante et reechantillonnage
% ------------------------------------------------------------------

%	k_run_mean = 4;
%	east_runmean = running_mean(east_seuil_median,k_run_mean);
%	east_runmean_resample = east_runmean(1:k_run_mean:maxdata);
%	base_temps_resample = base_temps(1:k_run_mean:maxdata) + (7.5 * 60 / 86400);
    


% statistiques sur les donnees manquantes
% ---------------------------------------

% 	kk = find(isnan(east_runmean_resample));
% 	size_trou_en_cours = 1; size_trou = NaN;
% 	nbr_trou = 0;
% 
% 	for i=1:size(kk,1)-1;
% 
% 		if ( kk(i+1) == kk(i)+1);
% 
% 			size_trou_en_cours = size_trou_en_cours + 1;
% 
% 		else
% 
% 			size_trou = [size_trou size_trou_en_cours];
% 			size_trou_en_cours = 1;
% 			nbr_trou = nbr_trou + 1;
% 
% 		end
% 
% 	end
% 
% 	fprintf(1,'nombre de trous %8.0f \n', nbr_trou);
% 
% 	N = hist(size_trou,1:1:50);
% 	figure;
% 	bar(N);
% 	hold on;
% 	titre = ['MADCP NORD ' U ' cellule = ' int2str(icel) ' seuil err = ' num2str(seuil_err) ' seuil vert = ' num2str(seuil_vert) ' k run mean = ' int2str(k_run_mean)];
% 	title( titre );
% 
% 	filename = ['MADCP-nord-trous-' U '-cel-' int2str(icel)];
% 	eval(['print -deps ' filename]);
% 
% % bouchage de trous par interpolation lineaire pour un trou maximum de 1
% % ----------------------------------------------------------------------
% 
% 	east_runmean_interp1 = east_runmean_resample;
% 	kk = find(isnan(east_runmean_interp1));
% 
% 	nbr_trou_bouche = 0;
% 
% 	for i=2:size(kk,1)-1;
% 
% 		if ( kk(i+1) ~= kk(i)+1)  &  (kk(i-1) ~= kk(i)-1);
% 
% 			east_runmean_interp1(kk(i)) =  ...
% 					(east_runmean_resample(kk(i)-1) + east_runmean_resample(kk(i)+1))/2;
% 
% 			nbr_trou_bouche = nbr_trou_bouche + 1;
% 
% 		end
% 
% 	end
% 
% 	fprintf(1,'nombre de trous bouches %8.0f \n', nbr_trou_bouche);



% visualisations
% --------------

	jour_ref = 1;
	nbr_jour = 395;

	debut = 1; %(jour_ref - 1)  * 4 * 24 + 1;  	
%	debut_resample = 1; 
%    if debut ~= 1; 
%        debut_resample = fix(debut / k_run_mean); 
%    end;
	fin   = length(base_temps);%(jour_ref + nbr_jour - 1) * 4 * 24; 
%    fin_resample = fix(fin / k_run_mean) ;


% 	JJ=find( isnan(east_runmean_resample(debut_resample:fin_resample)) & ...
% 			~isnan(east_runmean_interp1(debut_resample:fin_resample)) );

	indice_seuil = find( ~isnan(east(debut:fin,icel)) & isnan(east_seuil(debut:fin)));
	indice_seuil = indice_seuil + debut - 1;

	indice_seuil_median = ...
			find( ~isnan(east_seuil(debut:fin)) & isnan(east_seuil_median(debut:fin)));
	indice_seuil_median = indice_seuil_median + debut - 1;
    
    indice_final=sort([indice_seuil(:)' indice_seuil_median(:)']);

% figure;
% 	plot(base_temps(debut:fin),east(debut:fin,icel),'k.');
% 	hold on;
% 
% 	if ~isempty(indice_seuil);
% 	plot(base_temps(indice_seuil),east(indice_seuil,icel),'b+','markersize',6);
% 	hold on;
% 	end
% 
% 	if ~isempty(indice_seuil_median);
% 	plot(base_temps(indice_seuil_median),east(indice_seuil_median,icel),'r+','markersize',6);
% 	hold on;
% 	end
% 
% %	plot(base_temps_resample(debut_resample:fin_resample),...
% %			east_runmean_resample(debut_resample:fin_resample),'r');
% %	hold on;
% 
% % 	if ~isempty(JJ)
% % 	plot(base_temps_resample(JJ),east_runmean_interp1(JJ),'g.','markersize',6);
% % 	hold on;
% % 	end
% 
% 	%titre = ['MADCP NORD ' U ' cellule = ' int2str(icel) ' seuil err = ' num2str(seuil_err) ' seuil vert = ' num2str(seuil_vert) ' k run mean = ' int2str(k_run_mean)];
%     titre = ['cellule = ' int2str(icel) ' seuil err = ' num2str(seuil_err) ' seuil vert = ' num2str(seuil_vert)];
% 	title( titre );
% 	hold on;

%	orient landscape;
%	filename = ['MADCP-nord-validation-' U '-cel-' int2str(icel)];
%	eval(['print -depsc ' filename]);

% figure;
% 
% 	plot(base_temps(debut:fin),east(debut:fin,icel),'k.');
% 	hold on;
% 
% 	plot(base_temps_resample,east_runmean_interp1,'r');
% 	hold on;
% 
% 	titre = ['MADCP NORD ' U ' cellule = ' int2str(icel) ' seuil err = ' num2str(seuil_err) ' seuil vert = ' num2str(seuil_vert) ' k run mean = ' int2str(k_run_mean)];
% 	title( titre );
% 	hold on;
% 
% 	orient landscape;
% 	filename = ['MADCP-nord-valide-' U '-cel-' int2str(icel)];
% 	eval(['print -depsc ' filename]);

