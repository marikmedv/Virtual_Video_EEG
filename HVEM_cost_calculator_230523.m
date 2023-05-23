%% 22.05.2022
%HVEM_cost_calculator is the code for calculation of the diferent 
%components of home video-EEG moitoring (HVEM) cost. The code is composed by 3 parts:
%1)Definition of input variables.
%2)Cost calculation without considering possibility of 
%subsequent in-hospital VEM, when HVEM did not achieve its goal.
%3)Cost calculation considering possibility of 
%subsequent in-hospital VEM, when HVEM did not achieve its goal.
%4)Modeling of cost distribution for in-hospital VEM

%% Part 1
%Definition of input variables 
screening_daily_time=4;%time needed for EEG technician to 
%screen 100% of VEEG recorded in 24 hours (hours) 
screening_proportion=0.5; %proportion of VEEG data manually screened
%by EEG technician (from 0 to 1)
LOS_unit=7;% lenght of study unit, as a defoult - week (days)
maxunits=8; %maximum number  of weeks or other study time-units
recording_segment=6;%number of days between electrode reattachments
%by EEG technician
electrode_number=42; %number of EEG+ECG electrodes
salary_technician=31;% monthly salary of EEG-technician ($/hour)
salary_neurologist=134;%monthly salary of neurologist ($/hour)
electrode_attachment_time=1.5;%time takng for EEG-technician 
% to attach electtrode array (hours)
inhospital_testing_time=0.33;%time for testing the array in hospital (hours)
on_line_contact_time=1;%time sspending by EEG-technician for 
% every day on-line patient contact (hours)
patient_education_time=1;%time spending by EEG-technician for 
%instructing the patient patient onse before (or at) the beginning of the HVEM.
caregiver_instructing_time=2;%%time spending by EEG-technician for 
%instructing the patient patient's caregiver onse before (or at) the beginning of the HVEM (hours) 
electrode_cost=1; %the cost of one dysposable electrode ($)
neurologist_hours=8;% time spending by neurologist for one 
%HVEM patient(hours)
technology_percent=0.7;% proportion from basic cost (from 0 to 1)
administrative_percent=0.3;% proportion from basic cost (from 0 to 1)
hosp=13821; %mean cost of in-hospital VEM ($)
hosp_std=526;%standard deviaation of cost of in hospital VEM ($)
prop_adults=[0.2343, 0.4740, 0.6132, 0.7045, 0.7728, 0.8223, 0.8605, 0.89];%proportion
%of adults with epilepsy that achive goal of HVEM per week (or other study time-units) 
prop_children=[0.2909,0.5544,0.6859,0.7695,0.8275,0.8693,0.8994,0.9213];%proportion
%of children with epilepsy that achive goal of HVEM per week (or other study time-units)
inhosp1days_patients=1351;%number of patients with duration of in-hospital monitoring
%no longer than 1 day
inhosp2days_patients=1316;%number of patients with duration of in-hospital monitoring
%2 days
inhosp3days_patients=1047;%number of patients with duration of in-hospital monitoring
%3 days
inhosp4days_patients=823;%number of patients with duration of in-hospital monitoring
%4 days
inhosp5_7days_patients=734;%number of patients with duration of in-hospital monitoring
%5-7 days
proportion_children=0.38;%proportion of children in thee chohort
%% Part 2.
%Cost calculation without considering possibility of 
%subsequent in-hospital VEM, when HVEM did not achieve its goal.
%(Figure 1 in the article)

LOS=zeros(1,maxunits);%prealocation of lenght of study vector
for i=1:maxunits
    LOS(i)=LOS_unit*i;%creation of lenght of study vector 
end

%prealocations of Part 2 output variables
electrode_attachment_days=zeros(size(LOS));
electrode_attachment_hours=zeros(size(LOS));
on_line_contact_hours=zeros(size(LOS));
screening_hours=zeros(size(LOS));
screening_hours_partial=zeros(size(LOS));
hours_technician=zeros(size(LOS));
hours_technician_partial=zeros(size(LOS));
all_electrode_cost=zeros(size(LOS));
technician_cost=zeros(size(LOS));
P_technician_cost=zeros(size(LOS));
HVEEG_basic_cost=zeros(size(LOS));
P_HVEEG_basic_cost=zeros(size(LOS));
technology_cost=zeros(size(LOS));
administrative_cost=zeros(size(LOS));
HVEEG_direct_cost=zeros(size(LOS));
P_HVEEG_direct_cost=zeros(size(LOS));

%calculation of Part 2 output variables
for i=1:maxunits    
    electrode_attachment_days(i)=ceil(LOS(i)/recording_segment);
    
    electrode_attachment_hours(i)=electrode_attachment_days(i)*(electrode_attachment_time+inhospital_testing_time);
    on_line_contact_hours(i)=(LOS(i)-electrode_attachment_days(i))*on_line_contact_time;
    screening_hours(i)=LOS(i)*screening_daily_time;
    screening_hours_partial(i)=LOS(i)*screening_daily_time*screening_proportion;

    hours_technician(i)=electrode_attachment_hours(i)+on_line_contact_hours(i)+screening_hours(i)...
        +patient_education_time;

    hours_technician_partial(i)=electrode_attachment_hours(i)+on_line_contact_hours(i)+screening_hours_partial(i)...
        +patient_education_time+caregiver_instructing_time;

    all_electrode_cost(i)=electrode_attachment_days(i)*electrode_cost*electrode_number;

    technician_cost(i)=salary_technician*hours_technician(i);

    P_technician_cost(i)=salary_technician*hours_technician_partial(i);

    neurologist_cost=neurologist_hours*salary_neurologist;

    HVEEG_basic_cost(i)=all_electrode_cost(i)+technician_cost(i)+neurologist_cost;

    P_HVEEG_basic_cost(i)=all_electrode_cost(i)+P_technician_cost(i)+neurologist_cost;

    technology_cost(i) = technology_percent*HVEEG_basic_cost(i);

    administrative_cost(i) = administrative_percent*HVEEG_basic_cost(i);

    HVEEG_direct_cost(i)=HVEEG_basic_cost(i) + technology_cost(i) + administrative_cost(i);

    P_HVEEG_direct_cost(i)=P_HVEEG_basic_cost(i) + technology_cost(i) + administrative_cost(i);
end

%construction of Part 2 output variables matrix
ALL_COSTS_MAT=...
[electrode_attachment_days;...
electrode_attachment_hours;...
on_line_contact_hours;...
screening_hours;...
screening_hours_partial;...
hours_technician;...
hours_technician_partial;...
all_electrode_cost;...
technician_cost;...
P_technician_cost;...
HVEEG_basic_cost;...
P_HVEEG_basic_cost;...
technology_cost;...
administrative_cost;...
HVEEG_direct_cost;...
P_HVEEG_direct_cost];

%plotting figure of Part 2
home=ALL_COSTS_MAT(end-1:end,:); %HVEM costs for different lenghts of study 
hosp_line=hosp*ones(1,size(LOS,2)+1);
plot_fig_1=[hosp_line;[zeros(2,1),home]];
colorstring = 'brg';
figure(1)
hold on
for i=1:3
x=linspace(0,8,9);
plot(x,plot_fig_1(i,:),'LineWidth',3, 'Color',colorstring(i))
end
legend('In-hospital VEM, 1 week','Home VEM, 100% data manually screened','Home VEM, 50% data manually screened')
grid on
xlabel('Weeks','FontSize',14)
ylabel('USD','FontSize',14)

[hip,pval]=ttest(home(1,:),home(2,:),'Tail','right'); %One side unpaired T test

%% Part 3
%3)Cost calculation considering possibility of 
%subsequent in-hospital VEM, when HVEM did not achieve its goal. This
%output variable is named here general_cost. (Figure 2)
prop=[prop_adults;prop_children]; %prop - proportion
general_cost=zeros(4,8);%prealocation of general_cost
% Calulation of general_cost for adults--------------------------------------------------------------------
general_cost(1,1)=home(1,1)*prop(1,1)+(hosp+home(1,1))*(1-prop(1,1));
general_cost(2,1)=home(2,1)*prop(1,1)+(hosp+home(2,1))*(1-prop(1,1));

general_cost(1,2)=home(1,1)*prop(1,1)+home(1,2)*(prop(1,2)-prop(1,1))+(hosp+home(1,2))*(1-prop(1,2));
general_cost(2,2)=home(2,1)*prop(1,1)+home(2,2)*(prop(1,2)-prop(1,1))+(hosp+home(2,2))*(1-prop(1,2));

general_cost(1,3)=home(1,1)*prop(1,1)+home(1,2)*(prop(1,2)-prop(1,1))+...
    home(1,3)*(prop(1,3)-prop(1,2))+(hosp+home(1,3))*(1-prop(1,3));
general_cost(2,3)=home(2,1)*prop(1,1)+home(2,2)*(prop(1,2)-prop(1,1))+...
    home(2,3)*(prop(1,3)-prop(1,2))+(hosp+home(2,3))*(1-prop(1,3));

general_cost(1,4)=home(1,1)*prop(1,1)+home(1,2)*(prop(1,2)-prop(1,1))+...
    home(1,3)*(prop(1,3)-prop(1,2))+...
    home(1,4)*(prop(1,4)-prop(1,3))+(hosp+home(1,4))*(1-prop(1,4));
general_cost(2,4)=home(1)*prop(1,1)+home(2,2)*(prop(1,2)-prop(1,1))+...
    home(2,3)*(prop(1,3)-prop(1,2))+...
    home(2,4)*(prop(1,4)-prop(1,3))+(hosp+home(2,4))*(1-prop(1,4));


