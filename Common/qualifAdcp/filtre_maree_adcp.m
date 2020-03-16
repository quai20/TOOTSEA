load MADCP-nord-w-valide-C.mat

x = sqrt(east_valide.^2+nord_valide.^2);
s = x(198:end,:);
t = base_temps_valide(198:end);
xi = s;
y = s;

[b,a]=butter(2,[1/14 1/10]);
doc butter
for ii=1:30,
  isok = find(~isnan(s(:,ii)));
  fprintf('Cellule %i : %i NaN\n',[ii length(t)-length(isok)]);
  xi(:,ii)=interp1(t(isok),s(isok,ii),t);
  i1 = min(find(~isnan(xi(:,ii)))); 
  i2 = max(find(~isnan(xi(:,ii))));
  y(:,ii)=xi(:,ii) * NaN; 
  y(i1:i2,ii)=filtfilt(b,a,xi(i1:i2,ii));
end

plot(t,xi(:,4)-meanoutnan(xi(:,4)),'b.-',t,y(:,4),'r.-');
