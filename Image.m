classdef Image < handle
    %IMAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        
        image_intensite, % matrice qui contient toutes les intensit�  des pixels de la matrice
        image_mask, % Matrice qui contient un mask binaire 
        coinhaut, % coin qui contient les coordon�es xmin, ymin de l'image
        coinbas,  % coin qui contient les coordon�es xmax, ymax de l'image
        profondeur, % pronfondeur de l'image pour faire fonctionner si l'image est en noir te blanc
        X1, % Correspond au 4 coordonn�es de X pris avec Ginput
        Y1; % Correspond au 4 coordonn�es de Y pris avec Ginput
       
    end
    
    methods
        
        %% COnstructeur

        
        function obj = Image(image)
        % Fonction de cr�ation de l'image est appel� a la cr�ation de
        % l'objet
        
            obj.image_intensite = double(imread(image));                    % creation de la matrice qui contient les intensit�s
            
            [hauteur,largeur, obj.profondeur] = size(obj.image_intensite);  % r�cup�rations des grandeurs utiles de l'image
            
            obj.coinhaut = [1,1];                                              % [y,x] cr�ation des coins de l'image
            obj.coinbas = [hauteur,largeur];
            
            % cr�ation des dimensions
            
            obj.image_mask = ones(hauteur,largeur,obj.profondeur).*1;             % cr�ation d'un mask qui est initialis� a 1 enti�rement
            figure, imshow(image);                                                  % affichage l'image
            [obj.X1,obj.Y1] = ginput(4);                                            % r�cup�rations des coordon�es avec Ginput
        end
        
        %% Methodes
        function obj = Homography(obj,H)
            % Fonction qui permet de calculer la transform� d'une image
            % dans une nouvelle base
            
            
            hauteur = obj.coinbas(1)-obj.coinhaut(1)+1; %Calcule des largeur et hauteur pour  obtenir les autres  coordon�es des coins de l'iamge
            largeur = obj.coinbas(2)-obj.coinhaut(2)+1;
            
            
            X = [1 obj.coinbas(2) obj.coinbas(2) 1]; % Coordonn�es de de les coins de l'image
            Y = [1 1 obj.coinbas(1) obj.coinbas(1)];
            s = 1;
            
            %%%%%%%%%%%%%%Calcule des positions extreme dans le "plan/base"
            %%%%%%%%%%%%%%de l'image dans laquelle on veux projet�%%%%%%%
            
            for i = 1:size(X,2)
                v1 = [X(i); Y(i);s];
                v2 = H\v1;
                v3 = round(v2/v2(3,1));
                X(i) = v3(1,1);     % on remplace les valeurs par les nouvelles calcul�
                Y(i) = v3(2,1);
            end

            %%%%%%%%%%%%%%%% on r�cup�re les min et max pour obtenir la dimension de la nouvelle image
            x_homography_max = max(X); 
            y_homography_max = max(Y);
            x_homography_min = min(X);
            y_homography_min = min(Y);
                        
            x_largeur = x_homography_max-x_homography_min+1; %calcule des valeurs de largeur et de hauteur de li'mage 
            y_hauteur = y_homography_max-y_homography_min+1; % a voir pourquoi oj rajoute pas de 1
            
            
            %%%%%%%%% Cr�ation des nouvelles variable pour la nouvelle 
            image_homography = zeros(y_hauteur,x_largeur,obj.profondeur);
            image_homography_mask = zeros(y_hauteur,x_largeur,obj.profondeur); % mise a 0 de tout les pixels du mask
            
            
            
            %%%%%%%%% Parcour de l'image d'arriver
            for y = 1:y_hauteur                                         % voir si on ne peux pas faire de calcules matricielles a la place
                for x = 1:x_largeur

                    v1 = [x+x_homography_min;y+y_homography_min;s]; % cr�ation avec le d�calage des coordonn�es a parcourir dans l'autre image cad coordon�es g�ographique
                    v2 = H*v1;
                    v3 = round(v2/v2(3,1));
                    %%%%
                    %%%% il semble y avoir une inversion sur les coordon�es
                    %%%% je ne comprend pas pk a voir
                    if ((( 1 <= v3(2,1)) && (v3(2,1)<= hauteur)) && ((( 1 <= v3(1,1)) && (v3(1,1)<= largeur)))) % V�rification pour voir si les coordonn�es d'arriver sont dans l'image de d�part 
                        v3(2,1);
                        image_homography(y,x,:) = obj.image_intensite(v3(2,1),v3(1,1),:); % recopie des pixels necessaires
                        image_homography_mask(y,x,:) = 1; % on met en blanc tout les pixels de l'image a mettre en binaire en vrai pour faire des op�rations logique
                
                    end
                end
            end
            
            %%%%%%% Recopie des  nouvelles informations dans l'obj de
            %%%%%%% l'image
            obj.image_intensite =  image_homography;
            obj.image_mask = image_homography_mask;
      
            obj.coinhaut = [y_homography_min,x_homography_min];
            obj.coinbas = [y_homography_max,x_homography_max];
            
        end
        

   
        
        function obj = fusion(obj,image_a_fus)
         
        % R�cup�ration de la nouvelle boite
        
        % Calculede la taille de la boite 
      
         coin = nv1boite(obj.coinhaut,obj.coinbas,image_a_fus.coinhaut,image_a_fus.coinbas);
         coinhautfus = [coin(1) coin(2)];
         coinbasfus = [coin(3) coin(4)];

         % Calcule de la largeur de l'image global
         
