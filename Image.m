classdef Image < handle
    %IMAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        
        image_intensite, % matrice qui contient toutes les intensité  des pixels de la matrice
        image_mask, % Matrice qui contient un mask binaire 
        coin1, % coin qui contient les coordonées xmin, ymin de l'image
        coin2,  % coin qui contient les coordonées xmax, ymax de l'image
        profondeur, % pronfondeur de l'image pour faire fonctionner si l'image est en noir te blanc
        X1, % Correspond au 4 coordonnées de X pris avec Ginput
        Y1, % Correspond au 4 coordonnées de Y pris avec Ginput
        
        Xliste, % listes qui contiennent les coordonnées de la matrice dans une autre base
        Yliste;
       
    end
    
    methods
        
        %% COnstructeur

        
        function obj = Image(image)
        % Fonction de création de l'image est appelé a la création de
        % l'objet
        
            obj.image_intensite = double(imread(image));                    % creation de la matrice qui contient les intensitï¿½s
            
            [hauteur,largeur, obj.profondeur] = size(obj.image_intensite);  % récupérations des grandeurs utiles de l'image
            
            obj.coin1 = [1,1];                                              % [y,x] création des coins de l'image
            obj.coin2 = [hauteur,largeur];
            
            % crï¿½ation des dimensions
            
            obj.image_mask = ones(hauteur,largeur,obj.profondeur).*255;             % crï¿½ation d'un mask qui est initialisï¿½ a 1 entiï¿½rement
            figure, imshow(image);                                                  % affichage l'image
            [obj.X1,obj.Y1] = ginput(4);                                            % récupérations des coordonées avec Ginput
        end
        
        %% Methodes
        function obj = Homography(obj,H)
            % Fonction qui permet de calculer la transformé d'une image
            % dans une nouvelle base
            
            
            largeur = obj.coin2(1)-obj.coin1(1)+1 %Calcule des largeur et hauteur pour  obtenir les autres  coordonées des coins de l'iamge
            hauteur = obj.coin2(2)-obj.coin1(2)+1
            
            
            X = [1 obj.coin2(2) obj.coin2(2) 1]; % Coordonnées de de les coins de l'image
            Y = [1 1 obj.coin2(1) obj.coin2(1)];
            s = 1;
            
            %%%%%%%%%%%%%%Calcule des positions extreme dans le "plan/base"
            %%%%%%%%%%%%%%de l'image dans laquelle on veux projeté%%%%%%%
            
            for i = 1:size(X,2)
                v1 = [X(i); Y(i);s];
                v2 = H\v1;
                v3 = round(v2/v2(3,1));
                X(i) = v3(1,1);     % on remplace les valeurs par les nouvelles calculé
                Y(i) = v3(2,1);
            end

            %%%%%%%%%%%%%%%% on récupère les min et max pour obtenir la dimension de la nouvelle image
            x_homography_max = max(X); 
            y_homography_max = max(Y);
            x_homography_min = min(X);
            y_homography_min = min(Y);
            
            
            x_largeur = abs(x_homography_max-x_homography_min); %calcule des valeurs de largeur et de hauteur de li'mage 
            y_hauteur = abs(y_homography_max-y_homography_min);
            
            %%%%%%%%% Création des listes X et Y 
            obj.Xliste = 1+x_homography_min:1:x_homography_max; % permet de dï¿½caller correctement les indices 
            obj.Yliste = 1+y_homography_min:1:y_homography_max;
            
            %%%%%%%%% Création des nouvelles variable pour la nouvelle 
            image_homography = zeros(y_hauteur,x_largeur,obj.profondeur);
            image_homography_mask = zeros(y_hauteur,x_largeur,obj.profondeur); % mise a 0 de tout les pixels du mask
            
            
            
            %%%%%%%%% Parcour de l'image d'arriver
            for y = 1:y_hauteur                                         % voir si on ne peux pas faire de calcules matricielles a la place
                for x = 1:x_largeur

                    v1 = [x+x_homography_min;y+y_homography_min;s]; % création avec le décalage des coordonnées a parcourir dans l'autre image
                    v2 = H*v1;
                    v3 = round(v2/v2(3,1));
                    
                    
                    if ((( 1 <= v3(2,1)) && (v3(2,1)<= hauteur)) && ((( 1 <= v3(1,1)) && (v3(1,1)<= largeur)))) % Vérification pour voir si les coordonnées d'arriver sont dans l'image de départ 
                        v3(2,1);
                        image_homography(y,x,:) = obj.image_intensite(v3(2,1),v3(1,1),:); % recopie des pixels necessaires
                        image_homography_mask(y,x,:) = 1; % on met en blanc tout les pixels de l'image a mettre en binaire en vrai pour faire des opï¿½rations logique
                
                    end
                end
            end
            
            %%%%%%% Recopie des  nouvelles informations dans l'obj de
            %%%%%%% l'image
            obj.image_intensite =  image_homography;
            obj.image_mask = image_homography_mask;
      
            obj.coin1 = [y_homography_min,x_homography_min];
            obj.coin2 = [y_homography_max,x_homography_max];
            
            %obj.Xliste = 1+abs(x_homography_min):1:abs(x_homography_max); % permet de dï¿½caller correctement les indices 
            %obj.Yliste = 1+abs(y_homography_min):1:abs(y_homography_max);
        end
        

   
        
        function obj = fusion(obj,image_a_fus)
