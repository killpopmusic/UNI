clc;
close all;

%SELECTING A RANDOM IMAGE%

possible_colors={'blau','verd','vermell','groc'};
selected_color=possible_colors(randi(length(possible_colors)));
possible_orientation={'0','180'};
selected_orientation=possible_orientation(randi(length(possible_orientation))); 

selected_filename= char(strcat(selected_color,selected_orientation,'.png'));

photo=imread(selected_filename);
figure(1);
image(photo);

%RGB 
red_component=photo(:,:,1);
green_component=photo(:,:,2);
blue_component=photo(:,:,3);

%Calculating the threshold of each component
red_threshhold=graythresh(red_component);
green_threshhold=graythresh(green_component);
blue_threshhold=graythresh(blue_component);

%binarizing the image 
red_binary=imbinarize(red_component,red_threshhold);
green_binary=imbinarize(green_component,green_threshhold);
blue_binary=imbinarize(blue_component,blue_threshhold);

%getting the proportion 


sum_red=sum(red_binary,'all');
sum_green=sum(green_binary,'all'); %summarizing each colors' components
sum_blue=sum(blue_binary,'all');

mean_red=sum_red/(size(red_binary,1)*size(red_binary,2));
mean_green=sum_green/(size(green_binary,1)*size(green_binary,2)); %calculating mean value
mean_blue=sum_blue/(size(blue_binary,1)*size(blue_binary,2));

%deciding the color 

active=mean_red+mean_green+mean_blue;
active_red=mean_red/active;
active_green=mean_green/active;
active_blue=mean_blue/active;

red=0;
green=0;
blue=0;
yellow=0;

if active_red>0.75 && active_blue<0.25 && active_green<0.25
    red=1;
    kolor=' RED';
elseif  active_green>0.75 && active_blue<0.25 && active_red<0.25
    green=1;
    kolor=' GREEN';
elseif active_blue>0.75 && active_red<0.25 && active_green<0.25
    blue=1;
    kolor=' BLUE';
elseif  active_red>0.25 && active_red<0.75 && active_blue<0.25 && active_green>0.25 && active_green<0.75
    yellow=1;
    kolor=' YELLOW';
else 
    disp('color not found');
end

%CHECKING IF THE PLATE IS DEFECTED 

photo2=rgb2gray(photo);
img_threshhold=graythresh(photo2);
binaryimage=imbinarize(photo2,img_threshhold);
data=regionprops(binaryimage,'Area','Perimeter','Orientation');
ap_ratio=data.Area/data.Perimeter; 
figure(2);
imshow(binaryimage);
disp(ap_ratio);

if ap_ratio<78
info=0;
def=' DEFECTED';
else
info=1;
def=' OK';
end


%Sharing the info about defection 

host_inforamtion=opcserverinfo('localhost');
data_access=opcda('localhost','Kepware.KEPServerEX.V6');
connect(data_access);
data_group=addgroup(data_access);

item_def=additem(data_group, 'Robot1.Device1.kontroler1.RAPID.T_ROB1.Module1.item_defected');
write(item_def, info);

%Data to be sent to kepserver and then shown on the webapp
opcserverinfo('localhost');
da=opcda('localhost','Kepware.KEPServerEX.V6');
connect(da);
group=addgroup(da);
item_color=additem(group,'SimData.SimDevice.Data_A');
write(item_color,kolor);

defection=additem(group,'SimData.SimDevice.Data_B');
write(defection,def);