%          largeur_fus = abs(coinhautfus(2))+abs(coinbasfus(2)) + 1
%          hauteur_fus = abs(coinhautfus(1))+abs(coinbasfus(1)) + 1
         
         largeur_fus = coinbasfus(2)-coinhautfus(2) + 1;
         hauteur_fus = coinbasfus(1)-coinhautfus(1) + 1;
%          
         
         %Creation des varaibles d'image pour la fusion
         
         image_intensite_fus = zeros(hauteur_fus,largeur_fus,obj.profondeur);
         %taille_image1 = size( image_intensite_fus)
         image_mask_fus = zeros(hauteur_fus,largeur_fus,obj.profondeur);
        
               
         ymin = (obj.coinhaut(1)-coin(1,1))+1;
         ymax = (obj.coinbas(1)-coin(1,1))+1;
         xmin = (obj.coinhaut(2) -coin(1,2))+1;
         xmax = (obj.coinbas(2) -coin(1,2))+1;
         
         
         %Calcule des coordon�es d�cales pour l'image en param�tre de la
         %fusion

         
         ymin_image_a_fus = (image_a_fus.coinhaut(1)-coin(1,1))+1;
         ymax_image_a_fus = (image_a_fus.coinbas(1)-coin(1,1))+1;
         xmin_image_a_fus = (image_a_fus.coinhaut(2)-coin(1,2))+1;
         xmax_image_a_fus = (image_a_fus.coinbas(2)-coin(1,2))+1;
        
         
         
         % Affectation et fusion de images dans l'image final
         
         %image mask
         %image_mask_fus(ymin:ymax,xmin:xmax,:) = obj.image_mask + image_mask_fus(ymin:ymax,xmin:xmax,:); %% il faut comprendre pourquoi on ne doit pas d�caler de 1 sur es ymax et xmax ???
         image_mask_fus(ymin_image_a_fus:ymax_image_a_fus,xmin_image_a_fus:xmax_image_a_fus,:) = image_a_fus.image_mask + image_mask_fus(ymin_image_a_fus:ymax_image_a_fus,xmin_image_a_fus:xmax_image_a_fus,:); % 
         image_mask_fus(ymin:ymax,xmin:xmax,:) = obj.image_mask + image_mask_fus(ymin:ymax,xmin:xmax,:); %% il faut comprendre pourquoi on ne doit pas d�caler de 1 sur es ymax et xmax ???
         %image intensit�
         image_intensite_fus(ymin:ymax,xmin:xmax,:) = obj.image_intensite + image_intensite_fus(ymin:ymax,xmin:xmax,:);
         image_intensite_fus(ymin_image_a_fus:ymax_image_a_fus,xmin_image_a_fus:xmax_image_a_fus,:) = image_a_fus.image_intensite + image_intensite_fus(ymin_image_a_fus:ymax_image_a_fus,xmin_image_a_fus:xmax_image_a_fus,:);
        
         
         
