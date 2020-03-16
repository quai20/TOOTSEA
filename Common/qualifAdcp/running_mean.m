function [east_mean] = running_mean(east,kk)

% applique une moyenne courante a east;
% kk est le nombre de points utilises; 
% la nouvelle serie sera decentre de delta_T si kk est paire;

	
	east_mean = east;

	maxdata = size(east);

	if fix(kk/2) == kk/2

		k = kk/2;

		for I = k:maxdata-k;
			
			interm = east(I-k+1:I+k);
			jj = find(~isnan(interm));

			if ( isempty(jj) | size(jj,1) <= k)

				east_mean(I) = NaN;

			else

				east_mean(I) = mean(interm(jj));

			end

		end 



	else

		k = (kk-1)/2;

		for I = k+1:maxdata-k;

			interm = east(I-k:I+k)
			jj = find(~isnan(interm));

			if (isempty(jj) | size(jj,1) <= k)

				east_mean(I) = NaN;

			else

				east_mean(I) = mean(interm(jj));

			end;

		end;

	end;

	clear maxdata; clear interm; clear jj; clear k;
