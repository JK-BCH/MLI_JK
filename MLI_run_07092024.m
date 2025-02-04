  % 파일 선택 대화 상자 열기
[filenames, pathname] = uigetfile({'*.png;*.jpg;*.jpeg;*.tif;*.bmp', 'Image Files (*.png, *.jpg, *.jpeg, *.tif, *.bmp)'}, 'Select Image Files', 'MultiSelect', 'on');
if isequal(filenames, 0)
    disp('File selection canceled');
    return;
end
% 파일이 하나만 선택된 경우에도 cell array로 처리
if ischar(filenames)
    filenames = {filenames};
end
% 길이와 넓이를 저장할 배열 초기화
allLengths = [];
allAreas = [];

% 각 파일에 대해 처리
for i = 1:length(filenames)
    filename = filenames{i};
    [validLengths, validAreas] = MLI_main_07092024(filename, pathname);
    
      % 결과를 누적
    if isrow(validLengths)
        validLengths = validLengths'; % 행 벡터를 열 벡터로 변환
    end
    if isrow(validAreas)
        validAreas = validAreas'; % 행 벡터를 열 벡터로 변환
    end
    allLengths = [allLengths; validLengths];
    allAreas = [allAreas; validAreas];
    resultStr = sprintf('%s,%.2f,%.2f,%.2f,%.2f', filename, mean(validLengths), std(validLengths), mean(validAreas), std(validAreas));
    disp(resultStr);
end

% 전체 평균과 표준편차 계산
mean_length = mean(allLengths);
std_length = std(allLengths);

meanArea = mean(allAreas);
stdArea = std(allAreas);


resultStr = sprintf('%.2f,%.2f,%.2f,%.2f',mean_length, std_length, meanArea, stdArea);
disp(resultStr);

% 각 파일의 결과를 출력 (옵션)
for i = 1:length(filenames)
    filename = filenames{i};
    
end