%          image_mask_fus(image_mask_fus==0) = -1; % on passe les valeurs nul en n�gative pour la division par le mask
%          
%          image_intensite_fus = image_intensite_fus./image_mask_fus; % On divise chaque valeur de l'image par le mask 
%          
%          image_intensite_fus = abs(image_intensite_fus); % on repasse toutes les valeurs n�gative du masque � 0
%          %taille_image2 = size( image_intensite_fus) 
%           % on repasse toutes les valeurs du mask a 1 pour une prochaine fusion
%          image_mask_fus(image_mask_fus<0) = 0;
         
         image_intensite_fus = image_intensite_fus./( image_mask_fus+ (image_mask_fus==0) ); %remplacement de l'op�ration pr�d�dente par ce calcule
         image_mask_fus(image_mask_fus>0) = 1;
         
         
         %Reacfectation des variables de l'objet 
         obj.image_mask = image_mask_fus;
         obj.image_intensite = image_intensite_fus;
         
         obj.coinhaut = coinhautfus;
         obj.coinbas = coinbasfus;
        end
               
        function affichage(obj)
        % Fonction qui permet de faire l'affiche d'une image
        
            figure, imshow(uint8(obj.image_mask)); %% on affiche l'image
            figure, imshow(uint8(obj.image_intensite));
        end
        
        
        
        %% Getter et setters
        
        % method qui permet de reprendre de nouveaux points
        
        function obj = getnewginput(obj)
            figure, imshow(uint8(obj.image_intensite)); %% on affiche l'image
            [obj.X1,obj.Y1] = ginput(4);
        
        end
        function obj = modifmask(obj)
           obj.image_mask(obj.image_mask>0) = 255;
            
        end
        
        
        
        function obj = setimage_intensite(obj,image_intensite)
            obj.image_intensite =image_intensite;
        end
        
        function er = getimage_intensite(obj)
            er = obj.image_intensite;
        end
        
        function obj = setimage_mask(obj,image_mask)
            obj.image_mask = image_mask;
        end
        
        function er = getimage_mask(obj)
            er = obj.image_mask;
        end
        
        function obj = setlargeur(obj,largeur)
            obj.image_intensite = largeur;
        end
        

        
        function obj = sethauteur(obj,hauteur)
            obj.image_intensite = hauteur;
        end
        

        function obj = setprofondeur(obj,profondeur)
            obj.image_intensite = profondeur;
        end
        
        function er = getprofondeur(obj)
            er = obj.profondeur;
        end
                function obj = setCoord(obj,coord1, coord2)
            obj.X1 = coord1;
            obj.Y1  = coord2;
        end
        
        function er = getCoordx(obj)
            er = obj.X1;
        end
        
        function er = getCoordy(obj)
            er = obj.Y1;
        end
    end
    
    

end

   function coin = nv1boite(coinhaut1,coinhaut2,coinbas1,coinbas2)
        % Fonction qui permet de determin� les coins de la boite englobante
        % pour une fusion
            ymax = max([coinhaut1(1) coinhaut2(1) coinbas1(1) coinbas2(1)]);
            ymin = min([coinhaut1(1) coinhaut2(1) coinbas1(1) coinbas2(1)]);
            
            xmax = max([coinhaut1(2) coinhaut2(2) coinbas1(2) coinbas2(2)]);
            xmin = min([coinhaut1(2) coinhaut2(2) coinbas1(2) coinbas2(2)]);

            
            coin = [ymin xmin ymax xmax];
                 
        end
        
