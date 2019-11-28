classdef Image < handle
    %IMAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        image_intensite,
        image_mask,
        coin1,
        coin2,
        profondeur,
        X1, %ginput du debut
        Y1,
        Xliste,
        Yliste;
        
    end
    
    methods
        
        function obj = Image(image)
            %IMAGE Construct an instance of this class
            %   Detailed explanation goes here
            obj.image_intensite = double(imread(image));% creation de la matrice qui contient les intensit�s
            
            
            [hauteur,largeur, obj.profondeur] = size(obj.image_intensite); 
            
            obj.coin1 = [1,1];
            obj.coin2 = [hauteur,largeur];
            
            % cr�ation des dimensions
            obj.image_mask = ones(hauteur,largeur,obj.profondeur).*255;             % cr�ation d'un mask qui est initialis� a 1 enti�rement
            figure, imshow(image);
            [obj.X1,obj.Y1] = ginput(4);
        end
        
        function obj = Homography(obj,H)
            %METHOD1 Summary of this method goes here
            % Detailed explanation goes here
            % on va calculer d'abord les extremit� de l'image pour cr�e
            % l'image de la bonne taille avec les cot� noir
            
            largeur = obj.coin2(1)-obj.coin1(1);
            hauteur = obj.coin2(2)-obj.coin1(2);
            
            
            X = [1 largeur largeur 1];
            Y = [1 1 hauteur hauteur];
            s = 1;
            
            %calcule des positions extremes
            for i = 1:size(X,2)
                v1 = [X(i); Y(i);s];
                v2 = H\v1;
                v3 = round(v2/v2(3,1));
                X(i) = v3(1,1);     % on remplace les valeurs par les nouvelles calculer
                Y(i) = v3(2,1);
            end

            
            x_homography_max = max(X); % on r�cup�re les max pour avoir la dimension de l'image
            y_homography_max = max(Y);
            x_homography_min = min(X);
            y_homography_min = min(Y);
            
            x_largeur = abs(x_homography_max-x_homography_min); %calcule des valeurs maximales
            y_hauteur = abs(y_homography_max-y_homography_min);
            
            obj.Xliste = 1+x_homography_min:1:x_homography_max; % permet de d�caller correctement les indices 
            obj.Yliste = 1+y_homography_min:1:y_homography_max;
            
            
            image_homography = zeros(y_hauteur,x_largeur,obj.profondeur);
            size(image_homography);
            image_homography_mask = zeros(y_hauteur,x_largeur,obj.profondeur);
            
            
            
            
            for y = 1:y_hauteur
                for x = 1:x_largeur

                    v1 = [x+x_homography_min;y+y_homography_min;s]; % a voir si on enl�ve la valeur absolue -
                    v2 = H*v1;
                    v3 = round(v2/v2(3,1));
                    if ((( 1 <= v3(2,1)) && (v3(2,1)<= hauteur)) && ((( 1 <= v3(1,1)) && (v3(1,1)<= largeur))))
                    
                        image_homography(y,x,:) = obj.image_intensite(v3(2,1),v3(1,1),:);
                        image_homography_mask(y,x,:) = 255; % on met en blanc tout les pixels de l'image a mettre en binaire en vrai pour faire des op�rations logique
                
                    end
                end
            end
            %obj.setimage_intensite(image_homography);
            obj.image_intensite =  image_homography;
            obj.image_mask = image_homography_mask;
           

            obj.coin1 = [y_homography_min,x_homography_min];
            obj.coin2 = [y_homography_max,x_homography_max];
            
            %obj.Xliste = 1+abs(x_homography_min):1:abs(x_homography_max); % permet de d�caller correctement les indices 
            %obj.Yliste = 1+abs(y_homography_min):1:abs(y_homography_max);
        end
        
        function obj = fusion(obj,image_a_fus)
            xmax = max(max(obj.Xliste),max(a.Xliste));
            xmin = min(min(obj.Xliste),min(a.Xliste));
            ymax = max(max(obj.Yliste),max(image_a_fus.Yliste));
            ymin = min(min(obj.Yliste),min(image_a_fus.Yliste));
            
            xlargeur = abs(xmin-xmax);
            ylargeur = abs(ymin-ymax);
            x_largeurboite = xlargeur;
            y_hauteurboite = ylargeur;
%             [x_largeurboite,y_hauteurboite] = nvboite(obj.X1,obj.Y1,image_a_fus.X1,image_a_fus.Y1) % recupeeration de la taille maximale!
            
            image_boite_mask = zeros(floor(y_hauteurboite),floor(x_largeurboite),floor(obj.profondeur));
            
            coin1_boite_finale = [1,1];
%             coin2_boite_finale = [x_largeurboite,y_hauteurboite];
            
            
         %Calcul de l'écart entre l'image qui reçoit la fusion et la boîte
         %englobante finale
         diffx = obj.Xliste(1) - coin1_boite_finale(1);
         diffy = obj.Yliste(1) - coin1_boite_finale(2);
         
         
         %Calcul de l'écart entre l'image à fusionner et la boîte
         %englobante finale
         diffx_a_fus = round(abs(image_a_fus.Xliste(1) - coin1_boite_finale(1)));
         diffy_a_fus = round(abs(image_a_fus.Yliste(1) - coin1_boite_finale(2)));
            
         
         %Faire la copie des des pixels en parcourant les deux  images et en copiant chaque pixel dans l'image final 
         % a faire pour le image_mask et image_intensit�
         for x=1:length(obj.Xliste)
             for y=1:length(obj.Yliste)
                image_boite_mask(x+diffx,y+diffy) = obj.image_mask(x,y);
                image_boite_mask(x+diffx_a_fus,y+diffy_a_fus)= image_a_fus.image_mask(x,y);
             end
         end
         
         figure,imshow(image_boite_mask);
         
         %Reacfecter les variables a l'objet 
            
        end
        % Fonction 
        function [xlargeur,ylargeur] = nvboite(X1,Y1,X2,Y2)
            
            xmax = max(max(X1,X2));
            xmin = min(min(X1,X2));
            ymax = max(max(Y1,Y2));
            ymin = min(min(Y1,Y2));
            
            xlargeur = abs(xmin-xmax);
            ylargeur = abs(ymin-ymax);
                 
        end
        
        function affichage(obj)
            
            figure, imshow(uint8(obj.image_intensite)); %% on affiche l'image
            
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
        
        function er = getlargeur(obj)
            er = obj.largeur;
        end
        
        function obj = sethauteur(obj,hauteur)
            obj.image_intensite = hauteur;
        end
        
        function er = gethauteur(obj)
            er = obj.hauteur;
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

