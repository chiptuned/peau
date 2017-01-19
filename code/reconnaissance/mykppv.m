function [Class mat_dist]=mykppv(BaseKppv, Label, BaseTest, k, opt);
%data
% KPPV
%
% SYNTAXE :
%
% Class = kppv(BaseKppv ,Label, BaseTest, k [, opt])
%
% Classification par la méthode des K-ppv  
%
% ARGUMENTS :
%
% BaseKppv	: matrice des formes labellisées
% Label 		: vecteur colonne des labels de la base (valeurs strictement positives)
% BaseTest 	: matrice des formes à classer
% k      	: le 'k' des K-ppv
% opt    	: [optionnel] = 'reject'
%				  'reject' : classification avec rejet éventuel
%
%         
% VALEURS DE RETOUR :
%
% Class  : vecteur ligne des labels affectés aux échantillons de la base <BaseTest>.
%          Un label à 0 signifie un rejet de l'exemple par l'algorithme.
%
%
% DESCRIPTION :
% 
% KPPV effectue une classification des échantillons
% de <BaseTest> en utilisant la base <BaseKppv>, labellisée par
% <Label>. Pour k=1 (1-ppv), lorsque plusieurs voisins sont 
% trouvés à égale distance de l'échantillons courant à classer,
% la classe affectée est celle du premier voisin trouvé dans l'ordre de 
% leur rangement dans la base. Si l'option OPT='reject' est donnée,
% il y a rejet : le label retourné est 0.
% Le même raisonnement vaut pour k>1 : il y a rejet si parmi les 
% classes les plus représentées, plusieurs le sont un même 
% nombre de fois.
%


% Maurice Milgram - LIS/P&C UPMC
% Création : < 1996
% Version 1.4
% Derniere révision : 
%  - B. Gas (décembre 1999) : optimisation
%  - B. Gas (octobre 2000) : rejet 
%  - B. Gas (27/10/2000) : bug dans les errordlg et <Label> vect. ligne
%  - B. gas (4/2/2001) : mise à jour tbx RdF

if nargin < 4 | nargin > 5,
   error('[KPPV] usage: Class=kppv(BaseKppv, Label, BaseTest, k [, opt])');  
elseif nargin==4
   reject = 0;
elseif opt=='reject'
   reject = 1;
else
   error('[KPPV] erreur d''usage pour l''argument <opt> : opt={''reject''}');
end;
 
% Controle des arguments 
[KppvExSize KppvExNbr] = size(BaseKppv);
[TestExSize TestExNbr] = size(BaseTest);
[ans LabelNbr] = size(Label);

if ans~=1
   error('[KPPV] erreur : L''argument <Label> devrait être un vecteur ligne');
end;

if LabelNbr~=KppvExNbr 
   error('[KPPV] erreur : Dimensions non concordantes : <BaseKppv> et <Label> ');
end;

if KppvExSize~=TestExSize
   error('[KPPV] erreur : Les échantillons de <BaseKppv> et <BaseTest> n''ont pas même dimension');   
end;   

Class = zeros(1,TestExNbr);

mat_dist = [];

%1-ppv sans rejet : 
if k==1 & reject==0   
   for ex=1:TestExNbr   	   
      dist = BaseKppv - BaseTest(:,ex)*ones(1,KppvExNbr);   
      dist = sum(dist.^2);
      mat_dist = [mat_dist; dist ];
      size(mat_dist);
      [ans ind] = min(dist);
      Class(1,ex) = Label(ind);
   end;   
   
%1-ppv avec rejet : 
elseif k==1 & reject==1
   for ex=1:TestExNbr   	   
      dist = BaseKppv - BaseTest(:,ex)*ones(1,KppvExNbr);   
      dist = sum(dist.^2);
      [val ind] = min(dist);
      if sum(dist==val)>1  % rejet
	      Class(1,ex) = 0;
      else                  
         Class(1,ex) = Label(ind);
      end;      
   end;      
   
%K-ppv sans rejet :   
elseif reject==0   
   for ex=1:TestExNbr   	   
      dist = BaseKppv - BaseTest(:,ex)*ones(1,KppvExNbr);   
      dist = sum(dist.^2);			% distances aux échantillons
      [val ind] = sort(dist);		% ordonnancement croissant des distances
      lab = Label(ind(1:k));		% labels des K plus petites distances
      minlab = min(lab);			% histogramme des K labels
      [h ans] = hist(lab-minlab+1,1:max(lab)-minlab+1);
      [hmax label] = max(h);		% on garde le label le plus représenté  
      Class(1,ex) = label+minlab-1; 		
   end;      
   
%K-ppv avec rejet :   
else
   for ex=1:TestExNbr   	   
      dist = BaseKppv - BaseTest(:,ex)*ones(1,KppvExNbr);   
      dist = sum(dist.^2);			% distances aux échantillons
      [val ind] = sort(dist);		% ordonnancement croissant des distances
      lab = Label(ind(1:k));		% labels des K plus petites distances
      minlab = min(lab);			% histogramme des K labels
      [h ans] = hist(lab-minlab+1,1:max(lab)-minlab+1);
      [hmax label] = max(h);		% on garde le label le plus représenté  
      if sum(h==hmax)>1  			% s'il n'est pas unique : rejet
	      Class(1,ex) = 0;
      else                  
         Class(1,ex) = label+minlab-1;
      end;       		
   end;         
end;




