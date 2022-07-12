% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-plot_results-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
%
% Description:
% -----------
%
% plots figures in Feizollah and Tardif (2022) using calculated parameters
% using FWHM_pipe function.
%
% Inputs:
% ------
%
%   results:   structure with results:
%
%        results.label: type of trajectoy:
%                       - 'EPI'
%                       - 'PF-EPI'
%                       - 'Spiral'
%
%        results.B0:    main magnetic field strength (params.B0) in (T):
%                       - 3
%                       - 7
%
%        results.tissue:    type of params.tissue:
%                            - 'WM' for white matter
%                            - 'GM' for grey matter
%
%        results.R: acceleration factor
%
%        results.PSF:   PSF of a single resolution [N,1]
%
%        results.fov:   Field of View in (m)
%
%        results.N: grid size
%
%        results.TE:    the echo time vector (ms)
%
%        results.Res:   vector of simulated resolutions (mm) [Nres,1]
%
%        results.FWHM:  FWHMs for simulated PSFs [Nres,1]
%
%        results.readout_dur:   readout duration for trajectories (ms) [Nres,1]
%
%        results.kloc_phase: trajectory points in PE directions (rad/m) [Nk,1]
%
%        results.kloc_phase_PF: partial Fourier part of trajectory (rad/m)  [Nk,1]
%
%        results.kdata_phase: k-space data in the PE direction  [Nk,1]
%
%        results.kdata_phase_PF:  k-space data of partial Fourier part of trajectory  [Nk,1]
% 
%        results.specificity:   specificity as defined in the article
% 
%        results.sharspennig:   sharpenning as defiend in the article
%
%
%
%
% Outputs:
% -------
%   generates figures:
%
%       readout duration vs nominal resolution
%       TE vs nominal resolution
%       k-space data in PE direction
%       one-sided PSF in PE direction
%       effective resolution vs nominal resolution
%       specificity vs nominal resolution
%       sharpenning vs nominal resolution
%
% Article: Feizollah and Tardif (2022)
% -------
%
% Sajjad Feizollah, July 2022
% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

function plot_results(varargin)


for k=1:length(varargin)
    result{k}=varargin{k};
end

color={
    [166,54,3]/256
    [230,85,13]/256
    [253,141,60]/256
    [0,109,44]/256
    [49,163,84]/256
    [116,196,118]/256
    [8,81,156]/256
    [49,130,189]/256
    [121, 214, 253]/256
    };