general_cost(1,5)=home(1,1)*prop(1,1)+home(1,2)*(prop(1,2)-prop(1,1))+...
    home(1,3)*(prop(1,3)-prop(1,2))+...
    home(1,4)*(prop(1,4)-prop(1,3))+...
    home(1,5)*(prop(1,5)-prop(1,4))+(hosp+home(1,5))*(1-prop(1,5));
general_cost(2,5)=home(2,1)*prop(1,1)+home(2,2)*(prop(1,2)-prop(1,1))+...
    home(2,3)*(prop(1,3)-prop(1,2))+...
    home(2,4)*(prop(1,4)-prop(1,3))+...
    home(2,5)*(prop(1,5)-prop(1,4))+(hosp+home(2,5))*(1-prop(1,5));

general_cost(1,6)=home(1,1)*prop(1,1)+home(1,2)*(prop(1,2)-prop(1,1))+...
    home(1,3)*(prop(1,3)-prop(1,2))+...
    home(1,4)*(prop(1,4)-prop(1,3))+...
    home(1,5)*(prop(1,5)-prop(1,4))+...
    home(1,6)*(prop(1,6)-prop(1,5))+(hosp+home(1,6))*(1-prop(1,6));
general_cost(2,6)=home(2,1)*prop(1,1)+home(2,2)*(prop(1,2)-prop(1,1))+...
    home(2,3)*(prop(1,3)-prop(1,2))+...
    home(2,4)*(prop(1,4)-prop(1,3))+...
    home(2,5)*(prop(1,5)-prop(1,4))+...
    home(2,6)*(prop(1,6)-prop(1,5))+(hosp+home(2,6))*(1-prop(1,6));

general_cost(1,7)=home(1,1)*prop(1,1)+home(1,2)*(prop(1,2)-prop(1,1))+...
    home(1,3)*(prop(1,3)-prop(1,2))+...
    home(1,4)*(prop(1,4)-prop(1,3))+...
    home(1,5)*(prop(1,5)-prop(1,4))+...
    home(1,6)*(prop(1,6)-prop(1,5))+...
    home(1,7)*(prop(1,7)-prop(1,6))+(hosp+home(1,7))*(1-prop(1,7));
general_cost(2,7)=home(2,1)*prop(1,1)+home(2,2)*(prop(1,2)-prop(1,1))+...
    home(2,3)*(prop(1,3)-prop(1,2))+...
    home(2,4)*(prop(1,4)-prop(1,3))+...
    home(2,5)*(prop(1,5)-prop(1,4))+...
    home(2,6)*(prop(1,6)-prop(1,5))+...
    home(2,7)*(prop(1,7)-prop(1,6))+(hosp+home(2,7))*(1-prop(1,7));

general_cost(1,8)=home(1,1)*prop(1,1)+home(1,2)*(prop(1,2)-prop(1,1))+...
    home(1,3)*(prop(1,3)-prop(1,2))+...
    home(1,4)*(prop(1,4)-prop(1,3))+...
    home(1,5)*(prop(1,5)-prop(1,4))+...
    home(1,6)*(prop(1,6)-prop(1,5))+...
    home(1,7)*(prop(1,7)-prop(1,6))+...
    home(1,8)*(prop(1,8)-prop(1,7))+(hosp+home(1,8))*(1-prop(1,8));
general_cost(2,8)=home(2,1)*prop(1,1)+home(2,2)*(prop(1,2)-prop(1,1))+...
    home(2,3)*(prop(1,3)-prop(1,2))+...
    home(2,4)*(prop(1,4)-prop(1,3))+...
    home(2,5)*(prop(1,5)-prop(1,4))+...
    home(2,6)*(prop(1,6)-prop(1,5))+...
    home(2,7)*(prop(1,7)-prop(1,6))+...
    home(2,8)*(prop(1,8)-prop(1,7))+(hosp+home(2,8))*(1-prop(1,8));

% Calulation of general_cost for children----------------------------------------------------------------
general_cost(3,1)=home(1,1)*prop(2,1)+(hosp+home(1,1))*(1-prop(2,1));
general_cost(4,1)=home(2,1)*prop(2,1)+(hosp+home(2,1))*(1-prop(2,1));

general_cost(3,2)=home(1,1)*prop(2,1)+home(1,2)*(prop(2,2)-prop(2,1))+(hosp+home(1,2))*(1-prop(2,2));
general_cost(4,2)=home(2,1)*prop(2,1)+home(2,2)*(prop(2,2)-prop(2,1))+(hosp+home(2,2))*(1-prop(2,2));

general_cost(3,3)=home(1,1)*prop(2,1)+home(1,2)*(prop(2,2)-prop(2,1))+...
    home(1,3)*(prop(2,3)-prop(2,2))+(hosp+home(1,3))*(1-prop(2,3));
general_cost(4,3)=home(2,1)*prop(2,1)+home(2,2)*(prop(2,2)-prop(2,1))+...
    home(2,3)*(prop(2,3)-prop(2,2))+(hosp+home(2,3))*(1-prop(2,3));

general_cost(3,4)=home(1,1)*prop(2,1)+home(1,2)*(prop(2,2)-prop(2,1))+...
    home(1,3)*(prop(2,3)-prop(2,2))+...
    home(1,4)*(prop(2,4)-prop(2,3))+(hosp+home(1,4))*(1-prop(2,4));
general_cost(4,4)=home(1)*prop(2,1)+home(2,2)*(prop(2,2)-prop(2,1))+...
    home(2,3)*(prop(2,3)-prop(2,2))+...
    home(2,4)*(prop(2,4)-prop(2,3))+(hosp+home(2,4))*(1-prop(2,4));

general_cost(3,5)=home(1,1)*prop(2,1)+home(1,2)*(prop(2,2)-prop(2,1))+...
    home(1,3)*(prop(2,3)-prop(2,2))+...
    home(1,4)*(prop(2,4)-prop(2,3))+...
    home(1,5)*(prop(2,5)-prop(2,4))+(hosp+home(1,5))*(1-prop(2,5));
general_cost(4,5)=home(2,1)*prop(2,1)+home(2,2)*(prop(2,2)-prop(2,1))+...
    home(2,3)*(prop(2,3)-prop(2,2))+...
    home(2,4)*(prop(2,4)-prop(2,3))+...
    home(2,5)*(prop(2,5)-prop(2,4))+(hosp+home(2,5))*(1-prop(2,5));

general_cost(3,6)=home(1,1)*prop(2,1)+home(1,2)*(prop(2,2)-prop(2,1))+...
    home(1,3)*(prop(2,3)-prop(2,2))+...
    home(1,4)*(prop(2,4)-prop(2,3))+...
    home(1,5)*(prop(2,5)-prop(2,4))+...
    home(1,6)*(prop(2,6)-prop(2,5))+(hosp+home(1,6))*(1-prop(2,6));
general_cost(4,6)=home(2,1)*prop(2,1)+home(2,2)*(prop(2,2)-prop(2,1))+...
    home(2,3)*(prop(2,3)-prop(2,2))+...
    home(2,4)*(prop(2,4)-prop(2,3))+...
    home(2,5)*(prop(2,5)-prop(2,4))+...
    home(2,6)*(prop(2,6)-prop(2,5))+(hosp+home(2,6))*(1-prop(2,6));

general_cost(3,7)=home(1,1)*prop(2,1)+home(1,2)*(prop(2,2)-prop(2,1))+...
    home(1,3)*(prop(2,3)-prop(2,2))+...
    home(1,4)*(prop(2,4)-prop(2,3))+...
    home(1,5)*(prop(2,5)-prop(2,4))+...
    home(1,6)*(prop(2,6)-prop(2,5))+...
    home(1,7)*(prop(2,7)-prop(2,6))+(hosp+home(1,7))*(1-prop(2,7));
general_cost(4,7)=home(2,1)*prop(2,1)+home(2,2)*(prop(2,2)-prop(2,1))+...
    home(2,3)*(prop(2,3)-prop(2,2))+...
    home(2,4)*(prop(2,4)-prop(2,3))+...
    home(2,5)*(prop(2,5)-prop(2,4))+...
    home(2,6)*(prop(2,6)-prop(2,5))+...
    home(2,7)*(prop(2,7)-prop(2,6))+(hosp+home(2,7))*(1-prop(2,7));

general_cost(3,8)=home(1,1)*prop(2,1)+home(1,2)*(prop(2,2)-prop(2,1))+...
    home(1,3)*(prop(2,3)-prop(2,2))+...
    home(1,4)*(prop(2,4)-prop(2,3))+...
    home(1,5)*(prop(2,5)-prop(2,4))+...
    home(1,6)*(prop(2,6)-prop(2,5))+...
    home(1,7)*(prop(2,7)-prop(2,6))+...
    home(1,8)*(prop(2,8)-prop(2,7))+(hosp+home(1,8))*(1-prop(2,8));
general_cost(4,8)=home(2,1)*prop(2,1)+home(2,2)*(prop(2,2)-prop(2,1))+...
    home(2,3)*(prop(2,3)-prop(2,2))+...
    home(2,4)*(prop(2,4)-prop(2,3))+...
    home(2,5)*(prop(2,5)-prop(2,4))+...
    home(2,6)*(prop(2,6)-prop(2,5))+...
    home(2,7)*(prop(2,7)-prop(2,6))+...
    home(2,8)*(prop(2,8)-prop(2,7))+(hosp+home(2,8))*(1-prop(2,8));

