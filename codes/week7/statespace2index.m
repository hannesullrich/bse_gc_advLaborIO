function v = statespace2index(matrix, matidx)
  % Maps State Space to a unique index value in Indexer
  % Indexer uses vector vecidx as an nD index into matrix to return value v
  
  % Experience (starting at 0) needs added 1 for indexing
  matidx(:, 4:5) = matidx(:, 4:5)+1;
  
  % empty arrays
  v = NaN(size(matidx,1),1);
  cidx = num2cell(matidx);
  
  for l = 1:size(matidx,1)
      cidx_current = cidx(l,:);
      v(l) = matrix(cidx_current{:});
  end
  
end