if(isfield(result{1},'FWHM'))
    % >>>>>>>>>> readout duration vs nominal resolution <<<<<<<<<<
    
    figure('DefaultAxesFontSize',16)
    hold on
    clear legend_label;
    
    for k=1:length(result)
        plot(result{k}.Res,result{k}.readout_dur,'color',color{k},'LineWidth',6)
        legend_label{k}=strcat(result{k}.label,": ","R=",num2str(result{k}.R));
    end
    for k=1:length(result)
        plot(result{k}.Res,result{k}.readout_dur,'w.','Marker','.','MarkerEdgeColor','k','MarkerSize',18,'LineWidth',4)
    end
    
    grid on
    grid minor
    xlabel('nominal voxel size [mm]','FontWeight','bold')
    ylabel('readout duration [ms]','FontWeight','bold')
    axis([0.5 1.9 0 220])
    xticks(0.5:0.2:1.9)
    yticks(0:20:250)
    legend(legend_label);
    axis square
    
    % >>>>>>>>>> TE vs nominal resolution <<<<<<<<<<
    
    figure('DefaultAxesFontSize',16)
    hold on
    clear legend_label;
    
    for k=1:length(result)
        plot(result{k}.Res,result{k}.TE,'LineWidth',6,'color',color{k})
        legend_label{k}=strcat(result{k}.label,": ","R=",num2str(result{k}.R));
    end
    for k=1:length(result)
        plot(result{k}.Res,result{k}.TE,'w.','Marker','.','MarkerEdgeColor','k','MarkerSize',18,'LineWidth',4)
    end
    
    grid on
    grid minor
    xlabel('nominal voxel size [mm]','FontWeight','bold')
    ylabel('TE [ms]','FontWeight','bold')
    axis([0.5 1.9 30 240])
    axis square
    xticks(0.5:0.2:2)
    yticks(30:20:240)
    legend(legend_label)
    
    % >>>>>>>>>> k-space data vs frequency in PE direction <<<<<<<<<<
    
    figure('DefaultAxesFontSize',16)
    hold on
    clear legend_label
    lgd=legend;
    
    for k=1:length(result)
        dk=result{k}.kloc_phase(2)-result{k}.kloc_phase(1);
        max_kdata=result{k}.kdata_phase(floor(length(result{k}.kdata_phase)/2));
        
        if(result{k}.label~="PF-EPI")
            plot([result{k}.kloc_phase(1)-dk;result{k}.kloc_phase;result{k}.kloc_phase(end)+dk],...
                [0;result{k}.kdata_phase./max_kdata;0],'LineWidth',6,'color',color{k},'LineStyle','-')
        end
        if(result{k}.label=="PF-EPI")
            plot([result{k}.kloc_phase(1)-dk;result{k}.kloc_phase(1:length(result{k}.kloc_phase)-length(result{k}.kloc_phase_PF))],...
                [0;result{k}.kdata_phase(1:length(result{k}.kloc_phase)-length(result{k}.kloc_phase_PF))./max_kdata],'LineWidth',6,'color',color{k})
            lgd.AutoUpdate='off';
            plot([result{k}.kloc_phase(length(result{k}.kloc_phase)-length(result{k}.kloc_phase_PF));sort(result{k}.kloc_phase_PF);result{k}.kloc_phase_PF(1)+dk],...
                [result{k}.kdata_phase(length(result{k}.kloc_phase)-length(result{k}.kloc_phase_PF))./max_kdata;result{k}.kdata_phase_PF./max_kdata;0],'LineWidth',6,'color',color{k},'LineStyle',':')
            lgd.AutoUpdate='on';
        end
        legend_label{k}=strcat(result{k}.label,": ","R=",num2str(result{k}.R));
    end
    
    axis square
    grid on
    grid minor
    title("MTF of "+result{k}.tissue_type+" at "+result{k}.B0+"T")
    xlabel('k_y [rad/m]')
    ylabel('signal amplitude')
    axis([-3500 3500 0 2.05])
    xticks([-3500,-1500,0,1500,3500]);
    lgd.String=(legend_label);
    
    % >>>>>>>>>> normalized on-sided PSF <<<<<<<<<<
    
    figure('DefaultAxesFontSize',16)
    hold on
    clear legend_label
    
    x=(-result{k}.fov*1e3/2):(result{k}.fov*1e3/result{k}.N):(result{k}.fov*1e3/2-result{k}.fov*1e3/result{k}.N);
    
    lgd=legend;
    for k=1:length(result)
        plot(x,real(result{k}.PSF)./max(real(result{k}.PSF)),'LineWidth',6,'LineStyle','-','color',color{k})
        legend_label{k}=strcat(result{k}.label,": R=",num2str(result{k}.R));
    end
    
    axis([0 4 -.25 1])
    xticks(-5:1:5);
    yticks(-.2:.1:1);
    axis square
    grid on
    grid minor
    title("PSF of "+result{k}.tissue_type+" at "+result{k}.B0+"T")
    xlabel('Y [mm]')
    ylabel('normalized amplitude')
    lgd.String=(legend_label);
    axis square
    
    % >>>>>>>>>> effective resolution vs nominal resolution <<<<<<<<<<
    
    figure('DefaultAxesFontSize',16)
    hold on
    clear legend_label;
    
    for k=1:length(result)
        plot(result{k}.Res,result{k}.FWHM,'color',color{k},'LineWidth',4)
        legend_label{k}=strcat(result{k}.label,": R=",num2str(result{k}.R));
    end
    for k=1:length(result)
        plot(result{k}.Res,result{k}.FWHM,'w.','Marker','.','MarkerEdgeColor','k','MarkerSize',14,'LineWidth',4)
    end
    
    grid on
    grid minor
    axis square
    xlabel('nominal resolution [mm]','FontWeight','bold')
    ylabel('effective resolution [mm]','FontWeight','bold')
    axis([0.5 1.9 0.5 2.7])
    xticks(0.5:0.2:1.9)
    yticks(0.5:0.2:2.7)
    lgd=legend(legend_label);
    lgd.AutoUpdate='off';
    title("effective resolution of "+result{k}.tissue_type+" at "+result{k}.B0+"T")
    txt=text(1.25,1.2,'X=Y','FontSize',16,'Color',[0,0,0]+0.05);
    set(txt,'Rotation',35);
    plot(0.5:0.1:2.8,0.5:0.1:2.8,'--','color',[0,0,0]+0.05);
    
    % >>>>>>>>>> generates specificity and sharpenning figures <<<<<<<<<<
    
elseif isfield(result{k},'specificity')
    
    % >>>>>>>>>> specificity vs nominal resolution <<<<<<<<<<
    
    figure('DefaultAxesFontSize',16)
    hold on
    clear legend_label;
    for k=1:length(result)
        plot(result{k}.Res,result{k}.specificity,'color',color{k},'LineWidth',2)
        legend_label{k}=strcat(result{k}.label,": "," R=",num2str(result{k}.R));
    end
    for k=1:length(result)
        plot(result{k}.Res,result{k}.specificity,'w.','Marker','.','MarkerEdgeColor','k','MarkerSize',14,'LineWidth',4)
    end
    
    grid on
    grid minor
    xlabel('nominal voxel size [mm]','FontWeight','bold')
    ylabel('specificity','FontWeight','bold')
    axis([0.5 1.9 0 2.6])
    xticks(0.5:0.2:1.9)
    legend(legend_label);
    axis square
    
    % >>>>>>>>>> sharpenning vs nominal resolution <<<<<<<<<<
    
    figure('DefaultAxesFontSize',16)
    hold on
    clear legend_label;
    for k=1:length(result)
        
        plot(result{k}.Res,result{k}.sharpenning,'color',color{k},'LineWidth',2)
        legend_label{k}=strcat(result{k}.label,": ","R=",num2str(result{k}.R));
    end
    
    for k=1:length(result)
        plot(result{k}.Res,result{k}.sharpenning,'w.','Marker','.','MarkerEdgeColor','k','MarkerSize',14,'LineWidth',4)
    end
    grid on
    grid minor
    xlabel('nominal voxel size [mm]','FontWeight','bold')
    ylabel('sharpening factor','FontWeight','bold')
    axis([0.5 1.9 0 1])
    xticks(0.5:0.2:1.9)
    legend(legend_label);
    axis square
end