% Percent change (Figure 3)-----------------------------------------------------------
hosp_4=repmat(hosp,4,1);
hosp_gen_cost=[hosp_4,general_cost];
home_hosp_cost=[hosp_line;hosp_gen_cost];
percent_change=((home_hosp_cost(:,2:end)./home_hosp_cost(:,1:end-1))-1)*100;
colorstring = 'brmgc';
x=linspace(0,8,9);
figure(3)
hold on
plot_fig_3=[zeros(5,1),percent_change]';
for i=1:5
plot (x,plot_fig_3(:,i),'LineWidth',3,'Color',colorstring(i))
end
legend('zero line', 'HVEM-DRE adults, 100% data manually screened','HVEM-DRE adults, 50% data manually screened','HVEM-DRE children, 100% data manually screened','HVEM-DRE children, 50% data manually screened')
grid on
xlabel('Weeks','FontSize',14)
ylabel('Percent of cost change','FontSize',14)

%% Part 4 Modeling of cost distribution for in-hospital VEM

all_patients_number=inhosp1days_patients+inhosp2days_patients...
+inhosp3days_patients+inhosp4days_patients+...
inhosp5_7days_patients; %number of all inhospital patiets

cohort_inhosp_cost=hosp*all_patients_number; %cost of VEM for whole inhospital patient group
error_mat=zeros(20,10000); %prealocation of error matrix
std_mat=zeros(20,10000);%prealocation of standard deviation matrix
mean_mat=zeros(20,10000);%prealocation of mean values matrix
for jnd=1:20
cost_distrib_mat=zeros(all_patients_number,10000);%prealocation of distribution matrix
for ind=1:10000
vcost_cohort=cohort_inhosp_cost*(ind/10000);%variable part of VEM cost for whole inhospital patient group
ccost_cohort=cohort_inhosp_cost-vcost_cohort;%constant part of VEM cost for whole inhospital patient group
vcost_patient=vcost_cohort/all_patients_number;%mean variable part of VEM cost for inhospital patient 
ccost_patient=ccost_cohort/all_patients_number;%constant part of VEM cost for inhospital patient 
 
mean_vcost_patientday=vcost_patient*(inhosp1days_patients+inhosp2days_patients...
+inhosp3days_patients+inhosp4days_patients+inhosp5_7days_patients)...
/(inhosp1days_patients+2*inhosp2days_patients+3*inhosp3days_patients+4*inhosp4days_patients+...
(5+0.1*jnd)*inhosp5_7days_patients); %mean variable part of VEM cost of one day 
% %in hospital of one patient

%vectors of inhospital VEM cost for every patient according to duration of
%VEM
inhosp1days_cost=(mean_vcost_patientday+ccost_patient)*ones(inhosp1days_patients,1);
inhosp2days_cost=(mean_vcost_patientday*2+ccost_patient)*ones(inhosp2days_patients,1);
inhosp3days_cost=(mean_vcost_patientday*3+ccost_patient)*ones(inhosp3days_patients,1);
inhosp4days_cost=(mean_vcost_patientday*4+ccost_patient)*ones(inhosp4days_patients,1);
inhosp5_7days_cost=(mean_vcost_patientday*(5+0.1*jnd)+ccost_patient)*ones(inhosp5_7days_patients,1);

inhosp_cost_distribution= [inhosp1days_cost;inhosp2days_cost;inhosp3days_cost;...
inhosp4days_cost;inhosp5_7days_cost]; %vector of istrimution of inhospital VEM cost

cost_distrib_mat(:,ind)=inhosp_cost_distribution; %matrix of distrimution of inhospital...
%VEM cost 
end
 std_mat(jnd,:)=std(cost_distrib_mat); %construction of  VEM cost standard deviation matrix
 mean_mat(jnd,:)=mean(cost_distrib_mat); %construction of  VEM cost mean values matrix 
 inhosp_std_mean=[std_mat(jnd,:);mean_mat(jnd,:)];%construction of matrix build by std and mean vectors  
 hosp_std_vector=ones(size(std_mat(jnd,:)))*hosp_std; %vector of repeated std inhospital VEM cost value
 hosp_mean_vector=ones(size(mean_mat(jnd,:)))*hosp;%vector of repeated mean inhospital VEM cost value
 repeated_values=[hosp_std_vector;hosp_mean_vector]; %matrix build by vertical 
 %concatination of previous two vectors
 mismach=repeated_values-inhosp_std_mean; %calculation of mismach between
 %reported and modeled values of mean and standard deviation of inhospital
 %VEM cost
 error_vector=abs(mismach(1,:))+abs(mismach(2,:)); %calculation of sum of 
 %mean and std mismaches
 jnd
 error_mat(jnd,:)=error_vector; %construction of error matrix that consist of
 %values of sum of mean and std mismaches
end
min_error=min(min(error_mat)); %minimum value in error matrix
[row_min,column_min]=find(error_mat==min_error);%indices of the minimum value in error matrix 
optim_cost_std=std_mat(row_min,column_min);%std of optimized inhospital cost distribution
optim_cost_mean=mean_mat(row_min,column_min);%mean of optimized inhospital cost distribution 
mean_duration_5_7days=5+row_min*0.1;%optimized mean duration of inhospital VEM in 5-7 days group
vcost_cohort_optimized=cohort_inhosp_cost*(column_min/10000);%optimized variable part 
%of inhospital VEM for whole patient group   
ccost_cohort_optimized=cohort_inhosp_cost-vcost_cohort_optimized;%optimized constant part 
%of inhospital VEM for whole patient group    
vcost_patient_optimized=vcost_cohort_optimized/all_patients_number;%optimized mean variable part 
%of inhospital VEM for a patient    
ccost_patient_optimized=ccost_cohort_optimized/all_patients_number;%optimized constant part 
%of inhospital VEM for a patient   

optimized_vcost_patientday=vcost_patient_optimized*(inhosp1days_patients+inhosp2days_patients...
+inhosp3days_patients+inhosp4days_patients+inhosp5_7days_patients)...
/(inhosp1days_patients+2*inhosp2days_patients+...
3*inhosp3days_patients+4*inhosp4days_patients+...
mean_duration_5_7days*inhosp5_7days_patients);%optimized variable part 
%of inhospital VEM for one patient in one day    

figure (5)%Supplimentary figure S1
x=linspace(1,10000,10000);
xlimit=([1,10000]);
plot (x,error_mat(row_min,:),'LineWidth',3,'Color', 'b')
xlabel('X','FontSize',14)
ylabel('USD','FontSize',14)
legend('Optimization function')

%values of inhospital VEM cost for groups of patients according to VEM
%duration
opt_distribut_cost_1days=(ccost_patient_optimized+optimized_vcost_patientday)*inhosp1days_patients;
opt_distribut_cost_2days=(ccost_patient_optimized+2*optimized_vcost_patientday)*inhosp2days_patients;
opt_distribut_cost_3days=(ccost_patient_optimized+3*optimized_vcost_patientday)*inhosp3days_patients;
opt_distribut_cost_4days=(ccost_patient_optimized+4*optimized_vcost_patientday)*inhosp4days_patients;
opt_distribut_cost_5_7days=(ccost_patient_optimized+mean_duration_5_7days*optimized_vcost_patientday)*inhosp5_7days_patients;

inhosp_opt_gencost_distribution=zeros(1,5);
inhosp_opt_gencost_distribution(1)=opt_distribut_cost_1days;
inhosp_opt_gencost_distribution(2)=opt_distribut_cost_2days;
inhosp_opt_gencost_distribution(3)=opt_distribut_cost_3days;
inhosp_opt_gencost_distribution(4)=opt_distribut_cost_4days;
inhosp_opt_gencost_distribution(5)=opt_distribut_cost_5_7days;

inhosp_patients_perdays_vector=zeros(1,5);
inhosp_patients_perdays_vector(1)=inhosp1days_patients;
inhosp_patients_perdays_vector(2)=inhosp2days_patients;
inhosp_patients_perdays_vector(3)=inhosp3days_patients;
inhosp_patients_perdays_vector(4)=inhosp4days_patients;
inhosp_patients_perdays_vector(5)=inhosp5_7days_patients;

%distribution of cost of inhospital VEN in a patient according to VEM duration. 
inhosp_cost_distrip_perpatient=inhosp_opt_gencost_distribution./inhosp_patients_perdays_vector;

figure(4)
bar (inhosp_cost_distrip_perpatient, 'b')
xlabel('Days','FontSize',14)
ylabel('USD','FontSize',14)

%In-hospital VEM cost distribution between all patients  
INHOSP_ALL_cost_distribution=zeros(all_patients_number,1);
INHOSP_ALL_cost_distribution(1:inhosp_patients_perdays_vector(1))=inhosp_cost_distrip_perpatient(1);
INHOSP_ALL_cost_distribution(inhosp_patients_perdays_vector(1)+1:sum(inhosp_patients_perdays_vector(1:2)))=inhosp_cost_distrip_perpatient(2);
INHOSP_ALL_cost_distribution(sum(inhosp_patients_perdays_vector(1:2))+1:sum(inhosp_patients_perdays_vector(1:3)))=inhosp_cost_distrip_perpatient(3);
INHOSP_ALL_cost_distribution(sum(inhosp_patients_perdays_vector(1:3))+1:sum(inhosp_patients_perdays_vector(1:4)))=inhosp_cost_distrip_perpatient(4);
INHOSP_ALL_cost_distribution(sum(inhosp_patients_perdays_vector(1:4))+1:sum(inhosp_patients_perdays_vector(1:5)))=inhosp_cost_distrip_perpatient(5);

