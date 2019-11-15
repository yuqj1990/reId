function net = resnet52_market()
netStruct = load('/home/zzd/re_ID_beta23_uts0/data/imagenet-resnet-50-dag.mat') ;
net = dagnn.DagNN.loadobj(netStruct) ;
net.removeLayer('fc1000');
net.removeLayer('prob');
%---------setting1
for i = 1:numel(net.params)
    if(mod(i,2)==0)
        net.params(i).learningRate=0.02;
    else net.params(i).learningRate=0.001;
    end
    name = net.params(i).name;
    if(name(1)=='b')
        net.params(i).weightDecay=0;
    end
end

%---
net.params(1).learningRate = 0.0001;

% When training the basic network, please umcomment the following block.
% When training the whole network, please keep it commented.
%{ 
dropoutBlock = dagnn.DropOut('rate',0.75);
net.addLayer('dropout',dropoutBlock,{'pool5'},{'pool5d'},{});
fc751Block = dagnn.Conv('size',[1 1 2048 751],'hasBias',true,'stride',[1,1],'pad',[0,0,0,0]);
net.addLayer('fc751',fc751Block,{'pool5d'},{'prediction'},{'fc751f','fc751b'});
net.addLayer('softmaxloss',dagnn.Loss('loss','softmaxlog'),{'prediction','label'},'objective');
net.addLayer('top1err', dagnn.Loss('loss', 'classerror'), ...
    {'prediction','label'}, 'top1err') ;
net.addLayer('top5err', dagnn.Loss('loss', 'topkerror', ...
    'opts', {'topK',5}), ...
    {'prediction','label'}, 'top5err') ;
%}
net.initParams();
end

