function QC_out = seafloor_detection_qualif(DATA,ABSIC)
  % copy QC
  QC_out=DATA.QC_Serie;
  % diff : REFERENCE SHOULD BE ONE OF ABSIC 
  dABSIC = diff(ABSIC.Data,1,1);
  % max of diff within predefined interval
  [argvalue, argmax] = max(dABSIC,[],1);
  for i=1:length(argmax)
    if((ABSIC.Depth(argmax(i))<-300)&&(ABSIC.Depth(argmax(i))>-400))
      ath=argmax(i);
    else
      ath=round(mean(argmax));
    end
    QC_out(ath:end,i) = 4;	
  end  	
end

