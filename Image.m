classdef Image < handle
         %% ______________________________________Attributs________________________________________

    properties 
        
        image_intensite, % matrice qui contient toutes les intensité  des pixels de la matrice
        image_mask, % Matrice qui contient un mask binaire 
        coinhaut, % coin qui contient les coordonées xmin, ymin de l'image
        coinbas,  % coin qui contient les coordonées xmax, ymax de l'image
        profondeur, % pronfondeur de l'image pour faire fonctionner si l'image est en noir te blanc
        X1, % Correspond au 4 coordonnées de X pris avec Ginput
        Y1; % Correspond au 4 coordonnées de Y pris avec Ginput
       
    end
    methods
        %% ______________________________________Constructeur________________________________________
        
        function obj = Image(image)
        % Fonction de création de l'image est appelé a la création de
        % l'objet
        
            obj.image_intensite = double(imread(image));                    % creation de la matrice qui contient les intensitï¿½s
            
            [hauteur,largeur, obj.profondeur] = size(obj.image_intensite);  % récupérations des grandeurs utiles de l'image
            
            obj.coinhaut = [1,1];                                              % [y,x] création des coins de l'image
            obj.coinbas = [hauteur,largeur];
            
            
            obj.image_mask = ones(hauteur,largeur,obj.profondeur).*1;             % crï¿½ation d'un mask qui est initialisï¿½ a 1 entiï¿½rement
            figure, imshow(image);                                                  % affichage l'image
            [obj.X1,obj.Y1] = ginput(4);                                            % récupérations des coordonées avec Ginput
        end
        %%  _____________________________________Methodes____________________________________________
        
        function obj = Homography(obj,H)
            % Fonction qui permet de calculer la transformé d'une image
            % dans une nouvelle base
            %% 1ère étape : Calcule des points extrémes de l'image dans laquelle on veut projeté
            
            %Calcule des largeur et hauteur pour  obtenir les autres  coordonées des coins de l'iamge
            hauteur = obj.coinbas(1)-obj.coinhaut(1)+1; 
            largeur = obj.coinbas(2)-obj.coinhaut(2)+1;
            
            % Coordonnées des coins de l'image
            
            X = [1 obj.coinbas(2) obj.coinbas(2) 1]; 
            Y = [1 1 obj.coinbas(1) obj.coinbas(1)];
            s = 1;
            
            %%%%%%%%%%%%%%Calcule des positions extreme dans le "plan/base"
            %%%%%%%%%%%%%%de l'image dans laquelle on veux projeté%%%%%%%
            
            for i = 1:size(X,2)
                v1 = [X(i); Y(i);s];
                v2 = H\v1;
                v3 = round(v2/v2(3,1));
                X(i) = v3(1,1);     % on remplace les valeurs par les nouvelles calculé
                Y(i) = v3(2,1);     % ainsi nos opérations suivantes vont se faire sur X et Y
            end
            
            %% 2 ème étape : Récupération de la nouvelle dimension (largeur/hauteur) de l'image projeté
            
            %%%%%%%%%%%%%%%% on récupère les min et max pour obtenir la dimension de la nouvelle image
            x_homography_max = max(X); 
            y_homography_max = max(Y);
            x_homography_min = min(X);
            y_homography_min = min(Y);
                        
            x_largeur = x_homography_max-x_homography_min+1; %calcule des valeurs de largeur et de hauteur de l'image pour la création des nouvelles matrices 
            y_hauteur = y_homography_max-y_homography_min+1;
               
            %% 3 ème étape :Parcour de l'image et affectation des pixels
            % Création des nouvelles variable pour la nouvelle image
          
            image_homography_intensite = zeros(y_hauteur,x_largeur,obj.profondeur);
            image_homography_mask = zeros(y_hauteur,x_largeur,obj.profondeur); % mise a 0 de tout les pixels du mask
            
            %%%%%%%%% Parcour de l'image d'arriver
            for y = 1:y_hauteur                                         % voir si on ne peux pas faire de calcules matricielles a la place
                for x = 1:x_largeur
                    %% 3.1 étape, calcul de la position dans l'image de départ
                    v1 = [x+x_homography_min;y+y_homography_min;s]; % création avec le décalage des coordonnées a parcourir dans l'autre image cad coordonées géographique
                    v2 = H*v1;
                    v3 = round(v2/v2(3,1));
                    
                    %% 3.2 étape d'affectation des pixels si ils sont dans l'image d'arriver                   
                    % Condition logique pour voir si les coordonnées d'arriver sont dans l'image de départ 
                    if ((( 1 <= v3(2,1)) && (v3(2,1)<= hauteur)) && ((( 1 <= v3(1,1)) && (v3(1,1)<= largeur)))) 
                        v3(2,1);
                        % recopie des pixels necessaires
                        image_homography_intensite(y,x,:) = obj.image_intensite(v3(2,1),v3(1,1),:); 
                        
                        % on met le masque a 1 à l'endroit ou on affecte un pixel
                        image_homography_mask(y,x,:) = 1; 
                
                    end
                end
            end
            
            %% 4 ème étapes : réafectation des variables
           
            % Recopie des  nouvelles informations dans l'obj del'image
            obj.image_intensite =  image_homography_intensite;
            obj.image_mask = image_homography_mask;
      
            obj.coinhaut = [y_homography_min,x_homography_min];
            obj.coinbas = [y_homography_max,x_homography_max];
            
        end
        function obj = fusion(obj,image_a_fus)
        %% 1 ere étape: Calcule de la taille de la nouvelle boite englobante
          
         coin = nv1boite(obj.coinhaut,obj.coinbas,image_a_fus.coinhaut,image_a_fus.coinbas);
         coinhautfus = coin(1,:);
         coinbasfus = coin(2,:);

         % Calcule de la largeur de l'image global
         largeur_fus = coinbasfus(2)-coinhautfus(2) + 1;
         hauteur_fus = coinbasfus(1)-coinhautfus(1) + 1;         
         
         %% 2 ème étape: Calcule des positions des boites englobante dans la nouvelle boite englobante      
         %Calcule des coordonées décalées pour l'une des deux images en
         %entrée
         %ici l'image de l'objet
         
         ymin = (obj.coinhaut(1)-coinhautfus(1))+1;
         ymax = (obj.coinbas(1)-coinhautfus(1))+1;
         xmin = (obj.coinhaut(2) -coinhautfus(2))+1;
         xmax = (obj.coinbas(2) -coinhautfus(2))+1;
         
         %Calcule des coordonées décales pour l'une des deux images en
         %entrée
         %ici l'image en paramètre suplémentaire

         ymin_image_a_fus = (image_a_fus.coinhaut(1)-coinhautfus(1))+1;
         ymax_image_a_fus = (image_a_fus.coinbas(1)-coinhautfus(1))+1;
         xmin_image_a_fus = (image_a_fus.coinhaut(2)-coinhautfus(2))+1;
         xmax_image_a_fus = (image_a_fus.coinbas(2)-coinhautfus(2))+1;
         
         %% 3 ème étape Fussion des images
         
         %Creation des variables d'image pour la fusion
         image_intensite_fus = zeros(hauteur_fus,largeur_fus,obj.profondeur);
         image_mask_fus = zeros(hauteur_fus,largeur_fus,obj.profondeur);
         
         % Affectation et fusion de images dans l'image final
         %image mask
         image_mask_fus(ymin_image_a_fus:ymax_image_a_fus,xmin_image_a_fus:xmax_image_a_fus,:) = image_a_fus.image_mask + image_mask_fus(ymin_image_a_fus:ymax_image_a_fus,xmin_image_a_fus:xmax_image_a_fus,:); % 
         image_mask_fus(ymin:ymax,xmin:xmax,:) = obj.image_mask + image_mask_fus(ymin:ymax,xmin:xmax,:); %% il faut comprendre pourquoi on ne doit pas décaler de 1 sur es ymax et xmax ???
         
         %image intensité
         image_intensite_fus(ymin:ymax,xmin:xmax,:) = obj.image_intensite + image_intensite_fus(ymin:ymax,xmin:xmax,:);
         image_intensite_fus(ymin_image_a_fus:ymax_image_a_fus,xmin_image_a_fus:xmax_image_a_fus,:) = image_a_fus.image_intensite + image_intensite_fus(ymin_image_a_fus:ymax_image_a_fus,xmin_image_a_fus:xmax_image_a_fus,:);
        
         %% 4 ème étape : moyennage des intensités 
         image_intensite_fus = image_intensite_fus./( image_mask_fus+ (image_mask_fus==0) ); %remplacement de l'opération prédédente par ce calcule
         
         image_mask_fus(image_mask_fus>0) = 1;
         %% 5 ème étapes : réafectation des variables
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
        
        % method qui permet de reprendre de nouveaux points
        function obj = getnewginput(obj)
            figure, imshow(uint8(obj.image_intensite)); %% on affiche l'image
            [obj.X1,obj.Y1] = ginput(4);
        end
        % method qui permet de d'afficher le masque dans des couleurs
        % visibles
        function obj = modifmask(obj)
           obj.image_mask(obj.image_mask>0) = 255;  
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
        % Fonction qui permet de determiné les coins de la boite englobante
        % pour une fusion
            ymax = max([coinhaut1(1) coinhaut2(1) coinbas1(1) coinbas2(1)]);
            ymin = min([coinhaut1(1) coinhaut2(1) coinbas1(1) coinbas2(1)]);
            xmax = max([coinhaut1(2) coinhaut2(2) coinbas1(2) coinbas2(2)]);
            xmin = min([coinhaut1(2) coinhaut2(2) coinbas1(2) coinbas2(2)]);
            coin = [ymin xmin; ymax xmax];     
   end
   
   