classdef Image
    %IMAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        image_intensite,
        image_mask,
        largeur,
        hauteur,
        profondeur,
        X1,
        Y1;
    end
    
    methods
        
        function obj = Image(image)
            %IMAGE Construct an instance of this class
            %   Detailed explanation goes here
            obj.image_intensite = double(imread(image));                                    % creation de la matrice qui contient les intensit�s
            [obj.hauteur, obj.largeur, obj.profondeur] = size(obj.image_intensite);         % cr�ation des dimensions
            obj.image_mask = ones(obj.hauteur,obj.largeur,obj.profondeur).*255;             % cr�ation d'un mask qui est initialis� a 1 enti�rement
            figure, imshow(image);
            [obj.X1,obj.Y1] =ginput(4);
        end
        
        function Homography(obj,H)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            % on va calculer d'abord les extremit� de l'image pour cr�e
            % l'image de la bonne taille avec les cot� noir
            
            X = [1 obj.largeur obj.largeur 1]
            Y = [1 1 obj.hauteur obj.hauteur]
            s = 1;
            
            %calcule des positions extremes
            for i = 1:size(X,2)
                v1 = [X(i); Y(i);s];
                v2 = H*v1;
                v3 = round(v2/v2(3,1));
                X(i) = v3(1,1);     % on remplace les valeurs par les nouvelles calculer
                Y(i) = v3(2,1);
            end
            
            x_homography_max = max(X); % on r�cup�re les max pour avoir la dimension de l'image
            y_homography_max = max(Y);
            
            image_homography = zeros(y_homography_max,x_homography_max,obj.profondeur);
            image_homography_mask = zeros(y_homography_max,x_homography_max,obj.profondeur);
            
            for y = 1:obj.hauteur
                for x = 1:obj.largeur
                    v1 = [x;y;s];
                    v2 = H*v1;
                    v3 = round(v2/v2(3,1));
                    if( v3(2,1)<=0)
                        v3(2,1) = 1;
                    end
                    if( v3(1,1)<=0)
                        v3(1,1) = 1;
                    end
                    image_homography(v3(2,1),v3(1,1),:) = obj.image_intensite(y,x,:);
                    image_homography_mask(v3(2,1),v3(1,1),:) = 255; % on met en blanc tout les pixels de l'image a mettre en binaire en vrai pour faire des op�rations logique
                end
            end
            setimage_intensite(image_homography);
            %obj.image_intensite =  image_homography;
            %obj.image_mask = image_homography_mask;
           
            figure, imshow(uint8(image_homography))
             
            obj.hauteur = y_homography_max;
            obj.largeur = x_homography_max;
            
            
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