%             xmax = max(max(obj.Xliste),max(image_a_fus.Xliste));
%             xmin = min(min(obj.Xliste),min(image_a_fus.Xliste));
%             ymax = max(max(obj.Yliste),max(image_a_fus.Yliste));
%             ymin = min(min(obj.Yliste),min(image_a_fus.Yliste));
%             
%             xlargeur = abs(xmin-xmax);
%             ylargeur = abs(ymin-ymax);
%             x_largeurboite = xlargeur;
%             y_hauteurboite = ylargeur;
% %             [x_largeurboite,y_hauteurboite] = nvboite(obj.X1,obj.Y1,image_a_fus.X1,image_a_fus.Y1) % recupeeration de la taille maximale!
%             
%             image_boite_mask = zeros(floor(y_hauteurboite),floor(x_largeurboite),floor(obj.profondeur));
%             
%             coin1_boite_finale = [1,1];
% %             coin2_boite_finale = [x_largeurboite,y_hauteurboite];
%             
%             
%          %Calcul de l'Ã©cart entre l'image qui reÃ§oit la fusion et la boÃ®te
%          %englobante finale
%          diffx = obj.Xliste(1) - coin1_boite_finale(1);
%          diffy = obj.Yliste(1) - coin1_boite_finale(2);
%          
%          
%          %Calcul de l'Ã©cart entre l'image Ã  fusionner et la boÃ®te
%          %englobante finale
%          diffx_a_fus = round(abs(image_a_fus.Xliste(1) - coin1_boite_finale(1)));
%          diffy_a_fus = round(abs(image_a_fus.Yliste(1) - coin1_boite_finale(2)));
%             
%          
%          %Faire la copie des des pixels en parcourant les deux  images et en copiant chaque pixel dans l'image final 
%          % a faire pour le image_mask et image_intensitï¿½
%          for x=1:length(obj.Xliste)
%              for y=1:length(obj.Yliste)
%                 image_boite_mask(x+diffx,y+diffy) = obj.image_mask(x,y);
%                 image_boite_mask(x+diffx_a_fus,y+diffy_a_fus)= image_a_fus.image_mask(x,y);
%              end
%          end
         
        % Récupération de la nouvelle boite
        
        % Calcule/ récupérations  des indices/ variables necssaires
      
         coin = nv1boite(obj.coin1,obj.coin2,image_a_fus.coin1,image_a_fus.coin2);

         coin1fus = [coin(1,1) coin(1,2)];
         
         coin2fus = [coin(2,1) coin(2,2)];

        
         largeur_fus = abs( abs(coin1fus(2))-abs(coin2fus(2))) + 1;
         hauteur_fus = abs( abs(coin1fus(1))-abs(coin2fus(1))) + 1;
         
         obj.Xliste = obj.Xliste + abs(coin1fus(2)) + 1;
         
         obj.Yliste = obj.Yliste + abs(coin1fus(1)) + 1;
         
         image_a_fus.Xliste = image_a_fus.Xliste + abs(coin1fus(2)) + 1;
         
         image_a_fus.Yliste = image_a_fus.Yliste + abs(coin1fus(1)) + 1;
         
         
         %Creation des varibles pour la fusion
         
         image_intensite_fus = zeros(hauteur_fus,largeur_fus,obj.profondeur);
         image_mask_fus = zeros(hauteur_fus,largeur_fus,obj.profondeur);
         abs(coin(1,1)) + 1
         abs(coin(1,2)) + 1
         (obj.coin1(1))
         (obj.coin2(1))
         (obj.coin1(2))
         (obj.coin2(2))
         
         image_mask_fus((obj.coin1(1)+ abs(coin(1,1)) + 1):(obj.coin2(1)+ abs(coin(1,1)) ),(obj.coin1(2)+ abs(coin(1,2)) + 1):(obj.coin2(2)+ abs(coin(1,2)) ),:) = obj.image_mask; %% il faut comprendre pourquoi on ne doit pas décaler de 1 sur es ymax et xmax ???
         image_mask_fus(image_a_fus.coin1(1)+ abs(coin(1,1)) + 1:image_a_fus.coin2(1)+ abs(coin(1,1)) + 1,image_a_fus.coin1(2)+ abs(coin(1,2)) + 1:image_a_fus.coin2(2)+ abs(coin(1,2)) + 1,:) = image_a_fus.image_mask;

         image_intensite_fus((obj.coin1(1)+ abs(coin(1,1)) + 1):(obj.coin2(1)+ abs(coin(1,1)) ),(obj.coin1(2)+ abs(coin(1,2)) + 1):(obj.coin2(2)+ abs(coin(1,2)) ),:) = obj.image_intensite;
         image_intensite_fus(image_a_fus.coin1(1)+ abs(coin(1,1)) + 1:image_a_fus.coin2(1)+ abs(coin(1,1)) + 1,image_a_fus.coin1(2)+ abs(coin(1,2)) + 1:image_a_fus.coin2(2)+ abs(coin(1,2)) + 1,:) = image_a_fus.image_intensite;
        
                 
         obj.image_mask = image_mask_fus;
         obj.image_intensite = image_intensite_fus;
         
         
         %Reacfecter les variables a l'objet 
            
        end
        
        
        


        
        function affichage(obj)
        % Fonction qui permet de faire l'affiche d'une image
        
            figure, imshow(uint8(obj.image_mask)); %% on affiche l'image
            figure, imshow(uint8(obj.image_intensite));
        end
        
        
        
        %% Getter et setters
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

   function coin = nv1boite(coin11,coin12,coin21,coin22)
        % Fonction qui permet de determiné les coins de la boite englobante
        % pour une fusion
            ymax = max([coin11(1),coin12(1),coin21(1),coin22(1)]);
            ymin = min([coin11(1),coin12(1),coin21(1),coin22(1)]);
            
            xmax = max([coin11(2),coin12(2),coin21(2),coin22(2)]);
            xmin = min([coin11(2),coin12(2),coin21(2),coin22(2)]);

            
            coin = [ymin xmin;ymax xmax];
                 
        end
        
       
       function er = nvboite(a)
                er = 2*a;
      end