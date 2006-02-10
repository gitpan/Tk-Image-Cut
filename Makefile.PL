#-------------------------------------------------
use ExtUtils::MakeMaker;
#-------------------------------------------------
 WriteMakefile(
 	NAME			=> 'Tk::Image::Cut',
 	VERSION_FROM	=> 'lib/Tk/Image/Cut.pm',			# finds $VERSION
 	PREREQ_PM		=> {qw/
 				Tk
 				Tk::Frame
 				Tk::FileSelect
 				Tk::JPEG
 				Tk::PNG
 				Tk::Image::Calculation
 				/},					# e.g., Module::Name => 1.1
 	($] >= 5.005 ?							## Add these new keywords supported since 5.005
 	(ABSTRACT_FROM	=> 'lib/Tk/Image/Cut.pm',			# retrieve abstract from module
 	AUTHOR		=> 'Torsten Knorr <knorrcpan@tiscali.de>') : ()),
 	);
#-------------------------------------------------