%% Part 5 
%Statistical inference: HVEM for drug resistant epilepsy (DRE),
%taking into account that if goal of HVEM for DRE was not achieved,
%patients were refered to in-hospital VEM.
child_patients_number=round(all_patients_number*proportion_children);%number of 
%children in the cohort 
adults_patients_number=all_patients_number-child_patients_number;%number of 
%adults in the cohort

%Week 1
week_1_adult_distribution=zeros(adults_patients_number,1);%prealocation of 
%adult patients distribution in the first week
week_1_child_distribution=zeros(child_patients_number,1);%prealocation of 
%child patients distribution in the first week
home_cost_1week=home(2,1); %Cost of 1 week of HVEG for 1 patient

%Cost of VEM for one patient who reffered to hospital after 1 weeks HVEM
inhosp_cost_1week_1day=inhosp_cost_distrip_perpatient(1)+home(2,1);%1 day in-hospital monitoring
inhosp_cost_1week_2day=inhosp_cost_distrip_perpatient(2)+home(2,1);%2 days in-hospital monitoring
inhosp_cost_1week_3day=inhosp_cost_distrip_perpatient(3)+home(2,1);%3 days in-hospital monitoring
inhosp_cost_1week_4day=inhosp_cost_distrip_perpatient(4)+home(2,1);%4 days in-hospital monitoring
inhosp_cost_1week_5_7day=inhosp_cost_distrip_perpatient(5)+home(2,1);%5-7 days in-hospital monitoring

%HVEM cost distribution between adult patients at the end of 1 week
week_1_adult_distribution(1:round(prop(1,1)*adults_patients_number))= home_cost_1week;

%Adult patients number reffered to hospital after 1 week of HVEM
inho_adults_w1_day1=round(inhosp1days_patients/all_patients_number*(length(week_1_adult_distribution)-length(find(week_1_adult_distribution))));
inho_adults_w1_day2=round(inhosp2days_patients/all_patients_number*(length(week_1_adult_distribution)-length(find(week_1_adult_distribution))));
inho_adults_w1_day3=round(inhosp3days_patients/all_patients_number*(length(week_1_adult_distribution)-length(find(week_1_adult_distribution))));
inho_adults_w1_day4=round(inhosp4days_patients/all_patients_number*(length(week_1_adult_distribution)-length(find(week_1_adult_distribution))));

%VEM cost distribution between adult patients at the end of 1 week
find_lenght = length(find(week_1_adult_distribution));
week_1_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w1_day1)=inhosp_cost_1week_1day;
find_lenght = length(find(week_1_adult_distribution));
week_1_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w1_day2)=inhosp_cost_1week_2day;
find_lenght = length(find(week_1_adult_distribution));
week_1_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w1_day3)=inhosp_cost_1week_3day;
find_lenght = length(find(week_1_adult_distribution));
week_1_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w1_day4)=inhosp_cost_1week_4day;
find_lenght = length(find(week_1_adult_distribution));
week_1_adult_distribution(find_lenght+1:end)=inhosp_cost_1week_5_7day;

%HVEM cost distribution between child patients at the end of 1 week
week_1_child_distribution(1:round(prop(2,1)*child_patients_number))= home_cost_1week;

%Child patients number reffered to hospital after 1 week of HVEM
inho_child_w1_day1=round(inhosp1days_patients/all_patients_number*(length(week_1_child_distribution)-length(find(week_1_child_distribution))));
inho_child_w1_day2=round(inhosp2days_patients/all_patients_number*(length(week_1_child_distribution)-length(find(week_1_child_distribution))));
inho_child_w1_day3=round(inhosp3days_patients/all_patients_number*(length(week_1_child_distribution)-length(find(week_1_child_distribution))));
inho_child_w1_day4=round(inhosp4days_patients/all_patients_number*(length(week_1_child_distribution)-length(find(week_1_child_distribution))));

%VEM cost distribution between child patients at the end of 1 week
find_lenght = length(find(week_1_child_distribution));
week_1_child_distribution(find_lenght+1:find_lenght+1+inho_child_w1_day1)=inhosp_cost_1week_1day;
find_lenght = length(find(week_1_child_distribution));
week_1_child_distribution(find_lenght+1:find_lenght+1+inho_child_w1_day2)=inhosp_cost_1week_2day;
find_lenght = length(find(week_1_child_distribution));
week_1_child_distribution(find_lenght+1:find_lenght+1+inho_child_w1_day3)=inhosp_cost_1week_3day;
find_lenght = length(find(week_1_child_distribution));
week_1_child_distribution(find_lenght+1:find_lenght+1+inho_child_w1_day4)=inhosp_cost_1week_4day;
find_lenght = length(find(week_1_child_distribution));
week_1_child_distribution(find_lenght+1:end)=inhosp_cost_1week_5_7day;

%VEM cost distribution between all patients at the end of 1 week
ALL_cost_distribution_w1=[week_1_child_distribution; week_1_adult_distribution];

%Week 2
week_2_adult_distribution=zeros(adults_patients_number,1);%prealocation of 
%adult patients distribution in the 2nd week
week_2_child_distribution=zeros(child_patients_number,1);%prealocation of 
%child patients distribution in the 2nd week
home_cost_2week=home(2,2);%Cost of 2 weeks of HVEG for 1 patient

%Cost of VEM for one patient who reffered to hospital after 2 weeks HVEM
inhosp_cost_2week_1day=inhosp_cost_distrip_perpatient(1)+home(2,2);%1 day in-hospital monitoring
inhosp_cost_2week_2day=inhosp_cost_distrip_perpatient(2)+home(2,2);%2 day in-hospital monitoring
inhosp_cost_2week_3day=inhosp_cost_distrip_perpatient(3)+home(2,2);%2 day in-hospital monitoring
inhosp_cost_2week_4day=inhosp_cost_distrip_perpatient(4)+home(2,2);%4 day in-hospital monitoring
inhosp_cost_2week_5_7day=inhosp_cost_distrip_perpatient(5)+home(2,2);%5-7 days in-hospital monitoring

%HVEM cost distribution between adult patients at the end of 2 weeks
week_2_adult_distribution(1:round(prop(1,1)*adults_patients_number))= home_cost_1week;
week_2_adult_distribution(round(prop(1,1)*adults_patients_number)+1:round(prop(1,2)*adults_patients_number))= home_cost_2week;

%Adult patients number reffered to hospital after 2 weeks of HVEM
inho_adults_w2_day1=round(inhosp1days_patients/all_patients_number*(length(week_2_adult_distribution)-length(find(week_2_adult_distribution))));
inho_adults_w2_day2=round(inhosp2days_patients/all_patients_number*(length(week_2_adult_distribution)-length(find(week_2_adult_distribution))));
inho_adults_w2_day3=round(inhosp3days_patients/all_patients_number*(length(week_2_adult_distribution)-length(find(week_2_adult_distribution))));
inho_adults_w2_day4=round(inhosp4days_patients/all_patients_number*(length(week_2_adult_distribution)-length(find(week_2_adult_distribution))));

%VEM cost distribution between adult patients at the end of 2 weeks
find_lenght = length(find(week_2_adult_distribution));
week_2_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w2_day1)=inhosp_cost_2week_1day;
find_lenght = length(find(week_2_adult_distribution));
week_2_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w2_day2)=inhosp_cost_2week_2day;
find_lenght = length(find(week_2_adult_distribution));
week_2_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w2_day3)=inhosp_cost_2week_3day;
find_lenght = length(find(week_2_adult_distribution));
week_2_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w2_day4)=inhosp_cost_2week_4day;
find_lenght = length(find(week_2_adult_distribution));
week_2_adult_distribution(find_lenght+1:end)=inhosp_cost_2week_5_7day;

%HVEM cost distribution between child patients at the end of 2 weeks
week_2_child_distribution(1:round(prop(2,1)*child_patients_number))= home_cost_1week;
week_2_child_distribution(round(prop(2,1)*child_patients_number)+1:round(prop(2,2)*child_patients_number))= home_cost_2week;

%Child patients number reffered to hospital after 2 weeks of HVEM
inho_child_w2_day1=round(inhosp1days_patients/all_patients_number*(length(week_2_child_distribution)-length(find(week_2_child_distribution))));
inho_child_w2_day2=round(inhosp2days_patients/all_patients_number*(length(week_2_child_distribution)-length(find(week_2_child_distribution))));
inho_child_w2_day3=round(inhosp3days_patients/all_patients_number*(length(week_2_child_distribution)-length(find(week_2_child_distribution))));
inho_child_w2_day4=round(inhosp4days_patients/all_patients_number*(length(week_2_child_distribution)-length(find(week_2_child_distribution))));

%VEM cost distribution between child patients at the end of 2 weeks
find_lenght = length(find(week_2_child_distribution));
week_2_child_distribution(find_lenght+1:find_lenght+1+inho_child_w2_day1)=inhosp_cost_2week_1day;
find_lenght = length(find(week_2_child_distribution));
week_2_child_distribution(find_lenght+1:find_lenght+1+inho_child_w2_day2)=inhosp_cost_2week_2day;
find_lenght = length(find(week_2_child_distribution));
week_2_child_distribution(find_lenght+1:find_lenght+1+inho_child_w2_day3)=inhosp_cost_2week_3day;
find_lenght = length(find(week_2_child_distribution));
week_2_child_distribution(find_lenght+1:find_lenght+1+inho_child_w2_day4)=inhosp_cost_2week_4day;
find_lenght = length(find(week_2_child_distribution));
week_2_child_distribution(find_lenght+1:end)=inhosp_cost_2week_5_7day;

