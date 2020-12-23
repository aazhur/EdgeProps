% Beta Version. August 28, 2015
% by Denis Tsygankov (GT/Emory BME) and Timothy Qi (UNC)
% denis.tsygankov@bme.gatech.edu

function varargout = EdgeProps2(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EdgeProps2_OpeningFcn, ...
                   'gui_OutputFcn',  @EdgeProps2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function EdgeProps2_OpeningFcn(hObject, eventdata, handles, varargin)

    set(handles.copyright,'String',['  ' char(169) ' Tsygankov, Qi, & Zhurikhina'],'ForegroundColor',[.6 .6 .6]);
    
    set(handles.axes2,'XTick',[],'YTick',[],'Box','on');
    set(handles.axes3,'XTick',[],'YTick',[],'Box','on');
    set(handles.axes4,'XTick',[],'YTick',[],'Box','on');
    set(handles.axes5,'XTick',[],'YTick',[],'Box','on');
    
    handles.radius=5;
    handles.imagelag=1;
    handles.N_inter = 10;
    
    handles.output = hObject;
    handles.Slidermov = addlistener(handles.slider2, 'Value', 'PostSet', @(src, event)switchFrame(hObject, src, event));
    handles.processing=0;
    handles.kymo_done=0;
    handles.framenumber=0;
    handles.imported=0;
    handles.file=0;
    handles.sliderpos = round(get(handles.slider2,'Value'));
    handles.depth = 0;
    handles.depth_check = 0;
    
    handles.paramretained=1;
     
    handles.intframe=0;
    handles.mode = 'edge';
     
    handles.XVARs{1,1} = 'Velocity';
    handles.XVARs{2,1} = 'Intensity';
    handles.XVARs{3,1} = 'Orientation';
    handles.YVARs{1,1} = 'Velocity';
    handles.YVARs{2,1} = 'Intensity';
    handles.YVARs{3,1} = 'Orientation';

    handles.XVAR = handles.XVARs{get(handles.xpop,'Value'),1};
    handles.YVAR = handles.YVARs{get(handles.ypop,'Value'),1};
    
    colormap(handles.axes2,'jet');
    colormap(handles.axes3,'jet');
    colormap(handles.axes4,'jet');
    colormap(handles.axes5,'jet');

    guidata(hObject, handles);

function switchFrame (hObject, src, event)
    handles = guidata(hObject);
    handles.sliderpos = round(get(handles.slider2,'Value'));
    set(handles.text2, 'String', horzcat('Frame ',num2str(handles.sliderpos),'/',num2str(handles.framenumber-handles.imagelag)));
    
    if handles.imported > 0
        axes(handles.axes2);
        xlim=get(handles.axes2,'XLim');
        ylim=get(handles.axes2,'YLim');
        cla;
        hold on;
        im=handles.image{handles.sliderpos};%-handles.minI(handles.sliderpos);
               
        imagesc(im);        
        if (handles.sliderpos+handles.imagelag) <= handles.framenumber
            X=handles.XN{handles.sliderpos+handles.imagelag};
            Y=handles.YN{handles.sliderpos+handles.imagelag};
            plot([X X(1)],[Y Y(1)],'w','LineWidth',2);
        end
        plot(handles.cx(handles.sliderpos),handles.cy(handles.sliderpos),'ko','MarkerFaceColor','w');
        if handles.kymo_done
            plot(handles.nX(handles.sliderpos,1),handles.nY(handles.sliderpos,1),'wo','MarkerFaceColor','k')
        end
        axis equal;
        axis ij;
        set(handles.axes2,'XLim',xlim);
        set(handles.axes2,'YLim',ylim);
        axis off;   
        if handles.processing==1 && strcmp(handles.mode,'edge') == 1 ;
            if (handles.sliderpos+handles.imagelag) <= handles.framenumber
                VarVal2 = get(handles.ypop,'Value');
                VarVal = get(handles.xpop,'Value');
                mFRM=handles.framenumber-handles.imagelag;
                
            axes(handles.axes3);
            cla;
            hold on;
            handles.XVAR = handles.XVARs{VarVal,1};
            if VarVal == 1
                PlotThis=handles.colVel{handles.sliderpos};
            elseif VarVal == 2
                PlotThis=handles.colInt{handles.sliderpos};
            elseif VarVal == 3
                PlotThis=handles.colPos{handles.sliderpos};
            end
            patch(handles.XN{handles.sliderpos},handles.YN{handles.sliderpos},PlotThis,'EdgeColor','flat','FaceColor','none','LineWidth',2);
            axis equal;
            axis ij;
            axis off;
            set(handles.axes3,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
            set(handles.text6,'String',horzcat(handles.XVAR, ' at the edge'));
            
            axes(handles.axes4);
            cla;
            hold on;
            handles.YVAR = handles.YVARs{VarVal2,1};
            if VarVal2 == 1
                PlotThis=handles.colVel{handles.sliderpos};
            elseif VarVal2 == 2
                PlotThis=handles.colInt{handles.sliderpos};
            elseif VarVal2 ==3
                PlotThis=handles.colPos{handles.sliderpos};
            end
            patch(handles.XN{handles.sliderpos},handles.YN{handles.sliderpos},PlotThis,'EdgeColor','flat','FaceColor','none','LineWidth',2);
            axis equal;
            axis ij;
            axis off;
            set(handles.axes4,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
            set(handles.text7,'String',horzcat(handles.YVAR,' at the edge'));

            if VarVal==1 && VarVal2==2                          
                X=handles.LocVel; Y=handles.LocInt;
               elseif VarVal==1 && VarVal2==3
                X=handles.LocVel; Y=handles.LocPos;
            elseif VarVal==2 && VarVal2==1
                X=handles.LocInt; Y=handles.LocVel;
            elseif VarVal==2 && VarVal2==3
                X=handles.LocInt; Y=handles.LocPos;
            elseif VarVal==3 && VarVal2==1
                X=handles.LocPos; Y=handles.LocVel;
            elseif VarVal==3 && VarVal2==2
                X=handles.LocPos; Y=handles.LocInt;
            end
            [xb,yb,j,tmp,smp,dx,dy] = XY_Plot(handles.cNUM, X, handles.xmin, handles.xmax, Y, handles.ymin, handles.ymax, mFRM);
            
            handles.MeanHist=[xb;tmp;smp];
                        
            axes(handles.axes5);
            reset(handles.axes5);
            cla;
            hold on;
            imagesc(xb,yb,j');
            plot(xb,tmp,'w.-');
            xlabel(handles.XVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12); 
            ylabel(handles.YVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12);
            axis xy;
            axis fill;
            
            set(handles.axes5,'XLim',[xb(1)-dx/2,xb(end)+dx/2],'YLim',[yb(1)-dy/2,yb(end)+dy/2]);
                
            end
        elseif handles.processing == 1 && strcmp(handles.mode,'interior') == 1
            if (handles.sliderpos + handles.imagelag) <= handles.framenumber
                t = handles.sliderpos;
                
                depth = str2double(get(handles.depth_edit,'String'));
                if handles.interdone(t) == 1
                    F = round(handles.F_all{t});
                    maximum = max(max(F)); check = maximum - depth;
                    im = handles.image{t}.*(F <= check);
                    [x,y,~,~] = SmothBound(im,1);  

                    axes(handles.axes5);
                    xlabel(''); ylabel('');
                    cla;
                    hold on;
                    imagesc(handles.S_all{t});
                    plot(x,y,'k');
                    axis equal;
                    axis ij;
                    axis fill;
                    axis off;
                    set(handles.axes5,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
                    set(handles.text14,'String','Direction map');

                    axes(handles.axes3);
                    cla;
                    hold on;
                    imagesc(handles.M_all{t});
                    plot(x,y,'k');
                    axis equal;
                    axis ij;
                    axis fill;
                    axis off;
                    set(handles.axes3,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
                    set(handles.text6,'String','Interpolated velocity');

                    axes(handles.axes4);
                    cla;
                    hold on;
                    imagesc(handles.F_all{t});
                    plot(x,y,'k');
                    axis equal;
                    axis ij;
                    axis fill;
                    axis off;
                    set(handles.axes4,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
                    set(handles.text7,'String','Distance map');
                else
                    axes(handles.axes3);
                    cla;
                    xlabel('');
                    ylabel('');
                    set(handles.axes3,'XTick',[],'YTick',[],'Box','on');
                    axis on; axis fill;

                    axes(handles.axes4);
                    cla;
                    xlabel('');
                    ylabel('');
                    set(handles.axes4,'XTick',[],'YTick',[],'Box','on');
                    axis on; axis fill;

                    axes(handles.axes5);
                    cla; 
                    xlabel('');
                    ylabel('');
                    set(handles.axes5,'XTick',[],'YTick',[],'Box','on');
                    axis on; axis fill;
                end
                
            end
        elseif handles.processing == 1 && strcmp(handles.mode,'kymo') == 1
            if (handles.sliderpos + handles.imagelag) <= handles.framenumber
                
                    axes(handles.axes5);
                    reset(handles.axes5);
                    cla;
                    if get(handles.scale_checkbox,'Value')
                        colormap(jet);
                        imagesc(handles.correl_s); 
                        set(handles.text14,'String',['Unscaled Correlation of Velocity vs Intensity at Depth ' num2str(handles.depth)]);
                    else
                        colormap(jet);
                        imagesc(handles.correl_z); 
                        set(handles.text14,'String',['Scaled Correlation of Velocity vs Intensity at Depth ' num2str(handles.depth)]);
                    end 
                    set(handles.axes5,'XTick',[],'YTick',[],'Box','on');
                    axis off; 
                    axis fill;

                    axes(handles.axes3);
                    reset(handles.axes3);
                    cla;
                    if get(handles.scale_checkbox,'Value')
                        imagesc(handles.sV);    
                    else
                        imagesc(handles.nV);    
                    end
                    set(handles.axes3,'XTick',[],'YTick',[]);
                    axis on;    
                    xlabel('perimeter (counterclockwise)','FontName','Helvetica','FontUnits','pixels','FontSize',12);
                    ylabel('<==  time','FontName','Helvetica','FontUnits','pixels','FontSize',12);
                    set(handles.text6,'String',['Velocity kymograph at Depth ' num2str(handles.depth)]);

                    axes(handles.axes4);
                    reset(handles.axes4);
                    cla;
                    if get(handles.scale_checkbox,'Value')
                        imagesc(handles.sZ);    
                    else
                        imagesc(handles.nZ);    
                    end
                    set(handles.axes4,'XTick',[],'YTick',[]);
                    axis on;   
                    xlabel('perimeter (counterclockwise)','FontName','Helvetica','FontUnits','pixels','FontSize',12);
                    ylabel('<==  time','FontName','Helvetica','FontUnits','pixels','FontSize',12);    
                    set(handles.text7,'String',['Intensity kymograph at Depth ' num2str(handles.depth)]);
            end      
        end
    end
    guidata(hObject, handles);

function varargout = EdgeProps2_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function slider2_Callback(hObject, eventdata, handles)

function slider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
guidata(hObject,handles);

function text2(hObject, eventdata, handles)

function File_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function Import_Callback(hObject, eventdata, handles)
    set(handles.Xmin,'String','','Enable','Off');
    set(handles.Xmax,'String','','Enable','Off');
    set(handles.Ymin,'String','','Enable','Off');
    set(handles.Ymax,'String','','Enable','Off');
    set(handles.Equalize,'Enable','Off');
    set(handles.xpop,'Enable','Off');
    set(handles.ypop,'Enable','Off');

    set(handles.text11,'Enable','Off');
    set(handles.text12,'Enable','Off');
    set(handles.text15,'Enable','Off');
    set(handles.text16,'Enable','Off');
    set(handles.text17,'Enable','Off');
    set(handles.text18,'Enable','Off');
    set(handles.text19,'Enable','Off');
    set(handles.text20,'Enable','Off');

    set(handles.figures_button, 'Enable', 'Off');   
    set(handles.save_button, 'Enable', 'Off');   
    set(handles.kymo_button,'Enable','Off');
    set(handles.scale_checkbox,'Enable','Off');
    set(handles.scale_checkbox,'Value',0);
    set(handles.interior_button,'Enable','Off');
    set(handles.interior_all_button,'Enable','Off');
    set(handles.edge_button,'Enable','Off');
    set(handles.edge_save,'Enable','Off');
    set(handles.n_edit,'Enable','Off');
    set(handles.depth_edit,'Enable','Off');
    set(handles.depth_graph,'Enable','Off');
    set(handles.depth_save,'Enable','Off');
    set(handles.Orig,'Enable','Off');

    set(handles.radiobutton1,'Enable','On');
    set(handles.radiobutton1,'Value',1);
    set(handles.radiobutton2,'Enable','Off');
    set(handles.radiobutton3,'Enable','Off');

    if ispc
        [maskfile,maskpath,index] = uigetfile('*.tif','Select the mask file to import');
    else
        h = questdlg('Select the mask file to import', 'Import',...
        'OK','Cancel','OK');
        switch h
            case 'OK'
                [maskfile,maskpath,index] = uigetfile('*.tif'); 
            case 'Cancel'
                return; 
        end    
    end
    
    if index==0        
        return;
    else
        maskfile = [maskpath maskfile];
        info = imfinfo(maskfile);
        handles.framenumber = numel(info);
        handles.proposedlag = 1;
        mask=cell(1,handles.framenumber);
        waitbox=waitbar(0,'Importing masks...','WindowStyle','modal');
        for k = 1:handles.framenumber
            waitbar(k/handles.framenumber);
            im = double(imread(maskfile,k));
            im(im>0)=1;
            im=imfill(im);
            mask{k}=im;
        end
        close(waitbox);
    end
    
    if handles.framenumber < 2
        msgbox('Upload a Stack of files!');
        return;
    end    
    
    if ispc
        [handles.file, handles.pathname, index] = uigetfile ('*.tif','Select the data file to import');
    else
        h = questdlg('Select the data file to import', 'Import',...
        'OK','Cancel','OK');
        switch h
            case 'OK'
                [handles.file, handles.pathname, index] = uigetfile('*.tif');
            case 'Cancel'
            	return;
        end    
    end
    
    if index==1 
        
        try
            delete(handles.Slidermov);
        end
        axes(handles.axes3);
        cla;
        xlabel('');
        ylabel('');
        set(handles.axes3,'XTick',[],'YTick',[],'Box','on');
        axis on; axis fill;
        
        axes(handles.axes4);
        cla;
        xlabel('');
        ylabel('');
        set(handles.axes4,'XTick',[],'YTick',[],'Box','on');
        axis on; axis fill;
        
        axes(handles.axes5);
        cla; 
        xlabel('');
        ylabel('');
        set(handles.axes5,'XTick',[],'YTick',[],'Box','on');
        axis on; axis fill;
        
        set(handles.filename_text,'String',handles.file);
        
        handles.sliderpos = 1;
        
        handles.filename = [handles.pathname handles.file];
        info = imfinfo (handles.filename);
        tmp = numel(info);
        if tmp~=handles.framenumber
            errordlg('Mask file and data file must have the same number of frames','Import error','modal');
            return;
        end
        
        handles.image=cell(1,handles.framenumber);
        
        handles.cx=zeros(1,handles.framenumber);
        handles.cy=zeros(1,handles.framenumber);
        handles.minI=zeros(1,handles.framenumber);
        
        waitbox=waitbar(0,'Importing data...','WindowStyle','modal');
        for k = 1:handles.framenumber
            waitbar(k/handles.framenumber);
            im = double(imread(handles.filename,k));
            im = im.*mask{k};
            handles.image{k} = im;
            handles.minI(k) = min(im(im>0)); 
        end
        close(waitbox);
        
        set(handles.text6, 'String', ' ');  
        set(handles.text7, 'String', ' ');
        set(handles.text14, 'String', ' ');
        
        handles.XM=size(handles.image{1},2); 
        handles.YM=size(handles.image{1},1);
        
        handles.str=strel('disk',handles.radius,0);
        handles.nbh=getnhood(handles.str);

        handles.XN1=cell(1,handles.framenumber);
        handles.XN2=cell(1,handles.framenumber);
        handles.YN1=cell(1,handles.framenumber);
        handles.YN2=cell(1,handles.framenumber);
        
        [GX,GY]=meshgrid(1:handles.XM,1:handles.YM);
        
        waitbox=waitbar(0,'Extracting boundaries...','WindowStyle','modal');
        for count = 1:handles.framenumber
            waitbar(count/handles.framenumber);
            im = mask{count};
            [handles.XN{count},handles.YN{count},~,~]=SmothBound(im,1);            
            MX = im.*GX;
            MY = im.*GY;
            Mass = sum(im(:));
            handles.cx(count) = sum(MX(:))/Mass;
            handles.cy(count) = sum(MY(:))/Mass;            
        end
        close(waitbox);
        
        im=handles.image{1};
        axes(handles.axes2);
        cla;
        imagesc(im);
        axis image;
        axis ij;
        axis off;
        hold on;
        plot(handles.XN{1+handles.imagelag},handles.YN{1+handles.imagelag},'w','LineWidth',2);
        plot(handles.cx(1),handles.cy(1),'ko','MarkerFaceColor','w');
        
        if (handles.framenumber-handles.imagelag)>1
            set(handles.slider2, 'Max', handles.framenumber-handles.imagelag);
            set(handles.slider2, 'Min', 1);
            set(handles.slider2, 'Value', 1);
            set(handles.slider2, 'SliderStep',[1/(handles.framenumber-1) 5/(handles.framenumber-1)]);
            set(handles.slider2, 'Enable', 'on');  
        end
        
        set(handles.text2, 'String', ['Frame 1/' num2str(handles.framenumber-handles.imagelag)],'Enable','on');
        set(handles.text3, 'Enable','on');
        set(handles.text4, 'Enable','on');
        
        set(handles.edit2,'String',num2str(handles.imagelag),'Enable','On');
        set(handles.edit3,'String',num2str(handles.radius),'Enable','On');
        
        set(handles.edge_button,'Enable','On');
        
        handles.mode='edge';
        set(handles.radiobutton1, 'Value', 1);
        set(handles.radiobutton2, 'Value', 0);
        set(handles.radiobutton3, 'Value', 0);
        
        handles.imported=1;
        handles.processing=0;
        handles.kymo_done=0;
        handles.interdone=zeros(1,handles.framenumber);
        handles.Slidermov = addlistener(handles.slider2, 'Value', 'PostSet', @(src, event)switchFrame(hObject, src, event));
        
        %interior mode handles
        handles.M_all = cell(1,(handles.framenumber-1));
        handles.S_all = cell(1,(handles.framenumber-1));
        handles.F_all = cell(1,(handles.framenumber-1));
        
    end
    guidata(hObject, handles);

function figure1_SizeChangedFcn(hObject, eventdata, handles)

function edit2_Callback(hObject, eventdata, handles)

    handles.slidermax = str2double(get(handles.slider2,'Max'));
    handles.slidervalue = str2double(get(handles.slider2,'Value'));
    handles.proposedlag=str2double(get(hObject,'String'));
    if handles.framenumber==0
        h = msgbox('Import an image first.');
        set(handles.edit2,'String','2');
    else
        if handles.proposedlag < handles.framenumber && handles.imagelag ~= handles.proposedlag
            handles.imagelag = handles.proposedlag;
            axes(handles.axes3);
                cla;
                xlabel('');
                ylabel('');
                set(handles.axes3,'XTick',[],'YTick',[],'Box','on');
                axis on; axis fill;
            axes(handles.axes4);
                cla;
                xlabel('');
                ylabel('');
                set(handles.axes4,'XTick',[],'YTick',[],'Box','on');
                axis on; axis fill;
            axes(handles.axes5);
                cla;
                xlabel('');
                ylabel('');
                set(handles.axes5,'XTick',[],'YTick',[],'Box','on');
                axis on; axis fill;
            handles.processing=0;
            axes(handles.axes2);
                cla;
                hold on;
                if handles.sliderpos+handles.imagelag>handles.framenumber
                    handles.sliderpos=(handles.framenumber-handles.proposedlag);
                    set(handles.slider2,'Value',handles.framenumber-handles.proposedlag);
                    set(handles.text2, 'String', horzcat('Frame ',num2str(handles.sliderpos),'/',num2str(handles.framenumber-handles.proposedlag)));
                end
                imagesc(handles.image{handles.sliderpos});
                plot(handles.XN{handles.sliderpos+handles.imagelag},handles.YN{handles.sliderpos+handles.imagelag},'w','LineWidth',2);
                axis image;
                axis ij;
                axis off;
            set(handles.text6,'String',' ');
            set(handles.text7,'String',' ');
            set(handles.text14,'String',' ');

                if handles.framenumber - handles.proposedlag == 1
                    set(handles.slider2,'SliderStep',[1/1 10000/1]);
                else
                    set(handles.slider2, 'SliderStep',[1/(handles.framenumber-1) 5/(handles.framenumber-1)]);
                end

            handles.processing=0;
            handles.kymo_done=0;
            handles.interdone=zeros(1,handles.framenumber);
            set(handles.figures_button,'Enable','Off');
            set(handles.save_button,'Enable','Off');
            set(handles.slider2, 'Max', handles.framenumber-handles.proposedlag);
            set(handles.text2, 'String', horzcat('Frame ',num2str(handles.sliderpos),'/',num2str(handles.framenumber-handles.proposedlag)));

            set(handles.Xmin,'String','','Enable','Off');
            set(handles.Xmax,'String','','Enable','Off');
            set(handles.Ymin,'String','','Enable','Off');
            set(handles.Ymax,'String','','Enable','Off');
            set(handles.xpop,'Enable','Off');
            set(handles.ypop,'Enable','Off');

            set(handles.text11,'Enable','Off');
            set(handles.text12,'Enable','Off');
            set(handles.text15,'Enable','Off');
            set(handles.text16,'Enable','Off');
            set(handles.text17,'Enable','Off');
            set(handles.text18,'Enable','Off');
            set(handles.text19,'Enable','Off');
            set(handles.text20,'Enable','Off');
            
            set(handles.n_edit,'Enable','Off');
            set(handles.depth_edit,'Enable','Off');
            set(handles.depth_graph,'Enable','Off');
            set(handles.depth_save,'Enable','Off');
        
            set(handles.kymo_button,'Enable','Off');
            set(handles.scale_checkbox,'Enable','Off');
            set(handles.scale_checkbox,'Value',0);
            set(handles.interior_button,'Enable','Off');
            set(handles.interior_all_button,'Enable','Off');
            set(handles.edge_button,'Enable','On');
            set(handles.edge_save,'Enable','Off');
            set(handles.Equalize,'Enable','Off');
            set(handles.Orig,'Enable','Off');
            set(handles.radiobutton1,'Enable','On');
            set(handles.radiobutton1,'Value',1);
            set(handles.radiobutton2,'Enable','Off');
            set(handles.radiobutton3,'Enable','Off');
            handles.mode='edge';

        else
            h = msgbox('Frame and image lag exceed file length.');
            set(handles.edit2,'String',num2str(handles.imagelag));
        end
    end
    guidata(hObject,handles);

function edit2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
handles.imagelag = str2double(get(hObject,'String'));
guidata(hObject,handles);

function edit3_Callback(hObject, eventdata, handles)
    if handles.framenumber==0
        h = msgbox('Import an image first.');
        set(handles.edit3,'String','5');
    else
        check=str2double(get(hObject,'String'));
        check2=isnumeric(check);
        if (check>=0)&&(check<1000)&&(check2==1)
            handles.radius = str2double(get(hObject,'String'));
            handles.str=strel('disk',handles.radius,0);
            handles.nbh=getnhood(handles.str);
            axes(handles.axes3);
                cla;
                xlabel('');
                ylabel('');
                set(handles.axes3,'XTick',[],'YTick',[],'Box','on');
                axis on; axis fill;             
            axes(handles.axes4);
                cla;
                xlabel('');
                ylabel('');
                set(handles.axes4,'XTick',[],'YTick',[],'Box','on');
                axis on; axis fill;             
            axes(handles.axes5);
                cla;
                xlabel('');
                ylabel('');
                set(handles.axes5,'XTick',[],'YTick',[],'Box','on');
                axis on; axis fill;
            axes(handles.axes2);
                cla;
                hold on;
                imagesc(handles.image{handles.sliderpos});
                plot(handles.XN{handles.sliderpos+handles.imagelag},handles.YN{handles.sliderpos+handles.imagelag},'w','LineWidth',2);
                axis image;
                axis ij;
                axis off;
            set(handles.text6,'String',' ');
            set(handles.text7,'String',' ');
            set(handles.text14,'String',' ');    
                
            handles.processing=0;
            handles.kymo_done=0;
            handles.interdone=zeros(1,handles.framenumber);
            
            set(handles.Xmin,'String','','Enable','Off');
            set(handles.Xmax,'String','','Enable','Off');
            set(handles.Ymin,'String','','Enable','Off');
            set(handles.Ymax,'String','','Enable','Off');
            set(handles.xpop,'Enable','Off');
            set(handles.ypop,'Enable','Off');

            set(handles.text11,'Enable','Off');
            set(handles.text12,'Enable','Off');
            set(handles.text15,'Enable','Off');
            set(handles.text16,'Enable','Off');
            set(handles.text17,'Enable','Off');
            set(handles.text18,'Enable','Off');
            set(handles.text19,'Enable','Off');
            set(handles.text20,'Enable','Off');
            
            set(handles.n_edit,'Enable','Off');
            set(handles.depth_edit,'Enable','Off');
            set(handles.depth_graph,'Enable','Off');
            set(handles.depth_save,'Enable','Off');
        
            set(handles.kymo_button,'Enable','Off');
            set(handles.scale_checkbox,'Enable','Off');
            set(handles.scale_checkbox,'Value',0);
            set(handles.figures_button,'Enable','Off');
            set(handles.save_button,'Enable','Off');
            set(handles.interior_button,'Enable','Off');
            set(handles.interior_all_button,'Enable','Off');
            set(handles.edge_button,'Enable','On');
            set(handles.edge_save,'Enable','Off');
            set(handles.Equalize,'Enable','Off');
            set(handles.Orig,'Enable','Off');
            set(handles.radiobutton1,'Enable','On');
            set(handles.radiobutton1,'Value',1);
            set(handles.radiobutton2,'Enable','Off');
            set(handles.radiobutton3,'Enable','Off');
            handles.mode='edge';
        else
            h = msgbox('Input a reasonable radius.');
            try
                set(handles.edit3,'String',num2str(handles.radius));
            end
        end
        
            
    end
guidata(hObject,handles);

function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.radius = str2double(get(hObject,'String'));
guidata(hObject,handles);

function depth_edit_Callback(hObject, eventdata, handles)
    if handles.interdone(handles.sliderpos) == 1

            depth = str2double(get(hObject,'String'));
            set(handles.depth_edit,'String',num2str(depth));

            F = round(handles.F_all{handles.sliderpos});
            maximum = max(max(F)); check = maximum - depth;

            if check > 0 && check <= maximum
                im = handles.image{handles.sliderpos}.*(F <= check);
                [x,y,~,~] = SmothBound(im,1);  

                axes(handles.axes5);
                xlabel(''); ylabel('');
                cla;
                hold on;
                imagesc(handles.S_all{handles.sliderpos});
                plot(x,y,'k');
                axis equal;
                axis ij;
                axis fill;
                axis off;
                set(handles.axes5,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
                set(handles.text14,'String','Direction map');

                axes(handles.axes3);
                cla;
                hold on;
                imagesc(handles.M_all{handles.sliderpos});
                plot(x,y,'k');
                axis equal;
                axis ij;
                axis fill;
                axis off;
                set(handles.axes3,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
                set(handles.text6,'String','Interpolated velocity');

                axes(handles.axes4);
                cla;
                hold on;
                imagesc(handles.F_all{handles.sliderpos});
                plot(x,y,'k');
                axis equal;
                axis ij;
                axis fill;
                axis off;
            else
                msgbox(['Chosen depth exceeds allowed value. Please, choose depth within [0;' num2str(maximum-1) ']']);
            end         
    end
    
    guidata(hObject,handles);

function depth_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function depth_graph_Callback(hObject, eventdata, handles) 
     depth = str2double(get(handles.depth_edit,'String'));
     set(handles.depth_edit,'String',num2str(depth));
   
     VarVal2 = get(handles.ypop,'Value');
     VarVal = get(handles.xpop,'Value');
     mFRM = handles.framenumber-handles.imagelag;   

     if sum(handles.interdone) == handles.framenumber 
            if handles.depth ~= depth && depth > 0
                msgbox('To view graph at chosen Depth, do Interior Analysis of ALL frames!')
            elseif handles.depth ~= depth && depth == 0   
                handles.depth = 0;
                handles.LocVel_depth = handles.LocVel;
                handles.LocInt_depth = handles.LocInt;
                handles.LocPos_depth = handles.LocPos;
                handles.cNUM_depth = handles.cNUM;
                guidata(hObject,handles);
            end 

            maVel = max([handles.LocVel_depth{:}]);
            miVel = min([handles.LocVel_depth{:}]); 
            maInt = max([handles.LocInt_depth{:}]); 
            miInt = min([handles.LocInt_depth{:}]); 
            maPos = max([handles.LocPos_depth{:}]); 
            miPos = min([handles.LocPos_depth{:}]); 

           if VarVal == 1
            xmin = miVel;
            xmax = maVel;
            X = handles.LocVel_depth;
            x_name = 'Velocity';
           elseif VarVal == 2
            xmin = miInt;
            xmax = maInt;
            X = handles.LocInt_depth;
            x_name = 'Intensity';
           elseif VarVal == 3
            xmin = miPos;
            xmax = maPos;
            X = handles.LocPos_depth;
            x_name = 'Position';
           end
        
           if VarVal2 == 1
            ymin = miVel;
            ymax = maVel;
            Y = handles.LocVel_depth;
            y_name = 'Velocity';
           elseif VarVal2 == 2
            ymin = miInt;
            ymax = maInt;
            Y = handles.LocInt_depth;
            y_name = 'Intensity';
           elseif VarVal2 == 3
            ymin = miPos;
            ymax = maPos;
            Y = handles.LocPos_depth;
            y_name = 'Position';
          end
        
        [xb,yb,j,tmp,~,dx,dy] = XY_Plot(handles.cNUM_depth, X, xmin, xmax, Y, ymin, ymax, mFRM);

        handles.current_fig = figure;
        colormap(jet);
        cla;
        hold on;
        imagesc(xb,yb,j');
        plot(xb,tmp,'w.-');
        xlabel(handles.XVARs{VarVal,1},'FontName','Helvetica','FontUnits','pixels','FontSize',12); 
        ylabel(handles.YVARs{VarVal2,1},'FontName','Helvetica','FontUnits','pixels','FontSize',12);
        title([y_name ' vs ' x_name ' at Depth ' num2str(handles.depth)]);
        axis xy;
        axis fill;
        xlim([xb(1)-dx/2,xb(end)+dx/2]);
        ylim([yb(1)-dy/2,yb(end)+dy/2]);
        
        set(handles.depth_save,'Enable','On');
        handles.kymo_done=0;
        
    else
          VarVal = get(handles.ypop,'Value');
          VarVal2 = get(handles.xpop,'Value');
          if VarVal==1 && VarVal2==2                          
            X='Velocity'; Y='Intensity';
          elseif VarVal==1 && VarVal2==3
            X='Velocity'; Y='Position';
          elseif VarVal==2 && VarVal2==1
            X='Intensity'; Y='Velocity';
          elseif VarVal==2 && VarVal2==3
            X='Intensity'; Y='Position';
          elseif VarVal==3 && VarVal2==1
            X='Position'; Y='Velocity';
          elseif VarVal==3 && VarVal2==2
            X='Position'; Y='Intensity';
          end

          msgbox(['To view ' Y ' vs ' X ' Graph; Perform Interior Analysis for all frames first.']);
     end  
    
    guidata(hObject,handles);
    
function edge_button_Callback(hObject, eventdata, handles)
    
    if handles.file~=0
        
        VarVal2 = get(handles.ypop,'Value');
        VarVal = get(handles.xpop,'Value');
        mFRM=handles.framenumber-handles.imagelag;
        
        if VarVal~=VarVal2
            if (handles.processing~=1)||(handles.paramretained==0)
                
                cNUM=zeros(1,mFRM);

                handles.colInt=cell(1,mFRM);
                handles.colVel=cell(1,mFRM);
                handles.colPos=cell(1,mFRM);

                handles.LocInt=cell(1,mFRM);
                handles.LocVel=cell(1,mFRM);
                handles.LocPos=cell(1,mFRM);
                    
                wait=waitbar(0,'Processing in progress... ','WindowStyle','modal');

                for i=1:mFRM
                    waitbar(i/mFRM);

                    Ew=zeros(handles.YM+2*handles.radius,handles.XM+2*handles.radius);
                    Ew((handles.radius+1):(handles.radius+handles.YM),(handles.radius+1):(handles.radius+handles.XM))=handles.image{i};

                    cNUM(i)=length(handles.XN{i});        
                    db=zeros(1,cNUM(i));
                    di=zeros(1,cNUM(i));
                    dx=zeros(1,cNUM(i)); dy=zeros(1,cNUM(i));

                    handles.LocInt{i}=zeros(1,cNUM(i));
                    handles.LocVel{i}=zeros(1,cNUM(i));
                    handles.LocPos{i}=zeros(1,cNUM(i));
                    
                    for n=1:cNUM(i)
                        di(n)=inpolygon(handles.XN{i}(n),handles.YN{i}(n),handles.XN{i+handles.imagelag},handles.YN{i+handles.imagelag});
                        [db(n),dx(n),dy(n)]=DistToBoundU(handles.XN{i}(n),handles.YN{i}(n),handles.XN{i+handles.imagelag},handles.YN{i+handles.imagelag});       
                        xt=round(handles.XN{i}(n)); 
                        yt=round(handles.YN{i}(n));
                        W1=Ew(yt:(yt+2*handles.radius),xt:(xt+2*handles.radius));
                        W2=W1.*handles.nbh;
                        handles.LocInt{i}(n)=mean(W2(W2>0));
                        handles.LocVel{i}(n)=db(n)*sign(di(n)-0.5);
                        handles.LocPos{i}(n)=abs(atan2(handles.YN{i}(n)-handles.cy(i),handles.XN{i}(n)-handles.cx(i)));
                    
                    end
                    
                    handles.colInt{i}=round(1+63*(handles.LocInt{i}-min(handles.LocInt{i}))/(max(handles.LocInt{i})-min(handles.LocInt{i})));
                    handles.colVel{i}=round(1+63*(handles.LocVel{i}-min(handles.LocVel{i}))/(max(handles.LocVel{i})-min(handles.LocVel{i})));
                    handles.colPos{i}=round(1+63*(handles.LocPos{i}-min(handles.LocPos{i}))/(max(handles.LocPos{i})-min(handles.LocPos{i})));
                end
                handles.cNUM=cNUM;
                
                handles.maVel = max([handles.LocVel{:}]);
                handles.miVel = min([handles.LocVel{:}]); 
                handles.maInt = max([handles.LocInt{:}]); 
                handles.miInt = min([handles.LocInt{:}]); 
                handles.maPos = max([handles.LocPos{:}]); 
                handles.miPos = min([handles.LocPos{:}]); 
                
                handles.paramretained=1;
            end
            
            if VarVal == 1
                set(handles.Xmin,'String',num2str(handles.miVel,'%.2f'));
                set(handles.Xmax,'String',num2str(handles.maVel,'%.2f'));
            elseif VarVal == 2
                set(handles.Xmin,'String',num2str(handles.miInt,'%.2f'));
                set(handles.Xmax,'String',num2str(handles.maInt,'%.2f'));
            elseif VarVal == 3
                set(handles.Xmin,'String',num2str(handles.miPos,'%.2f'));
                set(handles.Xmax,'String',num2str(handles.maPos,'%.2f'));
            end


            if VarVal2 == 1
                set(handles.Ymin,'String',num2str(handles.miVel,'%.2f'));
                set(handles.Ymax,'String',num2str(handles.maVel,'%.2f'));
            elseif VarVal2 == 2
                set(handles.Ymin,'String',num2str(handles.miInt,'%.2f'));
                set(handles.Ymax,'String',num2str(handles.maInt,'%.2f'));
            elseif VarVal2 == 3
                set(handles.Ymin,'String',num2str(handles.miPos,'%.2f'));
                set(handles.Ymax,'String',num2str(handles.maPos,'%.2f'));
            end
                
            set(handles.axes2,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
            
            axes(handles.axes3);
            cla;
            hold on;
            handles.XVAR = handles.XVARs{VarVal,1};
            if VarVal == 1
                PlotThis=handles.colVel{handles.sliderpos};
            elseif VarVal == 2
                PlotThis=handles.colInt{handles.sliderpos};
            elseif VarVal == 3
                PlotThis=handles.colPos{handles.sliderpos};
            end
            patch(handles.XN{handles.sliderpos},handles.YN{handles.sliderpos},PlotThis,'EdgeColor','flat','FaceColor','none','LineWidth',2);
            axis equal;
            axis ij;
            axis off;
            set(handles.axes3,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
            set(handles.text6,'String',horzcat(handles.XVAR, ' at the edge'));
            
            axes(handles.axes4);
            cla;
            hold on;
            handles.YVAR = handles.YVARs{VarVal2,1};
            if VarVal2 == 1
                PlotThis=handles.colVel{handles.sliderpos};
            elseif VarVal2 == 2
                PlotThis=handles.colInt{handles.sliderpos};
            elseif VarVal2 ==3
                PlotThis=handles.colPos{handles.sliderpos};
            end
            patch(handles.XN{handles.sliderpos},handles.YN{handles.sliderpos},PlotThis,'EdgeColor','flat','FaceColor','none','LineWidth',2);
            axis equal;
            axis ij;
            axis off;
            set(handles.axes4,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
            set(handles.text7,'String',horzcat(handles.YVAR,' at the edge'));

            if VarVal == 1
                handles.xmin = handles.miVel;
                handles.xmax = handles.maVel;
                X = handles.LocVel;
           elseif VarVal == 2
                handles.xmin = handles.miInt;
                handles.xmax = handles.maInt;
                X = handles.LocInt;
           elseif VarVal == 3
                handles.xmin = handles.miPos;
                handles.xmax = handles.maPos;
                X = handles.LocPos;
           end

           if VarVal2 == 1
                handles.ymin = handles.miVel;
                handles.ymax = handles.maVel;
                Y = handles.LocVel;
           elseif VarVal2 == 2
                handles.ymin = handles.miInt;
                handles.ymax = handles.maInt;
                Y = handles.LocInt;
           elseif VarVal2 == 3
                handles.ymin = handles.miPos;
                handles.ymax = handles.maPos;
                Y = handles.LocPos;
          end
            
            [xb,yb,j,tmp,smp,dx,dy] = XY_Plot(handles.cNUM, X, handles.xmin, handles.xmax, Y, handles.ymin, handles.ymax, mFRM);
            
            handles.MeanHist=[xb;tmp;smp];
                        
            axes(handles.axes5);
            reset(handles.axes5);
            cla;
            hold on;
            imagesc(xb,yb,j');
            plot(xb,tmp,'w.-');
            xlabel(handles.XVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12); 
            ylabel(handles.YVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12);
            axis xy;
            axis fill;
            
            set(handles.axes5,'XLim',[xb(1)-dx/2,xb(end)+dx/2],'YLim',[yb(1)-dy/2,yb(end)+dy/2]);
          
            try
                close(wait);
            end
            handles.processing=1;
            
            set(handles.text14,'String','');
            set(handles.text11,'Enable','On');
            set(handles.text12,'Enable','On');
            set(handles.text15,'Enable','On');
            set(handles.text16,'Enable','On');
            set(handles.text17,'Enable','On');
            set(handles.text18,'Enable','On');
            set(handles.text19,'Enable','On');
            set(handles.text20,'Enable','On');
            
            set(handles.n_edit,'Enable','On');
            set(handles.n_edit,'String',num2str(handles.N_inter),'Enable','On');
            set(handles.depth_edit,'Enable','On');
            set(handles.depth_edit,'String',num2str(0),'Enable','On');
            set(handles.depth_graph,'Enable','On');
            set(handles.depth_save,'Enable','Off');
            
            set(handles.xpop,'Enable','On');
            set(handles.ypop,'Enable','On');
            set(handles.Xmin,'Enable','On');
            set(handles.Xmax,'Enable','On');
            set(handles.Ymin,'Enable','On');
            set(handles.Ymax,'Enable','On');
            set(handles.Equalize,'Enable','On');
            set(handles.Orig,'Enable','On');
            set(handles.scale_checkbox,'Enable','Off');
            set(handles.scale_checkbox,'Value',0);
            set(handles.figures_button,'Enable','Off');
            set(handles.save_button,'Enable','Off');
            
            set(handles.kymo_button,'Enable','On');
            set(handles.interior_button,'Enable','On');
            set(handles.interior_all_button,'Enable','On');
            set(handles.edge_save,'Enable','On');        
            handles.mode='edge';
            set(handles.radiobutton1,'Enable','On');
            set(handles.radiobutton1, 'Value', 1);
            set(handles.radiobutton2, 'Value', 0);
            set(handles.radiobutton3, 'Value', 0);
            
            guidata(hObject,handles);
        elseif VarVal==VarVal2
            mas=msgbox('Choose 2 different parameters.');
        elseif handlesvelmin>=handles.xmax
            mas=msgbox('Velocity max/min mismatch.');
        end
   end

function Xmin_Callback(hObject, eventdata, handles)

    xminproposed=str2double(get(handles.Xmin,'String'));
    
    xmax=str2double(get(handles.Xmax,'String'));
    valid=isempty(xminproposed);
    VarVal = get(handles.xpop,'Value');
    VarVal2 = get(handles.ypop,'Value');
    mFRM=handles.framenumber-handles.imagelag;
    if VarVal==1
        mi=handles.miVel;
        ma=handles.maVel;
    elseif VarVal==2
        mi=handles.miInt;
        ma=handles.maInt;
    elseif VarVal==3
        mi=handles.miPos;
        ma=handles.maPos;
    end
    
    if (xminproposed < xmax) && (xminproposed < ma) && (valid==0);
        if xminproposed >= mi
            handles.xmin = xminproposed;
        else
            handles.xmin = mi;
        end
        if VarVal==1 && VarVal2==2
            X=handles.LocVel; Y=handles.LocInt;
        elseif VarVal==1 && VarVal2==3
            X=handles.LocVel; Y=handles.LocPos;
        elseif VarVal==2 && VarVal2==1
            X=handles.LocInt; Y=handles.LocVel;
        elseif VarVal==2 && VarVal2==3
            X=handles.LocInt; Y=handles.LocPos;
        elseif VarVal==3 && VarVal2==1
            X=handles.LocPos; Y=handles.LocVel;
        elseif VarVal==3 && VarVal2==2
            X=handles.LocPos; Y=handles.LocInt;
        end
        [xb,yb,j,tmp,smp,dx,dy] = XY_Plot(handles.cNUM, X, handles.xmin, handles.xmax, Y, handles.ymin, handles.ymax, mFRM);

        handles.MeanHist=[xb;tmp;smp];
        
        axes(handles.axes5);
        reset(handles.axes5);
        cla;
        hold on;
        imagesc(xb,yb,j');
        plot(xb,tmp,'w.-');
        xlabel(handles.XVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12); 
        ylabel(handles.YVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12);
        axis xy;
        axis fill;
        set(handles.axes5,'XLim',[xb(1)-dx/2,xb(end)+dx/2],'YLim',[yb(1)-dy/2,yb(end)+dy/2]);
      
    end   
    set(handles.Xmin,'String',num2str(handles.xmin,'%.2f'));
    guidata(hObject,handles);
   
function Xmin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

function Xmax_Callback(hObject, eventdata, handles)

    xmaxproposed=str2double(get(handles.Xmax,'String'));
    
    xmin=str2double(get(handles.Xmin,'String'));
    valid=isempty(xmaxproposed);
    VarVal = get(handles.xpop,'Value');
    VarVal2 = get(handles.ypop,'Value');
    mFRM=handles.framenumber-handles.imagelag;
    if VarVal==1
        mi=handles.miVel;
        ma=handles.maVel;
    elseif VarVal==2
        mi=handles.miInt;
        ma=handles.maInt;
    elseif VarVal==3
        mi=handles.miPos;
        ma=handles.maPos;
    end
    
    if (xmaxproposed > xmin) && (xmaxproposed > mi) && (valid==0);
        if xmaxproposed <= ma
            handles.xmax = xmaxproposed;
        else
            handles.xmax = ma;
        end
        if VarVal==1 && VarVal2==2
            X=handles.LocVel; Y=handles.LocInt;
        elseif VarVal==1 && VarVal2==3
            X=handles.LocVel; Y=handles.LocPos;
        elseif VarVal==2 && VarVal2==1
            X=handles.LocInt; Y=handles.LocVel;
        elseif VarVal==2 && VarVal2==3
            X=handles.LocInt; Y=handles.LocPos;
        elseif VarVal==3 && VarVal2==1
            X=handles.LocPos; Y=handles.LocVel;
        elseif VarVal==3 && VarVal2==2
            X=handles.LocPos; Y=handles.LocInt;
        end
        [xb,yb,j,tmp,smp,dx,dy] = XY_Plot(handles.cNUM, X, handles.xmin, handles.xmax, Y, handles.ymin, handles.ymax, mFRM);

        handles.MeanHist=[xb;tmp;smp];
        
        axes(handles.axes5);
        reset(handles.axes5);
        cla;
        hold on;
        imagesc(xb,yb,j');
        plot(xb,tmp,'w.-');
        xlabel(handles.XVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12); 
        ylabel(handles.YVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12);
        axis xy;
        axis fill;
        set(handles.axes5,'XLim',[xb(1)-dx/2,xb(end)+dx/2],'YLim',[yb(1)-dy/2,yb(end)+dy/2]);
      
    end   
    set(handles.Xmax,'String',num2str(handles.xmax,'%.2f'));
    guidata(hObject,handles);

function Xmax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

function Ymin_Callback(hObject, eventdata, handles)

    yminproposed=str2double(get(handles.Ymin,'String'));
    
    ymax=str2double(get(handles.Ymax,'String'));
    valid=isempty(yminproposed);
    VarVal = get(handles.xpop,'Value');
    VarVal2 = get(handles.ypop,'Value');
    mFRM=handles.framenumber-handles.imagelag;
    if VarVal2==1
        mi=handles.miVel;
        ma=handles.maVel;
    elseif VarVal2==2
        mi=handles.miInt;
        ma=handles.maInt;
    elseif VarVal2==3
        mi=handles.miPos;
        ma=handles.maPos;
    end
    
    if (yminproposed < ymax) && (yminproposed < ma) && (valid==0);
        if yminproposed >= mi
            handles.ymin = yminproposed;
        else
            handles.ymin = mi;
        end
        if VarVal==1 && VarVal2==2
            X=handles.LocVel; Y=handles.LocInt;
        elseif VarVal==1 && VarVal2==3
            X=handles.LocVel; Y=handles.LocPos;
        elseif VarVal==2 && VarVal2==1
            X=handles.LocInt; Y=handles.LocVel;
        elseif VarVal==2 && VarVal2==3
            X=handles.LocInt; Y=handles.LocPos;
        elseif VarVal==3 && VarVal2==1
            X=handles.LocPos; Y=handles.LocVel;
        elseif VarVal==3 && VarVal2==2
            X=handles.LocPos; Y=handles.LocInt;
        end
        [xb,yb,j,tmp,smp,dx,dy] = XY_Plot(handles.cNUM, X, handles.xmin, handles.xmax, Y, handles.ymin, handles.ymax, mFRM);

        handles.MeanHist=[xb;tmp;smp];
        
        axes(handles.axes5);
        reset(handles.axes5);
        cla;
        hold on;
        imagesc(xb,yb,j');
        plot(xb,tmp,'w.-');
        xlabel(handles.XVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12); 
        ylabel(handles.YVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12);
        axis xy;
        axis fill;
        set(handles.axes5,'XLim',[xb(1)-dx/2,xb(end)+dx/2],'YLim',[yb(1)-dy/2,yb(end)+dy/2]);
      
    end   
    set(handles.Ymin,'String',num2str(handles.ymin,'%.2f'));
    guidata(hObject,handles);

function Ymin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Ymax_Callback(hObject, eventdata, handles)

    ymaxproposed=str2double(get(handles.Ymax,'String'));
    
    ymin=str2double(get(handles.Ymin,'String'));
    valid=isempty(ymaxproposed);
    VarVal = get(handles.xpop,'Value');
    VarVal2 = get(handles.ypop,'Value');
    mFRM=handles.framenumber-handles.imagelag;
    if VarVal2==1
        mi=handles.miVel;
        ma=handles.maVel;
    elseif VarVal2==2
        mi=handles.miInt;
        ma=handles.maInt;
    elseif VarVal2==3
        mi=handles.miPos;
        ma=handles.maPos;
    end
    
    if (ymaxproposed > ymin) && (ymaxproposed > mi) && (valid==0);
        if ymaxproposed <= ma
            handles.ymax = ymaxproposed;
        else
            handles.ymax = ma;
        end
        if VarVal==1 && VarVal2==2
            X=handles.LocVel; Y=handles.LocInt;
        elseif VarVal==1 && VarVal2==3
            X=handles.LocVel; Y=handles.LocPos;
        elseif VarVal==2 && VarVal2==1
            X=handles.LocInt; Y=handles.LocVel;
        elseif VarVal==2 && VarVal2==3
            X=handles.LocInt; Y=handles.LocPos;
        elseif VarVal==3 && VarVal2==1
            X=handles.LocPos; Y=handles.LocVel;
        elseif VarVal==3 && VarVal2==2
            X=handles.LocPos; Y=handles.LocInt;
        end
        [xb,yb,j,tmp,smp,dx,dy] = XY_Plot(handles.cNUM, X, handles.xmin, handles.xmax, Y, handles.ymin, handles.ymax, mFRM);

        handles.MeanHist=[xb;tmp;smp];
        
        axes(handles.axes5);
        reset(handles.axes5);
        cla;
        hold on;
        imagesc(xb,yb,j');
        plot(xb,tmp,'w.-');
        xlabel(handles.XVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12); 
        ylabel(handles.YVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12);
        axis xy;
        axis fill;
        set(handles.axes5,'XLim',[xb(1)-dx/2,xb(end)+dx/2],'YLim',[yb(1)-dy/2,yb(end)+dy/2]);
      
    end   
    set(handles.Ymax,'String',num2str(handles.ymax,'%.2f'));
    guidata(hObject,handles);

function Ymax_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Equalize_Callback(hObject, eventdata, handles) 
    lim5 = get(handles.axes5,'XLim');
    lim3 = get(handles.axes3,'XLim');
    lim4 = get(handles.axes4,'XLim');
    lim2 = get(handles.axes2,'XLim');

    if isequal(lim2,lim3) && ~isequal(lim2,lim4)
        set(handles.axes2,'XLim',get(handles.axes4,'XLim'));
        set(handles.axes2,'YLim',get(handles.axes4,'YLim'));
        set(handles.axes3,'XLim',get(handles.axes4,'XLim'));
        set(handles.axes3,'YLim',get(handles.axes4,'YLim'));
            
    
        if strcmp(handles.mode,'interior')
            set(handles.axes5,'XLim',get(handles.axes4,'XLim'));
            set(handles.axes5,'YLim',get(handles.axes4,'YLim'));
        end
        
    elseif isequal(lim2,lim4) && ~isequal(lim2,lim3)   
        set(handles.axes2,'XLim',get(handles.axes3,'XLim'));
        set(handles.axes2,'YLim',get(handles.axes3,'YLim'));
        set(handles.axes4,'XLim',get(handles.axes3,'XLim'));
        set(handles.axes4,'YLim',get(handles.axes3,'YLim'));
        
        if strcmp(handles.mode,'interior')
            set(handles.axes5,'XLim',get(handles.axes3,'XLim'));
            set(handles.axes5,'YLim',get(handles.axes3,'YLim'));
        end
        
    elseif isequal(lim3,lim4) && ~isequal(lim3,lim2)       
        set(handles.axes3,'XLim',get(handles.axes2,'XLim'));
        set(handles.axes3,'YLim',get(handles.axes2,'YLim'));
        set(handles.axes4,'XLim',get(handles.axes2,'XLim'));
        set(handles.axes4,'YLim',get(handles.axes2,'YLim'));
        
        if strcmp(handles.mode,'interior')
            set(handles.axes5,'XLim',get(handles.axes2,'XLim'));
            set(handles.axes5,'YLim',get(handles.axes2,'YLim'));
        end
        
    elseif strcmp(handles.mode,'interior') && isequal(lim2,lim3) && isequal(lim2,lim4) && isequal(lim3,lim4) && ~isequal(lim2,lim5)         
        set(handles.axes3,'XLim',get(handles.axes5,'XLim'));
        set(handles.axes3,'YLim',get(handles.axes5,'YLim'));
        set(handles.axes4,'XLim',get(handles.axes5,'XLim'));
        set(handles.axes4,'YLim',get(handles.axes5,'YLim'));
        set(handles.axes2,'XLim',get(handles.axes5,'XLim'));
        set(handles.axes2,'YLim',get(handles.axes5,'YLim'));
    else
        Orig_Callback(hObject, eventdata, handles)
    end
    
    guidata(hObject,handles);
 
function Orig_Callback(hObject, eventdata, handles)
        set(handles.axes2,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.axes3,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.axes4,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        
        if strcmp(handles.mode,'interior')
            set(handles.axes5,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        end
        
        guidata(hObject,handles);
    
    
function figures_button_Callback(hObject, eventdata, handles)

    if handles.kymo_done
        
        nV = handles.nV;
        nV = 65535*(nV - min(nV(:)))/(max(nV(:))-min(nV(:)));

        nZ = handles.nZ;
        nZ = 65535*(nZ - min(nZ(:)))/(max(nZ(:))-min(nZ(:)));

        sV = handles.sV;
        sV = 65535*(sV - min(sV(:)))/(max(sV(:))-min(sV(:)));

        sZ = handles.sZ;
        sZ = 65535*(sZ - min(sZ(:)))/(max(sZ(:))-min(sZ(:)));
        
        correl_s = handles.correl_s;
        correl_s = 65535*(correl_s - min(correl_s(:)))/(max(correl_s(:))-min(correl_s(:)));
                  
        correl_z = handles.correl_z;
        correl_z = 65535*(correl_z - min(correl_z(:)))/(max(correl_z(:))-min(correl_z(:)));
        
        figure('Name','Velocity','NumberTitle','off');
        colormap(jet);
        imagesc(nV);
        axis ij;

        figure('Name','Scaled Velocity','NumberTitle','off');
        colormap(jet);
        imagesc(sV);
        axis ij;

        figure('Name','Intensity','NumberTitle','off');
        colormap(jet);
        imagesc(nZ);
        axis ij;

        figure('Name','Scaled Intensity','NumberTitle','off');
        colormap(jet);
        imagesc(sZ);
        axis ij;
        
        figure('Name','Unscaled Correlation','NumberTitle','off');
        colormap(jet);
        imagesc(correl_s);
        axis ij;
                
        figure('Name','Scaled Correlation','NumberTitle','off');
        colormap(jet);
        imagesc(correl_z);
        axis ij;
        
        
    end

function xpop_Callback(hObject, eventdata, handles)
    if strcmp(handles.mode,'edge')
    VarVal2 = get(handles.ypop,'Value');
    VarVal = get(handles.xpop,'Value');
    
    handles.XVAR = handles.XVARs{VarVal,1};
    handles.YVAR = handles.YVARs{VarVal2,1};  
    mFRM=handles.framenumber-handles.imagelag;
    
    if VarVal==1
        handles.xmin=handles.miVel;
        handles.xmax=handles.maVel;
    elseif VarVal==2
        handles.xmin=handles.miInt;
        handles.xmax=handles.maInt;
    elseif VarVal==3
        handles.xmin=handles.miPos;
        handles.xmax=handles.maPos;
    end
    set(handles.Xmin,'String',num2str(handles.xmin,'%.2f'));
    set(handles.Xmax,'String',num2str(handles.xmax,'%.2f'));
    
    if VarVal ~= VarVal2
        set(handles.Xmin,'Enable','On');
        set(handles.Xmax,'Enable','On');            
        if handles.processing==1
            if VarVal==1 && VarVal2==2                          
                X=handles.LocVel; Y=handles.LocInt;
            elseif VarVal==1 && VarVal2==3
                X=handles.LocVel; Y=handles.LocPos;
            elseif VarVal==2 && VarVal2==1
                X=handles.LocInt; Y=handles.LocVel;
            elseif VarVal==2 && VarVal2==3
                X=handles.LocInt; Y=handles.LocPos;
            elseif VarVal==3 && VarVal2==1
                X=handles.LocPos; Y=handles.LocVel;
            elseif VarVal==3 && VarVal2==2
                X=handles.LocPos; Y=handles.LocInt;
            end
            [xb,yb,j,tmp,smp,dx,dy] = XY_Plot(handles.cNUM, X, handles.xmin, handles.xmax, Y, handles.ymin, handles.ymax, mFRM);
            
            handles.MeanHist=[xb;tmp;smp];
                        
            axes(handles.axes5);
            reset(handles.axes5);
            cla;
            hold on;
            imagesc(xb,yb,j');
            plot(xb,tmp,'w.-');
            xlabel(handles.XVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12); 
            ylabel(handles.YVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12);
            axis xy;
            axis fill;
            set(handles.axes5,'XLim',[xb(1)-dx/2,xb(end)+dx/2],'YLim',[yb(1)-dy/2,yb(end)+dy/2]);
                   
        end
    else
        if handles.processing==1
            axes(handles.axes5);
            cla;
            axis on;
            set(handles.axes5,'Box','on','XTick',[],'YTick',[]);
            xlabel(''); ylabel('');
        end        
    end
    
    if handles.processing==1
        axes(handles.axes3);
        cla;
        hold on;
        if VarVal==1
            PlotThis=handles.colVel{handles.sliderpos};
        elseif VarVal==2
            PlotThis=handles.colInt{handles.sliderpos};
        elseif VarVal==3
            PlotThis=handles.colPos{handles.sliderpos};
        end
        patch(handles.XN{handles.sliderpos},handles.YN{handles.sliderpos},PlotThis,'EdgeColor','flat','FaceColor','none','LineWidth',2);
        axis equal;
        axis ij;
        axis off;
        set(handles.axes3,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.text6,'String',horzcat(handles.XVAR, ' at the edge'));
        
        set(handles.axes4,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        
    end
    end
    guidata(hObject,handles);

function xpop_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    guidata(hObject,handles);

function ypop_Callback(hObject, eventdata, handles)
    if strcmp(handles.mode,'edge')
    VarVal2 = get(handles.ypop,'Value');
    VarVal = get(handles.xpop,'Value');
    
    handles.XVAR = handles.XVARs{VarVal,1};
    handles.YVAR = handles.YVARs{VarVal2,1};
    mFRM=handles.framenumber-handles.imagelag;
    
    if VarVal2==1
        handles.ymin=handles.miVel;
        handles.ymax=handles.maVel;
    elseif VarVal2==2
        handles.ymin=handles.miInt;
        handles.ymax=handles.maInt;
    elseif VarVal2==3
        handles.ymin=handles.miPos;
        handles.ymax=handles.maPos;
    end
    set(handles.Ymin,'String',num2str(handles.ymin,'%.2f'));
    set(handles.Ymax,'String',num2str(handles.ymax,'%.2f'));
    
    if VarVal ~= VarVal2
        set(handles.Ymin,'Enable','On');
        set(handles.Ymax,'Enable','On');
        if handles.processing==1
            
            if VarVal==1 && VarVal2==2                          
                X=handles.LocVel; Y=handles.LocInt;
            elseif VarVal==1 && VarVal2==3
                X=handles.LocVel; Y=handles.LocPos;
            elseif VarVal==2 && VarVal2==1
                X=handles.LocInt; Y=handles.LocVel;
            elseif VarVal==2 && VarVal2==3
                X=handles.LocInt; Y=handles.LocPos;
            elseif VarVal==3 && VarVal2==1
                X=handles.LocPos; Y=handles.LocVel;
            elseif VarVal==3 && VarVal2==2
                X=handles.LocPos; Y=handles.LocInt;
            end
            [xb,yb,j,tmp,smp,dx,dy] = XY_Plot(handles.cNUM, X, handles.xmin, handles.xmax, Y, handles.ymin, handles.ymax, mFRM);
            
            handles.MeanHist=[xb;tmp;smp];
                        
            axes(handles.axes5);
            reset(handles.axes5);
            cla;
            hold on;
            imagesc(xb,yb,j');
            plot(xb,tmp,'w.-');
            xlabel(handles.XVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12); 
            ylabel(handles.YVAR,'FontName','Helvetica','FontUnits','pixels','FontSize',12);
            axis xy;
            axis fill;
            set(handles.axes5,'XLim',[xb(1)-dx/2,xb(end)+dx/2],'YLim',[yb(1)-dy/2,yb(end)+dy/2]);
                   
        end
    else
        if handles.processing==1
            axes(handles.axes5);
            cla;
            axis on;
            set(handles.axes5,'Box','on','XTick',[],'YTick',[]);
            xlabel(''); ylabel('');
        end        
    end
    
    if handles.processing==1
        axes(handles.axes4);
        cla;
        hold on;

        if VarVal2 == 1
            PlotThis=handles.colVel{handles.sliderpos};
        elseif VarVal2 == 2
            PlotThis=handles.colInt{handles.sliderpos};
        elseif VarVal2 ==3
            PlotThis=handles.colPos{handles.sliderpos};
        end

        patch(handles.XN{handles.sliderpos},handles.YN{handles.sliderpos},PlotThis,'EdgeColor','flat','FaceColor','none','LineWidth',2);
        axis equal;
        axis ij;
        axis off;
        set(handles.axes4,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.text7,'String',horzcat(handles.YVAR,' at the edge'));
        
        set(handles.axes3,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
    end
    end
    guidata(hObject,handles);

function ypop_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

function interior_button_Callback(hObject, eventdata, handles)

    if handles.processing > 0
        
        i = handles.sliderpos; 
        
        if handles.interdone(i) == 0
            n = handles.N_inter;
            x = handles.XN{i};
            y = handles.YN{i};
            z = handles.colVel{i};
            [I,J] = interpol(x,y,z,handles.cx(i),handles.cy(i),handles.XM,handles.YM,n,i);
            handles.M_all{i} = I.*(handles.image{i}>0);
            handles.S_all{i} = J.*(handles.image{i}>0);
            D = bwdist(handles.image{i} == 0);
            handles.F_all{i} = (max(D(:))-D).*(handles.image{i}>0);
            handles.intframe = handles.sliderpos;
            handles.interdone(i) = 1;
        end
        
                        
        depth = str2double(get(handles.depth_edit,'String'));

        F = round(handles.F_all{i});
        maximum = max(max(F)); check = maximum - depth;
        im = handles.image{i}.*(F <= check);
        [x,y,~,~] = SmothBound(im,1);  
        
        axes(handles.axes5);
        xlabel(''); ylabel('');
        cla;
        hold on;
        imagesc(handles.S_all{i});
        plot(x,y,'k');
        axis equal;
        axis ij;
        axis fill;
        axis off;
        set(handles.axes5,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.text14,'String','Direction map');
        
        axes(handles.axes3);
        cla;
        hold on;
        imagesc(handles.M_all{i});
        plot(x,y,'k');
        axis equal;
        axis ij;
        axis fill;
        axis off;
        set(handles.axes3,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.text6,'String','Interpolated velocity');
        
        axes(handles.axes4);
        cla;
        hold on;
        imagesc(handles.F_all{i});
        plot(x,y,'k');
        axis equal;
        axis ij;
        axis fill;
        axis off;
        set(handles.axes4,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.text7,'String','Distance map');
        
        handles.mode='interior';
        
        set(handles.text11,'Enable','Off');
        set(handles.text12,'Enable','Off');
        set(handles.text15,'Enable','Off');
        set(handles.text16,'Enable','Off');
        set(handles.text17,'Enable','Off');
        set(handles.text18,'Enable','Off');
        set(handles.text19,'Enable','On');
        set(handles.text20,'Enable','On');
        
        set(handles.interior_button,'Enable','On');
        set(handles.interior_all_button,'Enable','On');
        set(handles.edge_save,'Enable','Off');
        set(handles.edge_button,'Enable','Off');
        
        if handles.kymo_done == 1
            set(handles.figures_button,'Enable','Off');
        else
            set(handles.figures_button,'Enable','On');
        end  

        set(handles.xpop,'Enable','Off');
        set(handles.ypop,'Enable','Off');
        set(handles.Xmin,'Enable','Off');
        set(handles.Xmax,'Enable','Off');
        set(handles.Ymin,'Enable','Off');
        set(handles.Ymax,'Enable','Off');
        set(handles.n_edit,'Enable','On');
        set(handles.depth_edit,'Enable','On');
        set(handles.depth_graph,'Enable','On');
        set(handles.depth_save,'Enable','Off');
        set(handles.scale_checkbox,'Enable','Off');
        set(handles.scale_checkbox,'Value',0);
        set(handles.figures_button,'Enable','Off');
        set(handles.save_button,'Enable','Off');
        set(handles.radiobutton2,'Enable','On');
        set(handles.radiobutton2, 'Value', 1);
        
        guidata(hObject,handles);
        
    end
    
function interior_all_button_Callback(hObject, eventdata, handles)
 if handles.processing > 0
    mFRM=handles.framenumber-handles.imagelag;
    depth = str2double(get(handles.depth_edit,'String'));
    set(handles.depth_edit,'String',num2str(depth));
    handles.depth = depth;
    
    VarVal2 = get(handles.ypop,'Value');
    VarVal = get(handles.xpop,'Value');
    
    XN = cell(1,handles.framenumber);
    YN = cell(1,handles.framenumber);
    cx = zeros(1,handles.framenumber);
    cy = zeros(1,handles.framenumber);
    Im_at_depth = cell(1,handles.framenumber);
    
    XM=size(handles.image{1},2);
    YM=size(handles.image{1},1);
    
    [GX,GY]=meshgrid(1:XM,1:YM);

    for i = 1:mFRM
       if handles.interdone(i) == 0
        n = handles.N_inter;
        x = handles.XN{i};
        y = handles.YN{i};
        z = handles.colVel{i};
        [I,J] = interpol(x,y,z,handles.cx(i),handles.cy(i),handles.XM,handles.YM,n,i);
        handles.M_all{i} = I.*(handles.image{i}>0);
        handles.S_all{i} = J.*(handles.image{i}>0);
       end
    end
    
    for i = 1:handles.framenumber
       if handles.interdone(i) == 0    
        D = bwdist(handles.image{i}==0);
        handles.F_all{i} = (max(D(:))-D).*(handles.image{i}>0);
        handles.interdone(i) = 1;
       end
       F = round(handles.F_all{i});
       maximum = max(max(F)); check = maximum - depth;
       Im_at_depth{i} = handles.image{i}.*(F <= check);
       [XN{i},YN{i},~,~] = SmothBound(Im_at_depth{i},1);
       MX = Im_at_depth{i}.*GX;
       MY = Im_at_depth{i}.*GY;
       Mass = sum(Im_at_depth{i}(:));
       cx(i) = sum(MX(:))/Mass;
       cy(i) = sum(MY(:))/Mass;

    end


    handles.XN_depth = XN; handles.YN_depth = YN;

    if VarVal~=VarVal2  

        cNUM=zeros(1,mFRM);

        colInt=cell(1,mFRM);
        colVel=cell(1,mFRM);
        colPos=cell(1,mFRM);

        LocInt=cell(1,mFRM);
        LocVel=cell(1,mFRM);
        LocPos=cell(1,mFRM);

        wait=waitbar(0,['Processing for depth = ' num2str(depth) ' in progress... '],'WindowStyle','modal');

        for i=1:mFRM
            waitbar(i/mFRM);

            Ew = zeros(YM+2*handles.radius,XM+2*handles.radius);
            Ew((handles.radius+1):(handles.radius+YM),(handles.radius+1):(handles.radius+XM)) = Im_at_depth{i};

            cNUM(i)=length(XN{i});        
            db=zeros(1,cNUM(i));
            di=zeros(1,cNUM(i));
            dx=zeros(1,cNUM(i)); dy=zeros(1,cNUM(i));

            LocInt{i}=zeros(1,cNUM(i));
            LocVel{i}=zeros(1,cNUM(i));
            LocPos{i}=zeros(1,cNUM(i));   

            for n=1:cNUM(i)
                di(n)=inpolygon(XN{i}(n),YN{i}(n),XN{i+handles.imagelag},YN{i+handles.imagelag});
                [db(n),dx(n),dy(n)]=DistToBoundU(XN{i}(n),YN{i}(n),XN{i+handles.imagelag},YN{i+handles.imagelag});       
                xt=round(XN{i}(n)); 
                yt=round(YN{i}(n));
                W1=Ew(yt:(yt+2*handles.radius),xt:(xt+2*handles.radius));
                W2=W1.*handles.nbh;
                LocInt{i}(n)=mean(W2(W2>0));
                LocVel{i}(n)=db(n)*sign(di(n)-0.5);
                LocPos{i}(n)=abs(atan2(YN{i}(n)-cy(i),XN{i}(n)-cx(i)));
            end
            colInt{i}=round(1+63*(LocInt{i}-min(LocInt{i}))/(max(LocInt{i})-min(LocInt{i})));
            colVel{i}=round(1+63*(LocVel{i}-min(LocVel{i}))/(max(LocVel{i})-min(LocVel{i})));
            colPos{i}=round(1+63*(LocPos{i}-min(LocPos{i}))/(max(LocPos{i})-min(LocPos{i})));
        end
        close(wait);

        handles.LocVel_depth = LocVel; 
        handles.LocInt_depth = LocInt; 
        handles.LocPos_depth = LocPos;
        handles.cNUM_depth = cNUM;
    end
    
        t = handles.sliderpos;
        
        depth = str2double(get(handles.depth_edit,'String'));

        F = round(handles.F_all{t});
        maximum = max(max(F)); check = maximum - depth;
        im = handles.image{t}.*(F <= check);
        [x,y,~,~] = SmothBound(im,1);  
        
        axes(handles.axes5);
        xlabel(''); ylabel('');
        cla;
        hold on;
        imagesc(handles.S_all{t});
        plot(x,y,'k');
        axis equal;
        axis ij;
        axis fill;
        axis off;
        set(handles.axes5,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.text14,'String','Direction map');
        
        axes(handles.axes3);
        cla;
        hold on;
        imagesc(handles.M_all{t});
        plot(x,y,'k');
        axis equal;
        axis ij;
        axis fill;
        axis off;
        set(handles.axes3,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.text6,'String','Interpolated velocity');
        
        axes(handles.axes4);
        cla;
        hold on;
        imagesc(handles.F_all{t});
        plot(x,y,'k');
        axis equal;
        axis ij;
        axis fill;
        axis off;
        set(handles.axes4,'XLim',[1 handles.XM],'YLim',[1 handles.YM]);
        set(handles.text7,'String','Distance map');
        
        handles.mode='interior';
        
        set(handles.text11,'Enable','Off');
        set(handles.text12,'Enable','Off');
        set(handles.text15,'Enable','Off');
        set(handles.text16,'Enable','Off');
        set(handles.text17,'Enable','Off');
        set(handles.text18,'Enable','Off');
        set(handles.text19,'Enable','On');
        set(handles.text20,'Enable','On');
        
        set(handles.interior_button,'Enable','On');
        set(handles.interior_all_button,'Enable','On');
        set(handles.edge_save,'Enable','Off');
        set(handles.edge_button,'Enable','Off');
        
        if handles.kymo_done == 1
            set(handles.figures_button,'Enable','Off');
        else
            set(handles.figures_button,'Enable','On');
        end    

        set(handles.xpop,'Enable','On');
        set(handles.ypop,'Enable','On');
        set(handles.Xmin,'Enable','Off');
        set(handles.Xmax,'Enable','Off');
        set(handles.Ymin,'Enable','Off');
        set(handles.Ymax,'Enable','Off');
        set(handles.n_edit,'Enable','On');
        set(handles.depth_edit,'Enable','On');
        set(handles.depth_graph,'Enable','On');
        set(handles.scale_checkbox,'Enable','Off');
        set(handles.scale_checkbox,'Value',0);
        set(handles.figures_button,'Enable','Off');
        set(handles.save_button,'Enable','Off');
        set(handles.radiobutton2,'Enable','On');
        set(handles.radiobutton2, 'Value', 1);
        
        
        
        guidata(hObject,handles);        
 end

function n_edit_Callback(hObject, eventdata, handles)

    tmp = str2double(get(hObject,'String'));
    if tmp > 0
        handles.N_inter = tmp;
        handles.interdone = zeros(1,handles.framenumber);
    end
    set(hObject,'String',num2str(handles.N_inter));
    guidata(hObject,handles);
    interior_button_Callback(hObject, eventdata, handles);
    %interior_all_button_Callback(hObject, eventdata, handles)
    

function n_edit_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function kymo_button_Callback(hObject, eventdata, handles)
    depth = str2double(get(handles.depth_edit,'String'));
    tmp = str2double(get(handles.n_edit,'String'));
    if (sum(handles.interdone) ~= handles.framenumber || handles.depth ~= depth) && depth > 0
        msgbox(['Kymographs will be done for Depth ' num2str(handles.depth) ' with hill ' num2str(handles.N_inter)...
            ', to view Kymographs at chosen Depth of ' num2str(depth) ' with Hill ' num2str(tmp) ' do Interior Analysis of All Frames First!']);
    end
    depth_check = 0;

    if (handles.kymo_done==0)||(handles.paramretained==0)
        mFRM = handles.framenumber-handles.imagelag;
        L=zeros(1,mFRM); 

        if sum(handles.interdone) == handles.framenumber && depth > 0 && handles.depth == depth
            depth_check = 1;

            axes(handles.axes5);
            reset(handles.axes5);
            cla;

            axes(handles.axes3);
            reset(handles.axes3);
            cla;

            axes(handles.axes4);
            reset(handles.axes4);
            cla;
        end

        for i=1:(handles.framenumber-handles.imagelag)
            if depth_check == 1 
                L(i)=length(handles.LocInt_depth{i});
            else
                L(i)=length(handles.LocInt{i});
            end    
        end

        N=max(L);
        n=1:N;

        nX=zeros(mFRM,N);   nY=zeros(mFRM,N);   nZ=zeros(mFRM,N);       nV=zeros(mFRM,N);       nU=zeros(mFRM,N);
                                                sZ=zeros(mFRM,N);       sV=zeros(mFRM,N);       sU=zeros(mFRM,N);

        if depth_check == 1 
            x=handles.XN_depth{1};    y=handles.YN_depth{1};    z=handles.LocInt_depth{1};    v=handles.LocVel_depth{1};	u=handles.LocPos_depth{1};
        else 
            x=handles.XN{1};    y=handles.YN{1};    z=handles.LocInt{1};    v=handles.LocVel{1};	u=handles.LocPos{1};
        end

        X=zeros(1,N);       Y=zeros(1,N);       Z=zeros(1,N);           V=zeros(1,N);           U=zeros(1,N);

        t=(L(1)-1)*(n-1)/(N-1);
        s=1+floor(t);    e=1+ceil(t);     t=t+1;
        ii=(e-s)==0;     jj=(e-s)~=0;

        X(ii)=x(s(ii)); Y(ii)=y(s(ii)); Z(ii)=z(s(ii)); V(ii)=v(s(ii));
        X(jj)=x(s(jj))+(t(jj)-s(jj)).*(x(e(jj))-x(s(jj)))./(e(jj)-s(jj));
        Y(jj)=y(s(jj))+(t(jj)-s(jj)).*(y(e(jj))-y(s(jj)))./(e(jj)-s(jj));
        Z(jj)=z(s(jj))+(t(jj)-s(jj)).*(z(e(jj))-z(s(jj)))./(e(jj)-s(jj));
        V(jj)=v(s(jj))+(t(jj)-s(jj)).*(v(e(jj))-v(s(jj)))./(e(jj)-s(jj));
        U(jj)=u(s(jj))+(t(jj)-s(jj)).*(u(e(jj))-u(s(jj)))./(e(jj)-s(jj));

        nX2=X;  nY2=Y;

        nX(1,:)=X;      nY(1,:)=Y;      nZ(1,:)=Z;      nV(1,:)=V;      nU(1,:)=U;
                                        sZ(1,:)=(Z-mean(Z))/std(Z);      
                                        sV(1,:)=(V-mean(V))/std(V);
                                        sU(1,:)=(U-mean(U))/std(U);

        wait=waitbar(1,'Processing in progress... ','WindowStyle','modal');
        for fr=2:mFRM
            waitbar(fr/mFRM);
            nX1=nX2;
            nY1=nY2;

            if depth_check == 1 
                x=handles.XN_depth{fr};    y=handles.YN_depth{fr};    z=handles.LocInt_depth{fr};    v=handles.LocVel_depth{fr};	u=handles.LocPos_depth{fr};
            else 
                x=handles.XN{fr};    y=handles.YN{fr};    z=handles.LocInt{fr};    v=handles.LocVel{fr};	u=handles.LocPos{fr};
            end

            X=zeros(1,N);       Y=zeros(1,N);       Z=zeros(1,N);           V=zeros(1,N);           U=zeros(1,N);

            t=(L(fr)-1)*(n-1)/(N-1);
            s=1+floor(t);     e=1+ceil(t);     t=t+1;
            ii=(e-s)==0;     jj=(e-s)~=0;

            X(ii)=x(s(ii)); Y(ii)=y(s(ii)); Z(ii)=z(s(ii)); V(ii)=v(s(ii));
            X(jj)=x(s(jj))+(t(jj)-s(jj)).*(x(e(jj))-x(s(jj)))./(e(jj)-s(jj));
            Y(jj)=y(s(jj))+(t(jj)-s(jj)).*(y(e(jj))-y(s(jj)))./(e(jj)-s(jj));
            Z(jj)=z(s(jj))+(t(jj)-s(jj)).*(z(e(jj))-z(s(jj)))./(e(jj)-s(jj));
            V(jj)=v(s(jj))+(t(jj)-s(jj)).*(v(e(jj))-v(s(jj)))./(e(jj)-s(jj));
            U(jj)=u(s(jj))+(t(jj)-s(jj)).*(u(e(jj))-u(s(jj)))./(e(jj)-s(jj));

            nX2=X;
            nY2=Y;

            D=zeros(1,N);
            D(1)=sum((nX2-nX1).^2+(nY2-nY1).^2);
            for k=2:N
                tmp1=[nX2(k:N) nX2(1:(k-1))];
                tmp2=[nY2(k:N) nY2(1:(k-1))];
                D(k)=sum((tmp1-nX1).^2+(tmp2-nY1).^2);
            end
            [~,j]=min(D);

            if j==1

                nX(fr,:)=X;     nY(fr,:)=Y;     nZ(fr,:)=Z;     nV(fr,:)=V;     nU(fr,:)=U;
                                                sZ(fr,:)=(Z-mean(Z))/std(Z);      
                                                sV(fr,:)=(V-mean(V))/std(V);
                                                sU(fr,:)=(U-mean(U))/std(U);
            else
                nX2=[nX2(j:N) nX2(1:(j-1))]; 
                nY2=[nY2(j:N) nY2(1:(j-1))]; 

                nX(fr,:)=[X(j:N) X(1:(j-1))];
                nY(fr,:)=[Y(j:N) Y(1:(j-1))];
                nZ(fr,:)=[Z(j:N) Z(1:(j-1))];
                nV(fr,:)=[V(j:N) V(1:(j-1))];
                nU(fr,:)=[U(j:N) U(1:(j-1))];
                sZ(fr,:)=(nZ(fr,:)-mean(nZ(fr,:)))/std(nZ(fr,:));      
                sV(fr,:)=(nV(fr,:)-mean(nV(fr,:)))/std(nV(fr,:));
                sU(fr,:)=(nV(fr,:)-mean(nU(fr,:)))/std(nU(fr,:));
            end

        end
        close(wait);

        handles.nX=nX;
        handles.nY=nY;
        handles.nV=nV;
        handles.nZ=nZ;
        handles.nU=nU;
        handles.sV=sV;
        handles.sZ=sZ;
        handles.sU=sU;
        handles.depth_check = depth_check;
        handles.correl_s = corr_im(handles.sV,handles.sZ,1);
        handles.correl_z = corr_im(handles.nV,handles.nZ,2);

    end    
       
    axes(handles.axes2);
    xlim=get(handles.axes2,'XLim');
    ylim=get(handles.axes2,'YLim');
    cla;
    hold on;
    im=handles.image{handles.sliderpos};%-handles.minI(handles.sliderpos);

    imagesc(im);        
    if (handles.sliderpos+handles.imagelag) <= handles.framenumber
        X=handles.XN{handles.sliderpos+handles.imagelag};
        Y=handles.YN{handles.sliderpos+handles.imagelag};
        plot([X X(1)],[Y Y(1)],'w','LineWidth',2);
    end
    plot(handles.cx(handles.sliderpos),handles.cy(handles.sliderpos),'ko','MarkerFaceColor','w');
    plot(handles.nX(handles.sliderpos,1),handles.nY(handles.sliderpos,1),'wo','MarkerFaceColor','k')
    axis equal;
    axis ij;
    set(handles.axes2,'XLim',xlim);
    set(handles.axes2,'YLim',ylim);
    axis off;      

    axes(handles.axes5);
    reset(handles.axes5);
    cla;
    if get(handles.scale_checkbox,'Value')
        colormap(jet);
        imagesc(handles.correl_s); 
        set(handles.text14,'String',['Unscaled Correlation of Velocity vs Intensity at Depth ' num2str(handles.depth)]);
    else
        colormap(jet);
        imagesc(handles.correl_z); 
        set(handles.text14,'String',['Scaled Correlation of Velocity vs Intensity at Depth ' num2str(handles.depth)]);
    end 
    set(handles.axes5,'XTick',[],'YTick',[],'Box','on');
    axis off; 
    axis fill;
    
    axes(handles.axes3);
    reset(handles.axes3);
    cla;
    if get(handles.scale_checkbox,'Value')
        imagesc(handles.sV);    
    else
        imagesc(handles.nV);    
    end
    set(handles.axes3,'XTick',[],'YTick',[]);
    axis on;    
    xlabel('perimeter (counterclockwise)','FontName','Helvetica','FontUnits','pixels','FontSize',12);
    ylabel('<==  time','FontName','Helvetica','FontUnits','pixels','FontSize',12);
    set(handles.text6,'String',['Velocity kymograph at Depth ' num2str(handles.depth)]);
    
    axes(handles.axes4);
    reset(handles.axes4);
    cla;
    if get(handles.scale_checkbox,'Value')
        imagesc(handles.sZ);    
    else
        imagesc(handles.nZ);    
    end
    set(handles.axes4,'XTick',[],'YTick',[]);
    axis on;   
    xlabel('perimeter (counterclockwise)','FontName','Helvetica','FontUnits','pixels','FontSize',12);
    ylabel('<==  time','FontName','Helvetica','FontUnits','pixels','FontSize',12);    
    set(handles.text7,'String',['Intensity kymograph at Depth ' num2str(handles.depth)]);
    
    handles.kymo_done = 1;
    handles.mode='kymo';
    
    set(handles.text11,'Enable','Off');
    set(handles.text12,'Enable','Off');
    set(handles.text15,'Enable','Off');
    set(handles.text16,'Enable','Off');
    set(handles.text17,'Enable','Off');
    set(handles.text18,'Enable','Off');
    set(handles.text19,'Enable','Off');
    set(handles.text20,'Enable','Off');
        
    if sum(handles.interdone) > 0
        set(handles.interior_button,'Enable','Off');
        set(handles.interior_all_button,'Enable','Off');
    else    
        set(handles.interior_button,'Enable','On');
        set(handles.interior_all_button,'Enable','On');
    end
    set(handles.edge_save,'Enable','Off');
    set(handles.edge_button,'Enable','Off');
    
    set(handles.xpop,'Enable','Off');
    set(handles.ypop,'Enable','Off');
    set(handles.Xmin,'Enable','Off');
    set(handles.Xmax,'Enable','Off');
    set(handles.Ymin,'Enable','Off');
    set(handles.Ymax,'Enable','Off');
    set(handles.Equalize,'Enable','Off');
    set(handles.Orig,'Enable','Off');
    set(handles.n_edit,'Enable','Off');
    set(handles.depth_edit,'Enable','Off');
    set(handles.depth_graph,'Enable','Off');
    set(handles.depth_save,'Enable','Off');
    set(handles.scale_checkbox,'Enable','On');
    set(handles.figures_button,'Enable','On');
    set(handles.save_button,'Enable','On');
    set(handles.radiobutton3,'Enable','On');
    set(handles.radiobutton3, 'Value', 1);
    
    guidata(hObject,handles);

function scale_checkbox_Callback(hObject, eventdata, handles)

    if handles.kymo_done==1

        axes(handles.axes5);
        reset(handles.axes5);
        cla;
        if get(handles.scale_checkbox,'Value')
            colormap(jet);
            imagesc(handles.correl_s);
            set(handles.text14,'String',['Unscaled Correlation of Velocity vs Intensity at Depth ' num2str(handles.depth)]);
        else
            colormap(jet);
            imagesc(handles.correl_z);   
            set(handles.text14,'String',['Scaled Correlation of Velocity vs Intensity at Depth ' num2str(handles.depth)]);
        end 
        set(handles.axes5,'XTick',[],'YTick',[],'Box','on');
        axis off; 
        axis fill;
        
        axes(handles.axes3);
        reset(handles.axes3);
        cla;
        if get(hObject,'Value')
            imagesc(handles.sV);    
        else
            imagesc(handles.nV);    
        end
        set(handles.axes3,'XTick',[],'YTick',[]);
        axis on;    
        xlabel('perimeter (counterclockwise)','FontName','Helvetica','FontUnits','pixels','FontSize',12);
        ylabel('<==  time','FontName','Helvetica','FontUnits','pixels','FontSize',12);
        set(handles.text6,'String',['Velocity kymograph at Depth ' num2str(handles.depth)]);

        axes(handles.axes4);
        reset(handles.axes4);
        cla;
        if get(hObject,'Value')
            imagesc(handles.sZ);    
        else
            imagesc(handles.nZ);    
        end
        set(handles.axes4,'XTick',[],'YTick',[]);
        axis on;   
        xlabel('perimeter (counterclockwise)','FontName','Helvetica','FontUnits','pixels','FontSize',12);
        ylabel('<==  time','FontName','Helvetica','FontUnits','pixels','FontSize',12);    
        set(handles.text7,'String',['Intensity kymograph at Depth ' num2str(handles.depth)]);
        
    end

function viewmode_SelectionChangedFcn(hObject, eventdata, handles)
    tag = get(eventdata.NewValue, 'Tag');
    if strcmp(tag,'radiobutton1') == 1
        handles.mode = 'edge';
        set(handles.edge_button,'Enable','On');
        set(handles.edge_save,'Enable','On');     
        set(handles.text11,'Enable','On');
        set(handles.text12,'Enable','On');
        set(handles.text15,'Enable','On');
        set(handles.text16,'Enable','On');
        set(handles.text17,'Enable','On');
        set(handles.text18,'Enable','On');
        set(handles.xpop,'Enable','On');
        set(handles.ypop,'Enable','On');
        set(handles.Xmin,'Enable','On');
        set(handles.Xmax,'Enable','On');
        set(handles.Ymin,'Enable','On');
        set(handles.Ymax,'Enable','On');
        
        set(handles.Equalize,'Enable','On');
        set(handles.Orig,'Enable','On');

        set(handles.text19,'Enable','Off');
        set(handles.text20,'Enable','Off');
        set(handles.n_edit,'Enable','Off');
        set(handles.depth_edit,'Enable','Off');
        set(handles.depth_graph,'Enable','Off');
        set(handles.depth_save,'Enable','Off');
        
        if sum(handles.interdone) > 0
            set(handles.interior_button,'Enable','Off');
            set(handles.interior_all_button,'Enable','Off');
        else    
            set(handles.interior_button,'Enable','On');
            set(handles.interior_all_button,'Enable','On');
        end
        
        if handles.kymo_done==1
            set(handles.kymo_button,'Enable','Off');
        else    
            set(handles.kymo_button,'Enable','On');
        end
        
        set(handles.save_button,'Enable','Off');
        set(handles.figures_button,'Enable','Off');
        set(handles.scale_checkbox,'Enable','Off');
        
    elseif strcmp(tag,'radiobutton2') == 1
        handles.mode = 'interior';
        set(handles.text19,'Enable','On');
        set(handles.text20,'Enable','On');
        set(handles.n_edit,'Enable','On');
        set(handles.depth_edit,'Enable','On');
        set(handles.depth_graph,'Enable','On');
        set(handles.depth_save,'Enable','Off');
        set(handles.interior_button,'Enable','On');
        set(handles.interior_all_button,'Enable','On');
        
        set(handles.Equalize,'Enable','On');
        set(handles.Orig,'Enable','On');

        if handles.kymo_done==1
            set(handles.kymo_button,'Enable','Off');
        else    
            set(handles.kymo_button,'Enable','On');
        end
        
        set(handles.save_button,'Enable','Off');
        set(handles.figures_button,'Enable','Off');
        set(handles.scale_checkbox,'Enable','Off');
        
        set(handles.edge_button,'Enable','Off');
        set(handles.edge_save,'Enable','Off');     
        set(handles.text11,'Enable','Off');
        set(handles.text12,'Enable','Off');
        set(handles.text15,'Enable','Off');
        set(handles.text16,'Enable','Off');
        set(handles.text17,'Enable','Off');
        set(handles.text18,'Enable','Off');
        set(handles.xpop,'Enable','On');
        set(handles.ypop,'Enable','On');
        set(handles.Xmin,'Enable','Off');
        set(handles.Xmax,'Enable','Off');
        set(handles.Ymin,'Enable','Off');
        set(handles.Ymax,'Enable','Off');
        
    elseif strcmp(tag,'radiobutton3') == 1
        handles.mode = 'kymo';
        set(handles.kymo_button,'Enable','On');
        set(handles.save_button,'Enable','On');
        set(handles.figures_button,'Enable','On');
        set(handles.scale_checkbox,'Enable','On');
        
        set(handles.text19,'Enable','Off');
        set(handles.text20,'Enable','Off');
        set(handles.n_edit,'Enable','Off');
        set(handles.depth_edit,'Enable','Off');
        set(handles.depth_graph,'Enable','Off');
        set(handles.depth_save,'Enable','Off');
        
        if sum(handles.interdone) > 0
            set(handles.interior_button,'Enable','Off');
            set(handles.interior_all_button,'Enable','Off');
        else    
            set(handles.interior_button,'Enable','On');
            set(handles.interior_all_button,'Enable','On');
        end
                
        set(handles.edge_button,'Enable','Off');
        set(handles.edge_save,'Enable','Off');    
        set(handles.text11,'Enable','Off');
        set(handles.text12,'Enable','Off');
        set(handles.text15,'Enable','Off');
        set(handles.text16,'Enable','Off');
        set(handles.text17,'Enable','Off');
        set(handles.text18,'Enable','Off');
        set(handles.xpop,'Enable','Off');
        set(handles.ypop,'Enable','Off');
        set(handles.Xmin,'Enable','Off');
        set(handles.Xmax,'Enable','Off');
        set(handles.Ymin,'Enable','Off');
        set(handles.Ymax,'Enable','Off');
        
        set(handles.Equalize,'Enable','Off');
        set(handles.Orig,'Enable','Off');
    end     
    guidata(hObject,handles);
    switchFrame(hObject, handles, eventdata)
    
function radiobutton1_Callback(hObject, eventdata, handles)
    
function radiobutton2_Callback(hObject, eventdata, handles)

function radiobutton3_Callback(hObject, eventdata, handles)

function edge_save_Callback(hObject, eventdata, handles)

    dlg_title = 'Save edge statistics';
    [FileName,PathName,FilterIndex] = uiputfile('*.mat',dlg_title,'EdgeStat');

    if FilterIndex>0
        
        ver=handles.MeanHist;
        save(fullfile(PathName,FileName),'ver');
                
    end

function offset_edit_Callback(hObject, eventdata, handles)

function offset_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function depth_save_Callback(hObject, eventdata, handles)
    if strcmp(handles.mode,'interior')
        
        dlg_title = 'Save interiror analysis as PNG-files';
        [FileName,PathName,FilterIndex] = uiputfile({'*.png'},dlg_title,'Graph');
        
        if FilterIndex > 0
            VarVal = get(handles.ypop,'Value');
            VarVal2 = get(handles.xpop,'Value');
            if VarVal==1 && VarVal2==2                          
                X='Velocity'; Y='Intensity';
            elseif VarVal==1 && VarVal2==3
                X='Velocity'; Y='Position';
            elseif VarVal==2 && VarVal2==1
                X='Intensity'; Y='Velocity';
            elseif VarVal==2 && VarVal2==3
                X='Intensity'; Y='Position';
            elseif VarVal==3 && VarVal2==1
                X='Position'; Y='Velocity';
            elseif VarVal==3 && VarVal2==2
                X='Position'; Y='Intensity';
            end

            myfolder =  exist([PathName 'Interior Analysis'], 'dir');
            if myfolder == 0
                mkdir([PathName 'Interior Analysis']);
            end

            if ispc
                PathName = [PathName '\Interior Analysis\'];
            else
                PathName = [PathName '/Interior Analysis/'];
            end    
            name = [Y ' vs ' X ' at depth ' get(handles.depth_edit,'String') ' '];
            saveas(handles.current_fig,[PathName name FileName], 'png');
            close(handles.current_fig);
            set(handles.depth_save,'Enable','Off');
        end      
    end 
    guidata(hObject,handles);


function save_button_Callback(hObject, eventdata, handles)

    if handles.kymo_done
        dlg_title = 'Save kymographs as TIF- or PNG-files';
        [FileName,PathName,FilterIndex] = uiputfile({'*.tif';'*.png'},dlg_title,'Kymo');
        
        myfolder =  exist([PathName 'Kymos'], 'dir');
        if myfolder == 0
            mkdir([PathName 'Kymos']);
        end    
        
        if ispc
            PathName = [PathName 'Kymos\'];
        else
            PathName = [PathName 'Kymos/'];
        end    
        
        if FilterIndex>0
            
            nV = handles.nV;
            nV = 65535*(nV - min(nV(:)))/(max(nV(:))-min(nV(:)));
         
            nZ = handles.nZ;
            nZ = 65535*(nZ - min(nZ(:)))/(max(nZ(:))-min(nZ(:)));
         
            sV = handles.sV;
            sV = 65535*(sV - min(sV(:)))/(max(sV(:))-min(sV(:)));
         
            sZ = handles.sZ;
            sZ = 65535*(sZ - min(sZ(:)))/(max(sZ(:))-min(sZ(:)));
            
            correl_s = handles.correl_s;
            correl_s = 65535*(correl_s - min(correl_s(:)))/(max(correl_s(:))-min(correl_s(:)));
            
            correl_z = handles.correl_z;
            correl_z = 65535*(correl_z - min(correl_z(:)))/(max(correl_z(:))-min(correl_z(:)));
        end
        
        if FilterIndex==1
         
            im=uint16(nV);
            imwrite(im,[PathName 'Velocity_' FileName],'Compression','none');
            
            im=uint16(sV);
            imwrite(im,[PathName 'Scaled_Velocity_' FileName],'Compression','none');
            
            im=uint16(nZ);
            imwrite(im,[PathName 'Intensity_' FileName],'Compression','none');
            
            im=uint16(sZ);
            imwrite(im,[PathName 'Scaled_Intensity_' FileName],'Compression','none');
            
            im=uint16(correl_s);
            imwrite(im,[PathName 'Velocity_Intensity_Correlation_' FileName],'Compression','none');
            
            im=uint16(correl_z);
            imwrite(im,[PathName 'Scaled_Velocity_Intensity_Correlation_' FileName],'Compression','none');
        
        elseif FilterIndex==2
            
            
            f=figure;
            colormap(jet);
            imagesc(nV);
            axis ij;
            axis off;
            set(gcf,'PaperPositionMode','auto');
            saveas(gcf,[PathName 'Velocity_' FileName], 'png');
            
            clf;
            imagesc(sV);
            axis ij;
            axis off;
            set(gcf,'PaperPositionMode','auto');
            saveas(gcf,[PathName 'Scaled_Velocity_' FileName], 'png');
            
            clf;
            imagesc(nZ);
            axis ij;
            axis off;
            set(gcf,'PaperPositionMode','auto');
            saveas(gcf,[PathName 'Intensity_' FileName], 'png');
            
            clf;
            imagesc(sZ);
            axis ij;
            axis off;
            set(gcf,'PaperPositionMode','auto');
            saveas(gcf,[PathName 'Scaled_Intensity_' FileName], 'png');
            
            clf;
            imagesc(correl_s);
            axis ij;
            axis off;
            set(gcf,'PaperPositionMode','auto');
            saveas(gcf,[PathName 'Velocity_Intensity_Correlation__' FileName], 'png');
            
            clf;
            imagesc(correl_z);
            axis ij;
            axis off;
            set(gcf,'PaperPositionMode','auto');
            saveas(gcf,[PathName 'Scaled_Velocity_Intensity_Correlation__' FileName], 'png');
            
            close(f);
            
        end
        
    end
    
    
    
%% Additional Functions    
    
function [db,dx,dy]=DistToBoundU(xo,yo,XB,YB)

    LB=length(XB);
    e=zeros(1,LB); xe=zeros(1,LB); ye=zeros(1,LB);
    for k=1:(LB-1)
        
       x1=XB(k); x2=XB(k+1);
       y1=YB(k); y2=YB(k+1);

       u=((xo-x1)*(x2-x1)+(yo-y1)*(y2-y1))/((x2-x1)^2+(y2-y1)^2);

       if u<=0
           e(k)=(xo-x1)^2+(yo-y1)^2;
           xe(k)=x1; ye(k)=y1;
       elseif u>=1
           e(k)=(xo-x2)^2+(yo-y2)^2;
           xe(k)=x2; ye(k)=y2;
       else
           e(k)=(xo-x1-u*(x2-x1))^2+(yo-y1-u*(y2-y1))^2;
           xe(k)=x1+u*(x2-x1); ye(k)=y1+u*(y2-y1);
       end
       
    end

    x1=XB(LB); x2=XB(1);
    y1=YB(LB); y2=YB(1);
    
    u=((xo-x1)*(x2-x1)+(yo-y1)*(y2-y1))/((x2-x1)^2+(y2-y1)^2);

    if u<=0
        e(LB)=(xo-x1)^2+(yo-y1)^2;
        xe(LB)=x1; ye(LB)=y1;
    elseif u>=1
        e(LB)=(xo-x2)^2+(yo-y2)^2;
        xe(LB)=x2; ye(LB)=y2;
    else
        e(LB)=(xo-x1-u*(x2-x1))^2+(yo-y1-u*(y2-y1))^2;
        xe(LB)=x1+u*(x2-x1); ye(LB)=y1+u*(y2-y1);
    end
      
    [mv,mi]=min(e);
    db = sqrt(mv);
    dx = xe(mi);
    dy = ye(mi);
    if db<1e-12
       db=0;
    end	

function Y=GFilterPer(y,n)
 
    if n<=1
        Y=y;
        return;
    end
    
    if mod(n,2)==0
        n=n+1;
    end
    ots=floor(n/2);
    
    gs=(n-1)/6;
    gx = linspace(-3*gs,3*gs,n);
    gf = exp( -(gx.^2)/(2*gs^2) );
    gf = gf / sum(gf);

    Y=y;    
    yy=[y((end-ots+1):end) y y(1:ots)];
    
    for j=1:length(y)
        Y(j)=sum(yy(j:(j+n-1)).*gf);
    end

function [I,J] = interpol(x,y,z,cx,cy,X,Y,n,t)

    I=zeros(Y,X);
    J=zeros(Y,X);
    
    is=floor(min(y));
    ie=ceil(max(y));
    
    js=floor(min(x));
    je=ceil(max(x));
    
    wait=waitbar(0,['Interpolation in progress/Frame ' num2str(t) ' ... ']);
    for i=is:ie
        waitbar((i-is+1)/(ie-is+1));
        for j=js:je            
            d=(j-x).^2+(i-y).^2;            
            I(i,j)=sum(z./(d.^n))/sum(1./(d.^n));
            
            J(i,j)=abs(atan2(i-cy,j-cx));
        end
    end
    close(wait);
    
function [XN,YN,XS,YS]=SmothBound(F,K)

    f=figure;

    F=im2bw(F,0.5); F=+F;
    h=fspecial('gaussian', [5 5], 1);
    G=imfilter(F, h,'replicate');
    SmBound = contour(G,1);  
    
    ii = find(SmBound(1,:)<1);
    [vv, jj] = max(SmBound(2,ii));
    
    bg=ii(jj)+1;
    en=ii(jj)+vv;
    
    XS=SmBound(1,bg:en); YS=SmBound(2,bg:en); %NS=SmBound(2,1);

    DS=sqrt((XS(2:end)-XS(1:(end-1))).^2+(YS(2:end)-YS(1:(end-1))).^2);
    CS=[0 cumsum(DS)];
    L=sum(DS); N=K*round(L);
    r=L/N;

    XN=zeros(1,N); YN=zeros(1,N);
    RD=0; XN(1)=XS(1); YN(1)=YS(1);
    for i=1:(N-1)    
        RD=RD+r;
        [vi, mi]=max(CS(CS<=RD));
        w=RD-vi;
        XN(i+1)=XS(mi)+(XS(mi+1)-XS(mi))*w/DS(mi);
        YN(i+1)=YS(mi)+(YS(mi+1)-YS(mi))*w/DS(mi);    
    end

    XN=fliplr(XN); YN=fliplr(YN);
    close(f);

function [xb,yb,j,tmp,smp,dx,dy] = XY_Plot(cNUM, x, xmin, xmax, y, ymin, ymax, lim)
    
    N=sum(cNUM);
    S=cumsum([0 cNUM]);
    X=zeros(1,N);
    Y=zeros(1,N);
    for counter=1:(lim)
        X((S(counter)+1):S(counter+1))=x{counter}; 
        Y((S(counter)+1):S(counter+1))=y{counter};
    end
    
    %disp(Y);
    cond = (X<=xmax) & (X>=xmin) & (Y<=ymax) & (Y>=ymin);
    %disp((X<xmax) & (X>xmin))
    %disp((Y<ymax) & (Y>ymin))
    %disp(X(cond))
    %disp(Y(cond))
    
    if ~isempty(X(cond)) && ~isempty(Y(cond))
        %disp('in non empty')
        if min(X(cond)) <= max(X(cond)) && min(Y(cond)) <= max(Y(cond))
            %disp('in cond <')
            j=hist3([X(cond)',Y(cond)'],[100 100]);
            xb = linspace(min(X(cond)),max(X(cond)),101);
            yb = linspace(min(Y(cond)),max(Y(cond)),101);
        else
            %disp('in cond >')
            xb=[]; yb=[]; j=[]; tmp=[]; smp=[]; dx=[]; dy=[];
            return;
        end
    else
        %disp('in empty')
        xb=[]; yb=[]; j=[]; tmp=[]; smp=[]; dx=[]; dy=[];
        return;
    end    
    
    tmp=zeros(1,101);
    smp=zeros(1,101);
    dx=xb(2)-xb(1);
    dy=yb(2)-yb(1);

    for counter=1:101
        ver=Y(X>(xb(counter)-dx/2) & X<=(xb(counter)+dx/2) & cond);
        tmp(counter)=median(ver);
        smp(counter)=std(ver);   
        %smp(counter)=std(ver)/sqrt(length(ver));   
    end
    
function R = corr_im(A,B,moda)
    if moda == 1
        display_moda = 'Unscaled';
    else
        display_moda = 'Scaled';
    end
    
    [m,n] = size(A);
    
    R_up_right = zeros(m,n);
    R_up_left = zeros(m,n);
    R_down_right = zeros(m,n);
    R_down_left = zeros(m,n);
    
    %wait=waitbar(0,['Up right corner Correlation in progress, ' display_moda '...']);
    wait=waitbar(0,[display_moda ' kymographs correlation in progress...']);
    count = 1;
    for dx = 1:m
        for dy = n:-1:1
            %waitbar(count/(m*n));
            part_A = A(1:dx,n-dy+1:n);
            part_B = B(m-dx+1:m,1:dy);
            R_up_right(dx,n-dy+1) = corr2(part_A,part_B);
            count = count + 1;
        end
    end  
    waitbar(1/4);
    %close(wait);
    
    %wait=waitbar(0,['Down left corner Correlation in progress, ' display_moda '...']);
    count = 1;
    for dx = m:-1:1
        for dy = 1:n
            %waitbar(count/(m*n));
            part_A = A(m-dx+1:m,1:dy);
            part_B = B(1:dx,n-dy+1:n);
            R_down_left(m-dx+1,dy) = corr2(part_A,part_B);
            count = count + 1;
        end
    end
    waitbar(2/4);
    %close(wait);
    
    %wait=waitbar(0,['Up left corner Correlation in progress, ' display_moda '...']);
    count = 1;
    for dx = 1:m
        for dy = 1:n
            %waitbar(count/(m*n));
            part_A = A(1:dx,1:dy);
            part_B = B(m-dx+1:m,(n-dy+1):n);
            R_up_left(dx,dy) = corr2(part_A,part_B);
            count = count + 1;
        end
    end
    waitbar(3/4);
    %close(wait);
    
    %wait=waitbar(0,['Down right corner Correlation in progress, ' display_moda '...']);
    count = 1;
    for dx = m:-1:1
        for dy = n:-1:1
            %waitbar(count/(m*n));
            part_A = A(m-dx+1:m,(n-dy+1):n);
            part_B = B(1:dx,1:dy);
            R_down_right(m-dx+1,n-dy+1) = corr2(part_A,part_B);
            count = count + 1;
        end
    end
    waitbar(4/4);
    close(wait);
    
    R1 = horzcat(R_up_left,R_up_right); 
    R2 = horzcat(R_down_left,R_down_right);
    
    R = vertcat(R1,R2);

% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_readme_Callback(hObject, eventdata, handles)
% hObject    handle to help_readme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    open('ReadMe.pdf')
