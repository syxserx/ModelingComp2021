function [arrival_times, routing] = build_sched_bin(workers,customers,vel,AST,L)
% Compute the time at a worker arrives at a customers' house using the
% average velocity and average service time.

m = length(workers);
n = length(customers);

% check if there is enough worker
if floor(n/L)>m
    disp('there is not enough worker')
    
else
    
arrival_times = zeros(n,1); % time which customer gets serviced
routing = cell(m,1);
c_pos = [customers.pos]; % 2 by n array of positions


% Get the angular position of each customer
R = vecnorm(c_pos); % radius
angle = zeros(1,n);
for i = 1:n
    if (c_pos(2,i) > 0)
        angle(i) = acosd(c_pos(1,i)/R(i));
    else
        angle(i) = 360 - acosd(c_pos(1,i)/R(i));
    end
    c_pos(3,i)=angle(i);
end


% Create a bin, and do a count for each bin.
da = 30;
edges = 0:da:360;
count= histcounts(angle,edges);
l=length(edges);

if l>m
    disp('there is not enough worker for each bin')
    
else

% Figure out a way to distribute m workers
all_tasks = cell(l,1);
worker_pos = zeros(2,m);

for i=1:l
all_tasks{i} = find(c_pos(3,i)>=edges(i)&&c_pos(3,i)<edges(i+1));
w_num(i)=floor(count(i)*m/n);
end

% loop over first l workers now the question is how to add the additional
% woker to the loop, maybe we can use alternative saying the w_num(i) in
% widge i, could take turns 1 woker goes first and the next goes to the
% closest customer and until all the workers in this group exhausted
for i = 1:l   
    time = 0;
    pos = worker_pos(:,i);
    tasks = all_tasks{i};
    route = [];
    while(~isempty(tasks)) % while array is nonempty
        dests = [customers(tasks).pos];
        dists = vecnorm(dests-pos);
        [val, ind] = min(dists);
        customer = tasks(ind); % closest customer
        route = [route, customer];
        
        % travel to customer location
        travel = dists(ind)/vel; % time = distance/velocity
        time = time + travel;
        pos = dests(ind);
        arrival_times(customer) = time; % record arrival time
        
        % do the work
        time = time + AST;
        tasks = tasks(tasks~=customer); % delete customer from array
    end
    routing{i} = route;
end
% For each non empty bin ...
%    Simulate workers moving from customer to customer based on proximity
%    Keep track of which worker moves to which customers
%    Keep track of the time at which the workers arrive
end

end

end