%VEM cost distribution between all patients at the end of 2 weeks
ALL_cost_distribution_w2=[week_2_child_distribution; week_2_adult_distribution];

%Week 3 
week_3_adult_distribution=zeros(adults_patients_number,1);%prealocation of 
%adult patients distribution in the 3rd week
week_3_child_distribution=zeros(child_patients_number,1);%prealocation of 
%child patients distribution in the 3rd week
home_cost_3week=home(2,3);%Cost of 3 weeks of HVEG for 1 patient

%Cost of VEM for one patient who reffered to hospital after 3 weeks HVEM
inhosp_cost_3week_1day=inhosp_cost_distrip_perpatient(1)+home(2,3);%1 day in-hospital monitoring
inhosp_cost_3week_2day=inhosp_cost_distrip_perpatient(2)+home(2,3);%2 days in-hospital monitoring
inhosp_cost_3week_3day=inhosp_cost_distrip_perpatient(3)+home(2,3);%3 days in-hospital monitoring
inhosp_cost_3week_4day=inhosp_cost_distrip_perpatient(4)+home(2,3);%4 days in-hospital monitoring
inhosp_cost_3week_5_7day=inhosp_cost_distrip_perpatient(5)+home(2,3);%5-7 days in-hospital monitoring

%HVEM cost distribution between adult patients at the end of 3 weeks
week_3_adult_distribution(1:round(prop(1,1)*adults_patients_number))= home_cost_1week;
week_3_adult_distribution(round(prop(1,1)*adults_patients_number)+1:round(prop(1,2)*adults_patients_number))= home_cost_2week;
week_3_adult_distribution(round(prop(1,2)*adults_patients_number)+1:round(prop(1,3)*adults_patients_number))= home_cost_3week;

%Adult patients number reffered to hospital after 3 weeks of HVEM
inho_adults_w3_day1=round(inhosp1days_patients/all_patients_number*(length(week_3_adult_distribution)-length(find(week_3_adult_distribution))));
inho_adults_w3_day2=round(inhosp2days_patients/all_patients_number*(length(week_3_adult_distribution)-length(find(week_3_adult_distribution))));
inho_adults_w3_day3=round(inhosp3days_patients/all_patients_number*(length(week_3_adult_distribution)-length(find(week_3_adult_distribution))));
inho_adults_w3_day4=round(inhosp4days_patients/all_patients_number*(length(week_3_adult_distribution)-length(find(week_3_adult_distribution))));

%VEM cost distribution between adult patients at the end of 3 weeks
find_lenght = length(find(week_3_adult_distribution));
week_3_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w3_day1)=inhosp_cost_3week_1day;
find_lenght = length(find(week_3_adult_distribution));
week_3_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w3_day2)=inhosp_cost_3week_2day;
find_lenght = length(find(week_3_adult_distribution));
week_3_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w3_day3)=inhosp_cost_3week_3day;
find_lenght = length(find(week_3_adult_distribution));
week_3_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w3_day4)=inhosp_cost_3week_4day;
find_lenght = length(find(week_3_adult_distribution));
week_3_adult_distribution(find_lenght+1:end)=inhosp_cost_3week_5_7day;

%HVEM cost distribution between child patients at the end of 3 weeks
week_3_child_distribution(1:round(prop(2,1)*child_patients_number))= home_cost_1week;
week_3_child_distribution(round(prop(2,1)*child_patients_number)+1:round(prop(2,2)*child_patients_number))= home_cost_2week;
week_3_child_distribution(round(prop(2,2)*child_patients_number)+1:round(prop(2,3)*child_patients_number))= home_cost_3week;

%Child patients number reffered to hospital after 3 weeks of HVEM
inho_child_w3_day1=round(inhosp1days_patients/all_patients_number*(length(week_3_child_distribution)-length(find(week_3_child_distribution))));
inho_child_w3_day2=round(inhosp2days_patients/all_patients_number*(length(week_3_child_distribution)-length(find(week_3_child_distribution))));
inho_child_w3_day3=round(inhosp3days_patients/all_patients_number*(length(week_3_child_distribution)-length(find(week_3_child_distribution))));
inho_child_w3_day4=round(inhosp4days_patients/all_patients_number*(length(week_3_child_distribution)-length(find(week_3_child_distribution))));

%VEM cost distribution between child patients at the end of 3 weeks
find_lenght = length(find(week_3_child_distribution));
week_3_child_distribution(find_lenght+1:find_lenght+1+inho_child_w3_day1)=inhosp_cost_3week_1day;
find_lenght = length(find(week_3_child_distribution));
week_3_child_distribution(find_lenght+1:find_lenght+1+inho_child_w3_day2)=inhosp_cost_3week_2day;
find_lenght = length(find(week_3_child_distribution));
week_3_child_distribution(find_lenght+1:find_lenght+1+inho_child_w3_day3)=inhosp_cost_3week_3day;
find_lenght = length(find(week_3_child_distribution));
week_3_child_distribution(find_lenght+1:find_lenght+1+inho_child_w3_day4)=inhosp_cost_3week_4day;
find_lenght = length(find(week_3_child_distribution));
week_3_child_distribution(find_lenght+1:end)=inhosp_cost_3week_5_7day;

%VEM cost distribution between all patients at the end of 3 weeks
ALL_cost_distribution_w3=[week_3_child_distribution; week_3_adult_distribution];

%Week 4 
week_4_adult_distribution=zeros(adults_patients_number,1);%prealocation of 
%adult patients distribution in the 4th week
week_4_child_distribution=zeros(child_patients_number,1);%prealocation of 
%child patients distribution in the 4th week
home_cost_4week=home(2,4);%Cost of 4 weeks of HVEG for 1 patient

%Cost of VEM for one patient who reffered to hospital after 4 weeks HVEM
inhosp_cost_4week_1day=inhosp_cost_distrip_perpatient(1)+home(2,4);%1 day in-hospital monitoring
inhosp_cost_4week_2day=inhosp_cost_distrip_perpatient(2)+home(2,4);%2 days in-hospital monitoring
inhosp_cost_4week_3day=inhosp_cost_distrip_perpatient(3)+home(2,4);%2 days in-hospital monitoring
inhosp_cost_4week_4day=inhosp_cost_distrip_perpatient(4)+home(2,4);%4 days in-hospital monitoring
inhosp_cost_4week_5_7day=inhosp_cost_distrip_perpatient(5)+home(2,4);%5-7s day in-hospital monitoring

%HVEM cost distribution between adult patients at the end of 4 weeks
week_4_adult_distribution(1:round(prop(1,1)*adults_patients_number))= home_cost_1week;
week_4_adult_distribution(round(prop(1,1)*adults_patients_number)+1:round(prop(1,2)*adults_patients_number))= home_cost_2week;
week_4_adult_distribution(round(prop(1,2)*adults_patients_number)+1:round(prop(1,3)*adults_patients_number))= home_cost_3week;
week_4_adult_distribution(round(prop(1,3)*adults_patients_number)+1:round(prop(1,4)*adults_patients_number))= home_cost_4week;

%Adult patients number reffered to hospital after 4 weeks of HVEM
inho_adults_w4_day1=round(inhosp1days_patients/all_patients_number*(length(week_4_adult_distribution)-length(find(week_4_adult_distribution))));
inho_adults_w4_day2=round(inhosp2days_patients/all_patients_number*(length(week_4_adult_distribution)-length(find(week_4_adult_distribution))));
inho_adults_w4_day3=round(inhosp3days_patients/all_patients_number*(length(week_4_adult_distribution)-length(find(week_4_adult_distribution))));
inho_adults_w4_day4=round(inhosp4days_patients/all_patients_number*(length(week_4_adult_distribution)-length(find(week_4_adult_distribution))));

%VEM cost distribution between adult patients at the end of 4 weeks
find_lenght = length(find(week_4_adult_distribution));
week_4_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w4_day1)=inhosp_cost_4week_1day;
find_lenght = length(find(week_4_adult_distribution));
week_4_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w4_day2)=inhosp_cost_4week_2day;
find_lenght = length(find(week_4_adult_distribution));
week_4_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w4_day3)=inhosp_cost_4week_3day;
find_lenght = length(find(week_4_adult_distribution));
week_4_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w4_day4)=inhosp_cost_4week_4day;
find_lenght = length(find(week_4_adult_distribution));
week_4_adult_distribution(find_lenght+1:end)=inhosp_cost_4week_5_7day;

%HVEM cost distribution between child patients at the end of 4 weeks
week_4_child_distribution(1:round(prop(2,1)*child_patients_number))= home_cost_1week;
week_4_child_distribution(round(prop(2,1)*child_patients_number)+1:round(prop(2,2)*child_patients_number))= home_cost_2week;
week_4_child_distribution(round(prop(2,2)*child_patients_number)+1:round(prop(2,3)*child_patients_number))= home_cost_3week;
week_4_child_distribution(round(prop(2,3)*child_patients_number)+1:round(prop(2,4)*child_patients_number))= home_cost_4week;

%Child patients number reffered to hospital after 4 weeks of HVEM
inho_child_w4_day1=round(inhosp1days_patients/all_patients_number*(length(week_4_child_distribution)-length(find(week_4_child_distribution))));
inho_child_w4_day2=round(inhosp2days_patients/all_patients_number*(length(week_4_child_distribution)-length(find(week_4_child_distribution))));
inho_child_w4_day3=round(inhosp3days_patients/all_patients_number*(length(week_4_child_distribution)-length(find(week_4_child_distribution))));
inho_child_w4_day4=round(inhosp4days_patients/all_patients_number*(length(week_4_child_distribution)-length(find(week_4_child_distribution))));

