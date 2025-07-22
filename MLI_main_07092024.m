function [validLangths, validAreas] = MLI_main_07092024(filename, pathname, pxsize)
    
    
    %% parameters
    % pxsize = 0.547;  % um/px
    pixelArea = pxsize^2; % µm²
    Outdir = './output/';
    % 출력 디렉토리가 존재하는지 확인하고 없으면 생성
    if ~exist(Outdir, 'dir')
        mkdir(Outdir); % 출력 디렉토리가 존재하지 않으면 생성
    end
    % 현재 날짜와 시간 가져오기
    currentTime = datetime('now');
    
    % 원하는 형식으로 포맷
    formattedTime = datestr(currentTime, 'yymmddHHMMSS');
    
    %% 이미지 읽기 및 전처리
    
    
    % 파일 선택 대화 상자 열기
    % [filename, pathname] = uigetfile({'*.png;*.jpg;*.jpeg;*.tif;*.bmp', 'Image Files (*.png, *.jpg, *.jpeg, *.tif, *.bmp)'}, 'Select an Image File');
    % if isequal(filename, 0)
    %     disp('File selection canceled');
    %     return;
    % end
    filepath = fullfile(pathname, filename);
    image = imread(filepath);
    grayImage = rgb2gray(image);
    binaryImage = imbinarize(grayImage,"adaptive",Sensitivity=0.6);
    binaryImage2 = binaryImage;
    [rows, cols] = size(binaryImage);
    
    
    %% 선 그리기 (15개 선)
    % %빈 이미지 생성 (검은색 배경)
    outputImage = zeros(rows, cols, 'uint8');
    
    % % % % 선 그리기
    % % % numLines = 15;
    % % % lineSpacing = rows / (numLines + 1);
    
    % 선을 80픽셀마다 그리기
    lineSpacing = 80;
    numLines = floor(rows / lineSpacing);
    
    % 선 두께 설정
    lineThickness = 3;
    
    for i = 1:numLines
        y = round(i * lineSpacing);
        % 두께 3px로 선 그리기
        for t = -floor(lineThickness/2):floor(lineThickness/2)
            outputImage(max(1, min(rows, y + t)), :) = 255;
        end
    end
    
    
    
    %% 폐 경계 부분에서 선분의 값을 0으로 설정
    for i = 1:rows
        for j = 1:cols
            if binaryImage(i, j) == 0 && outputImage(i, j, 1) == 255
                outputImage(i, j) = 0; % Red 채널 값 0으로 설정
    
            end
        end
    end
    % % 결과 이미지 표시
    % imshow(binaryImage);
    
    %% 선분들의 길이를 계산하는 함수
        
    labeledImage = bwlabel(outputImage);
    stats = regionprops(labeledImage, 'BoundingBox');
    
    % 각 선분의 길이 계산
    segment_lengths = [];
    for i = 1:numel(stats)
        boundingBox = stats(i).BoundingBox;
        segment_length = boundingBox(3); % BoundingBox의 너비가 선분의 길이
        if segment_length > 3 % 길이가 3보다 큰 경우에만 포함
            segment_lengths = [segment_lengths, segment_length];
        end
    end
    
    
    %%
    outputImage2 = zeros(rows, cols,3 ,'uint8');
    outputImage2(:,:,1) = outputImage;
    % figure;
    % imshow(image); hold on;
    % h = imshow(outputImage2);
    % set(h, 'AlphaData', sum(outputImage2, 3) > 0); % 투명도 조정
    % hold off;
    
    fusedImage = imfuse(image, outputImage2, 'blend');
    imwrite(fusedImage,fullfile(Outdir, [filename '_' formattedTime '_MLI.tif']));
    imwrite(binaryImage,fullfile(Outdir, [filename '_' formattedTime '_Binary.tif']));
    imwrite(outputImage,fullfile(Outdir, [filename '_' formattedTime '_Lines.tif']));
    %% % Area calculation
    % 스무스 필터링 적용 (Gaussian 필터 사용)
    smoothedImage = imgaussfilt(double(binaryImage2), 2); % 2는 필터 크기, 필요에 따라 조정 가능
    thresholdedImage = imbinarize(smoothedImage);
    
    % 도형 찾기
    labeledImage = bwlabel(thresholdedImage);
    stats = regionprops(labeledImage, 'Area', 'Centroid');
    
    % 각 도형의 넓이 계산
    areas = [stats.Area]* pixelArea;
    
    % 넓이 범위 필터링 (10 이상 3000 이하)
    validIndices = find(areas >= 40 & areas <= 3000);
    validAreas = areas(validIndices);
    validStats = stats(validIndices);
    
    
    % imshow(image);
    % title('Smoothed and Thresholded Image');
    % hold on;
    % for k = 1:numel(validStats)
    %     centroid = validStats(k).Centroid;
    %     areaText = sprintf('%.2f µm²', validAreas(k));
    %     text(centroid(1), centroid(2), areaText, 'Color', 'r', 'FontSize',8, 'FontWeight', 'bold');
    % end
    % hold off;
    
    
    %% Print results
    
    mean_length = mean(segment_lengths*pxsize);
    std_length = std(segment_lengths*pxsize);
    
    validLangths= segment_lengths*pxsize;
    meanArea = mean(validAreas);
    stdArea = std(validAreas);
    
    % resultStr = sprintf('Mean Length: %.2f µm, Std Length: %.2f µm, Mean Area: %.2f µm², Std Area: %.2f µm²', mean_length, std_length, meanArea, stdArea);
    % disp(resultStr);
    % resultStr = sprintf('%s_%s,%.2f,%.2f,%.2f,%.2f',formattedTime,filename, mean_length, std_length, meanArea, stdArea);
    % disp(resultStr);

end