:- use_module(library(sgml)).
:- use_module(library(apply)).


shutdown_all :-
	findall(I, instance(I, instanceId, _), Is),
	maplist(ec2_terminate_inst, Is).



% --------------------------------------------------------------------
% Build knowledge base

load_aws :-
	load_regions(_),
	load_instance(_),
	load_snapshot(_),
	load_volume(_).

% assert region information
load_regions(Rs) :-
	findall(R, (aws_region(R), assertz(region(R))), Rs).


% assert instance information
load_instance(Ids) :-
	findall(Id, (ec2_instance(I),
		     xpath(I, //('instanceId'(text)), Id),
		     I = element(_, _, Cs),
		     load_instance_attr(Id, Cs)),
		Ids).

load_instance_attr(_, []).
% load_instance_attr(Id, [element(tagSet, _, Items) | Cs]) :-
% 	load_tags(Id, Items).
load_instance_attr(Id, [C | Cs]) :-
	C = element(A, _, V),
	assertz(instance(Id, A, V)),
	load_instance_attr(Id, Cs).


% assert snapshot info
load_snapshot(Ids) :- 
	findall(Id, (ec2_snapshot(I),
		     xpath(I, //('snapshotId'(text)), Id),
		     I = element(_, _, Cs),
		     load_snapshot_attr(Id, Cs)),
		Ids).

load_snapshot_attr(_, []).
load_snapshot_attr(Id, [C | Cs]) :-
	C = element(A, _, V),
	assertz(snapshot(Id, A, V)),
	load_snapshot_attr(Id, Cs).

% assert volume info
load_volume(Ids) :- 
	findall(Id, (ec2_volume(I),
		     xpath(I, //('volumeId'(text)), Id),
		     I = element(_, _, Cs),
		     load_volume_attr(Id, Cs)),
		Ids).

load_volume_attr(_, []).
load_volume_attr(Id, [C | Cs]) :-
	C = element(A, _, V),
	assertz(volume(Id, A, V)),
	load_volume_attr(Id, Cs).



% Transform an element list of attributes into a list of [Attribute, Value]
xml_to_list([], _).
xml_to_list([X | Xml], [[A,V] | Ls] ) :-
	X = element(A, _, V),
	xml_to_list(Xml, Ls).



% --------------------------------------------------------------------
% EC2 related calls



ec2_terminate_inst(Id) :-
	aws_fake_run(['terminate-instances', Id], _).

% Return an XML chunk for each instance
ec2_instance(Instance) :-
	aws_run(['describe-instances'], Xml),
	xpath(Xml, //('instancesSet')/('item'), Instance).


% Return XML for each snapshot
ec2_snapshot(Snapshot) :-
	aws_run(['describe-snapshots'], Xml),
	xpath(Xml, //('snapshotSet')/('item'), Snapshot).


% Return XML for each volume
ec2_volume(Volume) :-
	aws_run(['describe-volumes'], Xml),
	xpath(Xml, //('volumeSet')/('item'), Volume).	


% Return each region
aws_region(Region) :-
 	aws_run(['describe-regions'], Xml),
 	xpath(Xml, //('regionName'(text)), Region).


% --------------------------------------------------------------------
% Low level calls to processes 

% Calls aws perl script available at timkay.com/aws
aws_run(Options, Xml) :-
	process_create(path(aws), ['--xml' | Options], [stdout(pipe(P))]),
	load_structure(P,Xml,[dialect(xml),space(remove)]).

% Fake aws_run for testing
aws_fake_run(Options, []) :-
	write('EXEC: aws --xml'),
	maplist(my_write, Options),
	nl.

my_write(T) :- write(' '), write(T).