%VEM cost distribution between child patients at the end of 4 weeks
find_lenght = length(find(week_4_child_distribution));
week_4_child_distribution(find_lenght+1:find_lenght+1+inho_child_w4_day1)=inhosp_cost_4week_1day;
find_lenght = length(find(week_4_child_distribution));
week_4_child_distribution(find_lenght+1:find_lenght+1+inho_child_w4_day2)=inhosp_cost_4week_2day;
find_lenght = length(find(week_4_child_distribution));
week_4_child_distribution(find_lenght+1:find_lenght+1+inho_child_w4_day3)=inhosp_cost_4week_3day;
find_lenght = length(find(week_4_child_distribution));
week_4_child_distribution(find_lenght+1:find_lenght+1+inho_child_w4_day4)=inhosp_cost_4week_4day;
find_lenght = length(find(week_4_child_distribution));
week_4_child_distribution(find_lenght+1:end)=inhosp_cost_4week_5_7day;

%VEM cost distribution between all patients at the end of 4 weeks
ALL_cost_distribution_w4=[week_4_child_distribution; week_4_adult_distribution];

%Week 5 
week_5_adult_distribution=zeros(adults_patients_number,1);%prealocation of 
%adult patients distribution in the 5th week
week_5_child_distribution=zeros(child_patients_number,1);%prealocation of 
%child patients distribution in the 5th week
home_cost_5week=home(2,5);%Cost of 5 weeks of HVEG for 1 patient

%Cost of VEM for one patient who reffered to hospital after 5 weeks HVEM
inhosp_cost_5week_1day=inhosp_cost_distrip_perpatient(1)+home(2,5);%1 day in-hospital monitoring
inhosp_cost_5week_2day=inhosp_cost_distrip_perpatient(2)+home(2,5);%2 days in-hospital monitoring
inhosp_cost_5week_3day=inhosp_cost_distrip_perpatient(3)+home(2,5);%3 days in-hospital monitoring
inhosp_cost_5week_4day=inhosp_cost_distrip_perpatient(4)+home(2,5);%4 days in-hospital monitoring
inhosp_cost_5week_5_7day=inhosp_cost_distrip_perpatient(5)+home(2,5);%5-7 days in-hospital monitoring

%HVEM cost distribution between adult patients at the end of 5 weeks
week_5_adult_distribution(1:round(prop(1,1)*adults_patients_number))= home_cost_1week;
week_5_adult_distribution(round(prop(1,1)*adults_patients_number)+1:round(prop(1,2)*adults_patients_number))= home_cost_2week;
week_5_adult_distribution(round(prop(1,2)*adults_patients_number)+1:round(prop(1,3)*adults_patients_number))= home_cost_3week;
week_5_adult_distribution(round(prop(1,3)*adults_patients_number)+1:round(prop(1,4)*adults_patients_number))= home_cost_4week;
week_5_adult_distribution(round(prop(1,4)*adults_patients_number)+1:round(prop(1,5)*adults_patients_number))= home_cost_5week;

%Adult patients number reffered to hospital after 5 weeks of HVEM
inho_adults_w5_day1=round(inhosp1days_patients/all_patients_number*(length(week_5_adult_distribution)-length(find(week_5_adult_distribution))));
inho_adults_w5_day2=round(inhosp2days_patients/all_patients_number*(length(week_5_adult_distribution)-length(find(week_5_adult_distribution))));
inho_adults_w5_day3=round(inhosp3days_patients/all_patients_number*(length(week_5_adult_distribution)-length(find(week_5_adult_distribution))));
inho_adults_w5_day4=round(inhosp4days_patients/all_patients_number*(length(week_5_adult_distribution)-length(find(week_5_adult_distribution))));

%VEM cost distribution between adult patients at the end of 5 weeks
find_lenght = length(find(week_5_adult_distribution));
week_5_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w5_day1)=inhosp_cost_5week_1day;
find_lenght = length(find(week_5_adult_distribution));
week_5_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w5_day2)=inhosp_cost_5week_2day;
find_lenght = length(find(week_5_adult_distribution));
week_5_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w5_day3)=inhosp_cost_5week_3day;
find_lenght = length(find(week_5_adult_distribution));
week_5_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w5_day4)=inhosp_cost_5week_4day;
find_lenght = length(find(week_5_adult_distribution));
week_5_adult_distribution(find_lenght+1:end)=inhosp_cost_5week_5_7day;

%HVEM cost distribution between child patients at the end of 5 weeks
week_5_child_distribution(1:round(prop(2,1)*child_patients_number))= home_cost_1week;
week_5_child_distribution(round(prop(2,1)*child_patients_number)+1:round(prop(2,2)*child_patients_number))= home_cost_2week;
week_5_child_distribution(round(prop(2,2)*child_patients_number)+1:round(prop(2,3)*child_patients_number))= home_cost_3week;
week_5_child_distribution(round(prop(2,3)*child_patients_number)+1:round(prop(2,4)*child_patients_number))= home_cost_4week;
week_5_child_distribution(round(prop(2,4)*child_patients_number)+1:round(prop(2,5)*child_patients_number))= home_cost_5week;

%Child patients number reffered to hospital after 5 weeks of HVEM
inho_child_w5_day1=round(inhosp1days_patients/all_patients_number*(length(week_5_child_distribution)-length(find(week_5_child_distribution))));
inho_child_w5_day2=round(inhosp2days_patients/all_patients_number*(length(week_5_child_distribution)-length(find(week_5_child_distribution))));
inho_child_w5_day3=round(inhosp3days_patients/all_patients_number*(length(week_5_child_distribution)-length(find(week_5_child_distribution))));
inho_child_w5_day4=round(inhosp4days_patients/all_patients_number*(length(week_5_child_distribution)-length(find(week_5_child_distribution))));

%VEM cost distribution between child patients at the end of 5 weeks
find_lenght = length(find(week_5_child_distribution));
week_5_child_distribution(find_lenght+1:find_lenght+1+inho_child_w5_day1)=inhosp_cost_5week_1day;
find_lenght = length(find(week_5_child_distribution));
week_5_child_distribution(find_lenght+1:find_lenght+1+inho_child_w5_day2)=inhosp_cost_5week_2day;
find_lenght = length(find(week_5_child_distribution));
week_5_child_distribution(find_lenght+1:find_lenght+1+inho_child_w5_day3)=inhosp_cost_5week_3day;
find_lenght = length(find(week_5_child_distribution));
week_5_child_distribution(find_lenght+1:find_lenght+1+inho_child_w5_day4)=inhosp_cost_5week_4day;
find_lenght = length(find(week_5_child_distribution));
week_5_child_distribution(find_lenght+1:end)=inhosp_cost_5week_5_7day;

%VEM cost distribution between all patients at the end of 5 weeks
ALL_cost_distribution_w5=[week_5_child_distribution; week_5_adult_distribution];

%Week 6 
week_6_adult_distribution=zeros(adults_patients_number,1);%prealocation of 
%adult patients distribution in the 6th week
week_6_child_distribution=zeros(child_patients_number,1);%prealocation of 
%child patients distribution in the 6th week
home_cost_6week=home(2,6);%Cost of 6 week of HVEG for 1 patient

%Cost of VEM for one patient who reffered to hospital after 6 weeks HVEM
inhosp_cost_6week_1day=inhosp_cost_distrip_perpatient(1)+home(2,6);%1 day in-hospital monitoring
inhosp_cost_6week_2day=inhosp_cost_distrip_perpatient(2)+home(2,6);%2 days in-hospital monitoring
inhosp_cost_6week_3day=inhosp_cost_distrip_perpatient(3)+home(2,6);%3 days in-hospital monitoring
inhosp_cost_6week_4day=inhosp_cost_distrip_perpatient(4)+home(2,6);%4 days in-hospital monitoring
inhosp_cost_6week_5_7day=inhosp_cost_distrip_perpatient(5)+home(2,6);%5-7 days in-hospital monitoring

%HVEM cost distribution between adult patients at the end of 6 weeks
week_6_adult_distribution(1:round(prop(1,1)*adults_patients_number))= home_cost_1week;
week_6_adult_distribution(round(prop(1,1)*adults_patients_number)+1:round(prop(1,2)*adults_patients_number))= home_cost_2week;
week_6_adult_distribution(round(prop(1,2)*adults_patients_number)+1:round(prop(1,3)*adults_patients_number))= home_cost_3week;
week_6_adult_distribution(round(prop(1,3)*adults_patients_number)+1:round(prop(1,4)*adults_patients_number))= home_cost_4week;
week_6_adult_distribution(round(prop(1,4)*adults_patients_number)+1:round(prop(1,5)*adults_patients_number))= home_cost_5week;
week_6_adult_distribution(round(prop(1,5)*adults_patients_number)+1:round(prop(1,6)*adults_patients_number))= home_cost_6week;

%Adult patients number reffered to hospital after 6 weeks of HVEM
inho_adults_w6_day1=round(inhosp1days_patients/all_patients_number*(length(week_6_adult_distribution)-length(find(week_6_adult_distribution))));
inho_adults_w6_day2=round(inhosp2days_patients/all_patients_number*(length(week_6_adult_distribution)-length(find(week_6_adult_distribution))));
inho_adults_w6_day3=round(inhosp3days_patients/all_patients_number*(length(week_6_adult_distribution)-length(find(week_6_adult_distribution))));
inho_adults_w6_day4=round(inhosp4days_patients/all_patients_number*(length(week_6_adult_distribution)-length(find(week_6_adult_distribution))));

