function results = sliderThresh_showResults(results)
%function sliderThresh_showResults(results)
%
%jens.schwarzbach@ukr.de
%
%%Example call:
%load './thresholdLogs/Aino-arm_2019-06-28_16-21-38'
%load './thresholdLogs/viola-arm_2019-06-28_15-42-36'
%load './thresholdLogs/viola-bein_2019-06-28_15-44-56'
%load './thresholdLogs/002_T1_ALD_2019-08-06_11-10-55'
%load './thresholdLogsVW/002_T1_ALV_2019-08-06_11-15-36'
%results = sliderThresh_showResults(results)
set(0, 'DefaultAxesFontSize', 16);

%current intensity is provided with a digital value that changes the duty
%cycle of analog PWM output of arduino
%need to transform this to mA
%estimate
[P_digVal2amp, P_amp2digVal] = DS8Rmappings;
%apply estimate
results.intensityAmp = predictValue(results.intensity, P_digVal2amp);


figure
tEnd = results.intensityAmp(end) + 1;
hPatchG = patch( [0 tEnd tEnd 0], [0.5 0.5 4.5 4.5], 'g');
set(hPatchG, 'EdgeColor', 'none', 'FaceAlpha', 0.3)

hPatchY = patch( [0 tEnd tEnd 0], [4.5 4.5 5.5 5.5], 'y');
set(hPatchY, 'EdgeColor', 'none', 'FaceAlpha', 0.3)

hPatchO = patch( [0 tEnd tEnd 0], [5.5 5.5 9.5 9.5], 'w');
set(hPatchO, 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'FaceColor', [1.0000    0.4118    0.1608])

hPatchR = patch( [0 tEnd tEnd 0], [9.5 9.5 10 10], 'r');
set(hPatchR, 'EdgeColor', 'none', 'FaceAlpha', 0.3)
hold on
lh0 = plot(results.intensityAmp, results.aversiveness, 'k', 'LineWidth', 2);
hold on
ph0 = plot(results.intensityAmp, results.aversiveness, 'o');
set(ph0, 'MarkerFaceColor', get(lh0, 'Color'), 'MarkerEdgeColor', 'w', 'LineWidth', 2, 'MarkerSize', 10)
xlabel('intensity [mA]')
ylabel('aversiveness')
box off
idx_painThresh = find((results.aversiveness >=4.5) & (results.aversiveness <=5.5));
tmp = median(results.intensityAmp(idx_painThresh));
if ~isnan(tmp)
    idxNearest = nearest(results.intensityAmp, tmp);
    results.painThreshIntensityAmpMedian = results.intensityAmp(idxNearest);
    results.painThreshIntensityMedian = results.intensity(idxNearest);
else
    results.painThreshIntensityAmpMedian = NaN;
    results.painThreshIntensityMedian = NaN;
end
yl = get(gca, 'ylim');
hold on
plot([results.painThreshIntensityAmpMedian, results.painThreshIntensityAmpMedian], [yl(1), yl(2)], 'k:', 'LineWidth', 2);
hold off
set(gcf, 'name', sprintf('intensity at pain threshold: %5.3f mA (%d)',...
    results.painThreshIntensityAmpMedian, results.painThreshIntensityMedian));

figure
yyaxis right
tEnd = results.time(end) + 1;
hPatchG = patch( [0 tEnd tEnd 0], [0.5 0.5 4.5 4.5], 'g');
set(hPatchG, 'EdgeColor', 'none', 'FaceAlpha', 0.3)

hPatchY = patch( [0 tEnd tEnd 0], [4.5 4.5 5.5 5.5], 'y');
set(hPatchY, 'EdgeColor', 'none', 'FaceAlpha', 0.3)

hPatchO = patch( [0 tEnd tEnd 0], [5.5 5.5 9.5 9.5], 'w');
set(hPatchO, 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'FaceColor', [1.0000    0.4118    0.1608])

hPatchR = patch( [0 tEnd tEnd 0], [9.5 9.5 10 10], 'r');
set(hPatchR, 'EdgeColor', 'none', 'FaceAlpha', 0.3)

hold on
lh2 = plot(results.time', results.aversiveness', 'LineWidth', 2);
hold on
ph2 = plot(results.time', results.aversiveness', 'o', 'MarkerSize', 10);
hold off
set(ph2, 'MarkerFaceColor', get(lh2, 'Color'), 'MarkerEdgeColor', 'w', 'LineWidth', 2, 'MarkerSize', 10)
ylabel('aversiveness')


yyaxis left
lh1 = plot(results.time', results.intensityAmp', 'LineWidth', 4);
hold on
%ph1 = plot(results.time', results.intensityAmp', 'o', 'MarkerSize', 10);
%hold off
%set(ph1, 'MarkerFaceColor', get(lh1, 'Color'), 'MarkerEdgeColor', 'w', 'LineWidth', 2, 'MarkerSize', 10)
xlabel('time [sec]')
ylabel('intensity [mA]')


box off
set(gca, 'xlim', [0, results.time(end)+1])
set(0, 'DefaultAxesFontSize', 'factory');

plot(results.time(idx_painThresh), results.intensityAmp(idx_painThresh), 'ko', 'MarkerFaceColor', 'k');
hold off


set(gcf, 'name', sprintf('intensity at pain threshold: %5.3f mA (%d)',...
    results.painThreshIntensityAmpMedian, results.painThreshIntensityMedian));
%apply parameter estimates to map digital values for PWM to
%amperage of DS8R
function yhat = predictValue(x, P)
yhat = x.^2*P(1) + x*P(2)+P(3);

function [P_digVal2amp, P_amp2digVal] = DS8Rmappings
%estimate parameters of a function that maps digital values for PWM to
%amperage of DS8R
dat4_5_VoltPower = [10	0.2
    100	0.5
    200	2.7
    400	4.7
    500	6
    600	6.2
    700	7.3
    800	7.8
    900	8.3
    1000	9
    1100	9.8
    1200	10.8
    1300	11.3
    1400	12
    1500	12.8
    1600	13.3
    1700	14
    1800	14.6
    1900	15.3
    2000	16.1
    2100	16.8
    2200	17.3
    2300	18.1
    2400	18.8
    2500	19.6
    3000    23.1
    4000    29.4
    5000    36.0
    6000    42.0
    10000   65.7];

dat6_VoltPower=[
    1000	4.7
    1100	5.7
    1200	6.5
    1300	7.3
    1400	8.5
    1500	9
    1600	10
    1700	10.8
    1800	11.8
    1900	12.8
    2000	13.8
    2100	14.6
    2200	15.6
    2300	16.3
    2400	17.1
    2500	17.8
    2600	18.8
    2700	19.8
    2800	20.6
    2900	21.6
    3000	22.6
    3100	23.1
    3200	23.9
    3300	24.6
    3400	25.4
    3500	26.4
    3600	27.4
    3700	28.1
    3800	28.9
    3900	29.9
    4000	30.7
    4100	31.7
    4200	32.4
    4300	33.2
    4400	33.9
    4500	34.9
    4600	35.7
    4700	36.7
    4800	37
    4900	38
    5000	38.7
    5100	39.5
    5200	40.5
    5300	41.2
    5400	41.7
    5500	42.7
    5600	43.8
    5700	44.3
    5800	45.3
    5900	46
    6000	46.8
    6100	47.8
    6200	48.3
    6300	49.3
    6400	50.1
    6500	51.1];

dat = dat6_VoltPower;

x = dat(:, 1);
y = dat(:, 2);

degPol = 2;
P_digVal2amp = polyfit(x,y,degPol);
P_amp2digVal = polyfit(y,x,degPol);


