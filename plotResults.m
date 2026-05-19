% Visualizes the net density distribution of ratings as a single continuous ribbon
masterDataFile = 'CallFile.mat';
 
if exist(masterDataFile, 'file')
    load(masterDataFile, 'allResults');
    

    % Options: 'all', 'left', 'center', 'right'
    targetCondition = 'all'; 
    
    if strcmpi(targetCondition, 'all')
        % Use everything
        filteredRatings = allResults.Rating;
    else
        % Match rows where the Position column matches our target condition
        rowMask = strcmpi(allResults.Position, targetCondition);
        
        % Extract ONLY the ratings that match our true mask locations
        filteredRatings = allResults.Rating(rowMask);
    end
    
    % Safety check: compilation protection if no matches are found
    if isempty(filteredRatings)
        error('No data found matching the position condition: "%s"', targetCondition);
    end
    
    % Calculate the filtered average score
    Score = mean(filteredRatings);
    
    % Define the resolution of your net heatmap line (e.g., 10 bins from 0% to 100%)
    numBins = 10;
    binEdges = linspace(0, 1, numBins + 1);
    binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;
    
    % Count how many data points fall into each slice of the rating scale
    netCounts = histcounts(filteredRatings, binEdges);
    
    % Open figure canvas
    figure('Color', [1 1 1]);
    
    % Draw the net distribution strip (1 row, numBins columns)
    imagesc(binCenters * 100, 1, netCounts);
    
    % Style the net heatmap strip
    colormap('jet');
    c = colorbar;
    c.Label.String = 'Net Concentration (Data Point Count)';
    
    % Format the axes to look like a single clean evaluation scale
    set(gca, 'YTick', [], 'YColor', 'none', 'Box', 'off');
    xlabel('Line Bisection Rating Value (%)');
    
    % CHANGED: Dynamic title to reflect your selected condition split
    title(sprintf('Net Rating Heatmap: %s Position Trials Data Density', upper(targetCondition)));
    
    % Adjust look to make it a distinct, thick horizontal ribbon strip
    pbaspect([5 1 1]); % Sets a wide aspect ratio for the straight line geometry
    
    fprintf('\n=== Net Analysis (%s) ===\n', upper(targetCondition));
    fprintf('Overall Average Rating Score: %.2f%%\n', Score * 100);
    fprintf('Total Data Points Analyzed: %d\n\n', length(filteredRatings));
    
else
    error('Unable to locate the master data file: %s', masterDataFile);
end