%VEM cost distribution between adult patients at the end of 6 weeks
find_lenght = length(find(week_6_adult_distribution));
week_6_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w6_day1)=inhosp_cost_6week_1day;
find_lenght = length(find(week_6_adult_distribution));
week_6_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w6_day2)=inhosp_cost_6week_2day;
find_lenght = length(find(week_6_adult_distribution));
week_6_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w6_day3)=inhosp_cost_6week_3day;
find_lenght = length(find(week_6_adult_distribution));
week_6_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w6_day4)=inhosp_cost_6week_4day;
find_lenght = length(find(week_6_adult_distribution));
week_6_adult_distribution(find_lenght+1:end)=inhosp_cost_6week_5_7day;

%HVEM cost distribution between child patients at the end of 6 weeks
week_6_child_distribution(1:round(prop(2,1)*child_patients_number))= home_cost_1week;
week_6_child_distribution(round(prop(2,1)*child_patients_number)+1:round(prop(2,2)*child_patients_number))= home_cost_2week;
week_6_child_distribution(round(prop(2,2)*child_patients_number)+1:round(prop(2,3)*child_patients_number))= home_cost_3week;
week_6_child_distribution(round(prop(2,3)*child_patients_number)+1:round(prop(2,4)*child_patients_number))= home_cost_4week;
week_6_child_distribution(round(prop(2,4)*child_patients_number)+1:round(prop(2,5)*child_patients_number))= home_cost_5week;
week_6_child_distribution(round(prop(2,5)*child_patients_number)+1:round(prop(2,6)*child_patients_number))= home_cost_6week;

%Child patients number reffered to hospital after 6 weeks of HVEM
inho_child_w6_day1=round(inhosp1days_patients/all_patients_number*(length(week_6_child_distribution)-length(find(week_6_child_distribution))));
inho_child_w6_day2=round(inhosp2days_patients/all_patients_number*(length(week_6_child_distribution)-length(find(week_6_child_distribution))));
inho_child_w6_day3=round(inhosp3days_patients/all_patients_number*(length(week_6_child_distribution)-length(find(week_6_child_distribution))));
inho_child_w6_day4=round(inhosp4days_patients/all_patients_number*(length(week_6_child_distribution)-length(find(week_6_child_distribution))));

%VEM cost distribution between child patients at the end of 6 weeks
find_lenght = length(find(week_6_child_distribution));
week_6_child_distribution(find_lenght+1:find_lenght+1+inho_child_w6_day1)=inhosp_cost_6week_1day;
find_lenght = length(find(week_6_child_distribution));
week_6_child_distribution(find_lenght+1:find_lenght+1+inho_child_w6_day2)=inhosp_cost_6week_2day;
find_lenght = length(find(week_6_child_distribution));
week_6_child_distribution(find_lenght+1:find_lenght+1+inho_child_w6_day3)=inhosp_cost_6week_3day;
find_lenght = length(find(week_6_child_distribution));
week_6_child_distribution(find_lenght+1:find_lenght+1+inho_child_w6_day4)=inhosp_cost_6week_4day;
find_lenght = length(find(week_6_child_distribution));
week_6_child_distribution(find_lenght+1:end)=inhosp_cost_6week_5_7day;

%VEM cost distribution between all patients at the end of 6 weeks
ALL_cost_distribution_w6=[week_6_child_distribution; week_6_adult_distribution];

%Week 7 
week_7_adult_distribution=zeros(adults_patients_number,1);%prealocation of 
%adult patients distribution in the 7th week
week_7_child_distribution=zeros(child_patients_number,1);%prealocation of 
%child patients distribution in the 7th week
home_cost_7week=home(2,7);%Cost of 7 week of HVEG for 1 patient

%Cost of VEM for one patient who reffered to hospital after 7 weeks HVEM
inhosp_cost_7week_1day=inhosp_cost_distrip_perpatient(1)+home(2,7);%1 day in-hospital monitoring
inhosp_cost_7week_2day=inhosp_cost_distrip_perpatient(2)+home(2,7);%2 day in-hospital monitoring
inhosp_cost_7week_3day=inhosp_cost_distrip_perpatient(3)+home(2,7);%3 day in-hospital monitoring
inhosp_cost_7week_4day=inhosp_cost_distrip_perpatient(4)+home(2,7);%4 day in-hospital monitoring
inhosp_cost_7week_5_7day=inhosp_cost_distrip_perpatient(5)+home(2,7);%5-7 day in-hospital monitoring

%HVEM cost distribution between adult patients at the end of 7 weeks
week_7_adult_distribution(1:round(prop(1,1)*adults_patients_number))= home_cost_1week;
week_7_adult_distribution(round(prop(1,1)*adults_patients_number)+1:round(prop(1,2)*adults_patients_number))= home_cost_2week;
week_7_adult_distribution(round(prop(1,2)*adults_patients_number)+1:round(prop(1,3)*adults_patients_number))= home_cost_3week;
week_7_adult_distribution(round(prop(1,3)*adults_patients_number)+1:round(prop(1,4)*adults_patients_number))= home_cost_4week;
week_7_adult_distribution(round(prop(1,4)*adults_patients_number)+1:round(prop(1,5)*adults_patients_number))= home_cost_5week;
week_7_adult_distribution(round(prop(1,5)*adults_patients_number)+1:round(prop(1,6)*adults_patients_number))= home_cost_6week;
week_7_adult_distribution(round(prop(1,6)*adults_patients_number)+1:round(prop(1,7)*adults_patients_number))= home_cost_7week;

%Adult patients number reffered to hospital after 7 weeks of HVEM
inho_adults_w7_day1=round(inhosp1days_patients/all_patients_number*(length(week_7_adult_distribution)-length(find(week_7_adult_distribution))));
inho_adults_w7_day2=round(inhosp2days_patients/all_patients_number*(length(week_7_adult_distribution)-length(find(week_7_adult_distribution))));
inho_adults_w7_day3=round(inhosp3days_patients/all_patients_number*(length(week_7_adult_distribution)-length(find(week_7_adult_distribution))));
inho_adults_w7_day4=round(inhosp4days_patients/all_patients_number*(length(week_7_adult_distribution)-length(find(week_7_adult_distribution))));

%VEM cost distribution between adult patients at the end of 7 weeks
find_lenght = length(find(week_7_adult_distribution));
week_7_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w7_day1)=inhosp_cost_7week_1day;
find_lenght = length(find(week_7_adult_distribution));
week_7_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w7_day2)=inhosp_cost_7week_2day;
find_lenght = length(find(week_7_adult_distribution));
week_7_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w7_day3)=inhosp_cost_7week_3day;
find_lenght = length(find(week_7_adult_distribution));
week_7_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w7_day4)=inhosp_cost_7week_4day;
find_lenght = length(find(week_7_adult_distribution));
week_7_adult_distribution(find_lenght+1:end)=inhosp_cost_7week_5_7day;

%HVEM cost distribution between child patients at the end of 7 weeks
week_7_child_distribution(1:round(prop(2,1)*child_patients_number))= home_cost_1week;
week_7_child_distribution(round(prop(2,1)*child_patients_number)+1:round(prop(2,2)*child_patients_number))= home_cost_2week;
week_7_child_distribution(round(prop(2,2)*child_patients_number)+1:round(prop(2,3)*child_patients_number))= home_cost_3week;
week_7_child_distribution(round(prop(2,3)*child_patients_number)+1:round(prop(2,4)*child_patients_number))= home_cost_4week;
week_7_child_distribution(round(prop(2,4)*child_patients_number)+1:round(prop(2,5)*child_patients_number))= home_cost_5week;
week_7_child_distribution(round(prop(2,5)*child_patients_number)+1:round(prop(2,6)*child_patients_number))= home_cost_6week;
week_7_child_distribution(round(prop(2,6)*child_patients_number)+1:round(prop(2,7)*child_patients_number))= home_cost_7week;

%Child patients number reffered to hospital after 7 weeks of HVEM
inho_child_w7_day1=round(inhosp1days_patients/all_patients_number*(length(week_7_child_distribution)-length(find(week_7_child_distribution))));
inho_child_w7_day2=round(inhosp2days_patients/all_patients_number*(length(week_7_child_distribution)-length(find(week_7_child_distribution))));
inho_child_w7_day3=round(inhosp3days_patients/all_patients_number*(length(week_7_child_distribution)-length(find(week_7_child_distribution))));
inho_child_w7_day4=round(inhosp4days_patients/all_patients_number*(length(week_7_child_distribution)-length(find(week_7_child_distribution))));

%VEM cost distribution between child patients at the end of 7 weeks
find_lenght = length(find(week_7_child_distribution));
week_7_child_distribution(find_lenght+1:find_lenght+1+inho_child_w7_day1)=inhosp_cost_7week_1day;
find_lenght = length(find(week_7_child_distribution));
week_7_childdistribution(find_lenght+1:find_lenght+1+inho_child_w7_day2)=inhosp_cost_7week_2day;
find_lenght = length(find(week_7_child_distribution));
week_7_child_distribution(find_lenght+1:find_lenght+1+inho_child_w7_day3)=inhosp_cost_7week_3day;
find_lenght = length(find(week_7_child_distribution));
week_7_child_distribution(find_lenght+1:find_lenght+1+inho_child_w7_day4)=inhosp_cost_7week_4day;
find_lenght = length(find(week_7_child_distribution));
week_7_child_distribution(find_lenght+1:end)=inhosp_cost_7week_5_7day;

%VEM cost distribution between all patients at the end of 7 weeks
ALL_cost_distribution_w7=[week_7_child_distribution; week_7_adult_distribution];

%Week 8 
week_8_adult_distribution=zeros(adults_patients_number,1);%prealocation of 
%adult patients distribution in the 8th week
week_8_child_distribution=zeros(child_patients_number,1);%prealocation of 
%child patients distribution in the 8th week
home_cost_8week=home(2,8);%Cost of 8 week of HVEG for 1 patient

%Cost of VEM for patient who refert to hospital after 8 weeks HVEM
inhosp_cost_8week_1day=inhosp_cost_distrip_perpatient(1)+home(2,8);%1 day in-hospital monitoring
inhosp_cost_8week_2day=inhosp_cost_distrip_perpatient(2)+home(2,8);%2 day in-hospital monitoring
inhosp_cost_8week_3day=inhosp_cost_distrip_perpatient(3)+home(2,8);%3 day in-hospital monitoring
inhosp_cost_8week_4day=inhosp_cost_distrip_perpatient(4)+home(2,8);%4 day in-hospital monitoring
inhosp_cost_8week_5_7day=inhosp_cost_distrip_perpatient(5)+home(2,8);%5-7 day in-hospital monitoring

%HVEM cost distribution between adult patients at the end of 8 weeks
week_8_adult_distribution(1:round(prop(1,1)*adults_patients_number))= home_cost_1week;
week_8_adult_distribution(round(prop(1,1)*adults_patients_number)+1:round(prop(1,2)*adults_patients_number))= home_cost_2week;
week_8_adult_distribution(round(prop(1,2)*adults_patients_number)+1:round(prop(1,3)*adults_patients_number))= home_cost_3week;
week_8_adult_distribution(round(prop(1,3)*adults_patients_number)+1:round(prop(1,4)*adults_patients_number))= home_cost_4week;
week_8_adult_distribution(round(prop(1,4)*adults_patients_number)+1:round(prop(1,5)*adults_patients_number))= home_cost_5week;
week_8_adult_distribution(round(prop(1,5)*adults_patients_number)+1:round(prop(1,6)*adults_patients_number))= home_cost_6week;
week_8_adult_distribution(round(prop(1,6)*adults_patients_number)+1:round(prop(1,7)*adults_patients_number))= home_cost_7week;
week_8_adult_distribution(round(prop(1,7)*adults_patients_number)+1:round(prop(1,8)*adults_patients_number))= home_cost_8week;

%Adult patients number reffered to hospital after 8 weeks of HVEM
inho_adults_w8_day1=round(inhosp1days_patients/all_patients_number*(length(week_8_adult_distribution)-length(find(week_8_adult_distribution))));
inho_adults_w8_day2=round(inhosp2days_patients/all_patients_number*(length(week_8_adult_distribution)-length(find(week_8_adult_distribution))));
inho_adults_w8_day3=round(inhosp3days_patients/all_patients_number*(length(week_8_adult_distribution)-length(find(week_8_adult_distribution))));
inho_adults_w8_day4=round(inhosp4days_patients/all_patients_number*(length(week_8_adult_distribution)-length(find(week_8_adult_distribution))));

%VEM cost distribution between adult patients at the end of 8 weeks
find_lenght = length(find(week_8_adult_distribution));
week_8_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w8_day1)=inhosp_cost_8week_1day;
find_lenght = length(find(week_8_adult_distribution));
week_8_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w8_day2)=inhosp_cost_8week_2day;
find_lenght = length(find(week_8_adult_distribution));
week_8_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w8_day3)=inhosp_cost_8week_3day;
find_lenght = length(find(week_8_adult_distribution));
week_8_adult_distribution(find_lenght+1:find_lenght+1+inho_adults_w8_day4)=inhosp_cost_8week_4day;
find_lenght = length(find(week_8_adult_distribution));
week_8_adult_distribution(find_lenght+1:end)=inhosp_cost_8week_5_7day;

%HVEM cost distribution between child patients at the end of 8 weeks
week_8_child_distribution(1:round(prop(2,1)*child_patients_number))= home_cost_1week;
week_8_child_distribution(round(prop(2,1)*child_patients_number)+1:round(prop(2,2)*child_patients_number))= home_cost_2week;
week_8_child_distribution(round(prop(2,2)*child_patients_number)+1:round(prop(2,3)*child_patients_number))= home_cost_3week;
week_8_child_distribution(round(prop(2,3)*child_patients_number)+1:round(prop(2,4)*child_patients_number))= home_cost_4week;
week_8_child_distribution(round(prop(2,4)*child_patients_number)+1:round(prop(2,5)*child_patients_number))= home_cost_5week;
week_8_child_distribution(round(prop(2,5)*child_patients_number)+1:round(prop(2,6)*child_patients_number))= home_cost_6week;
week_8_child_distribution(round(prop(2,6)*child_patients_number)+1:round(prop(2,7)*child_patients_number))= home_cost_7week;
week_8_child_distribution(round(prop(2,7)*child_patients_number)+1:round(prop(2,8)*child_patients_number))= home_cost_8week;

%Child patients number reffered to hospital after 8 weeks of HVEM
inho_child_w8_day1=round(inhosp1days_patients/all_patients_number*(length(week_8_child_distribution)-length(find(week_8_child_distribution))));
inho_child_w8_day2=round(inhosp2days_patients/all_patients_number*(length(week_8_child_distribution)-length(find(week_8_child_distribution))));
inho_child_w8_day3=round(inhosp3days_patients/all_patients_number*(length(week_8_child_distribution)-length(find(week_8_child_distribution))));
inho_child_w8_day4=round(inhosp4days_patients/all_patients_number*(length(week_8_child_distribution)-length(find(week_8_child_distribution))));

%VEM cost distribution between child patients at the end of 8 weeks
find_lenght = length(find(week_8_child_distribution));
week_8_child_distribution(find_lenght+1:find_lenght+1+inho_child_w8_day1)=inhosp_cost_8week_1day;
find_lenght = length(find(week_8_child_distribution));
week_8_child_distribution(find_lenght+1:find_lenght+1+inho_child_w8_day2)=inhosp_cost_8week_2day;
find_lenght = length(find(week_8_child_distribution));
week_8_child_distribution(find_lenght+1:find_lenght+1+inho_child_w8_day3)=inhosp_cost_8week_3day;
find_lenght = length(find(week_8_child_distribution));
week_8_child_distribution(find_lenght+1:find_lenght+1+inho_child_w8_day4)=inhosp_cost_8week_4day;
find_lenght = length(find(week_8_child_distribution));
week_8_child_distribution(find_lenght+1:end)=inhosp_cost_8week_5_7day;

%VEM cost distribution between all patients at the end of 8 weeks
ALL_cost_distribution_w8=[week_8_child_distribution; week_8_adult_distribution];

%Mean values of all cost distributions per week
mean_w1=mean(ALL_cost_distribution_w1);
mean_w2=mean(ALL_cost_distribution_w2);
mean_w3=mean(ALL_cost_distribution_w3);
mean_w4=mean(ALL_cost_distribution_w4);
mean_w5=mean(ALL_cost_distribution_w5);
mean_w6=mean(ALL_cost_distribution_w6);
mean_w7=mean(ALL_cost_distribution_w7);
mean_w8=mean(ALL_cost_distribution_w8);

mean_HVEM_vector=[hosp;mean_w1;mean_w2;mean_w3;mean_w4;mean_w5;mean_w6;mean_w7;mean_w8];

home_hosp_cost=home_hosp_cost';
DRE_home_host=[hosp_line',home_hosp_cost(:,2:5),mean_HVEM_vector];
x=linspace(0,8,9);
colorstring = 'brmgcy';
figure (2)
hold on
for i=1:6
plot(x,DRE_home_host(:,i),'LineWidth',3,'Color',colorstring(i))
end
legend('In-hospital VEM, 1 week', 'HVEM-DRE adults, 100% data manually screened','HVEM-DRE adults, 50% data manually screened','HVEM-DRE children, 100% data manually screened','HVEM-DRE children, 50% data manually screened','HVEM-DRE based on Slater et al, 2019')
grid on
xlabel('Weeks','FontSize',14)
ylabel('USD','FontSize',14)

%Standard deviation values of all cost distributions per week
std_w1=std(ALL_cost_distribution_w1);
std_w2=std(ALL_cost_distribution_w2);
std_w3=std(ALL_cost_distribution_w3);
std_w4=std(ALL_cost_distribution_w4);
std_w5=std(ALL_cost_distribution_w5);
std_w6=std(ALL_cost_distribution_w6);
std_w7=std(ALL_cost_distribution_w7);
std_w8=std(ALL_cost_distribution_w8);

%two sample T-test
[h1,p1]=ttest2(ALL_cost_distribution_w1,INHOSP_ALL_cost_distribution);
[h2,p2]=ttest2(ALL_cost_distribution_w2,INHOSP_ALL_cost_distribution);
[h3,p3]=ttest2(ALL_cost_distribution_w3,INHOSP_ALL_cost_distribution);
[h4,p4]=ttest2(ALL_cost_distribution_w4,INHOSP_ALL_cost_distribution);
[h5,p5]=ttest2(ALL_cost_distribution_w5,INHOSP_ALL_cost_distribution);
[h6,p6]=ttest2(ALL_cost_distribution_w6,INHOSP_ALL_cost_distribution);
[h7,p7]=ttest2(ALL_cost_distribution_w7,INHOSP_ALL_cost_distribution);
[h8,p8]=ttest2(ALL_cost_distribution_w8,INHOSP_ALL_cost_distribution);