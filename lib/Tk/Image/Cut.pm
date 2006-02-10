#*** Cut.pm ***#
# Copyright (C) 2006 by Torsten Knorr
# create-soft@tiscali.de
# All rights reserved!
#-------------------------------------------------
 package Tk::Image::Cut;
#-------------------------------------------------
 use strict;
 use warnings;
 use Tk;
 use Tk::Frame;
 use Tk::FileSelect;
 use Tk::JPEG;
 use Tk::PNG;
 use Tk::Image::Calculation;
#-------------------------------------------------
 @Tk::Image::Cut::ISA = qw(Tk::Frame Tk::Image::Calculation);
 $Tk::Image::Cut::VERSION = '0.04';
 Construct Tk::Widget "Cut";
#-------------------------------------------------
 sub Populate
 	{
 	require Tk::Button;
 	require Tk::BrowseEntry;
 	require Tk::Entry;
 	require Tk::Label;
 	require Tk::Canvas;
 	my ($cut, $args) = @_;
 	my @grid = qw(
 		-column	0
 		-row	0
 		-sticky	nswe
 		); 	
 	$cut->{_cal} = Tk::Image::Calculation->new();
#-------------------------------------------------
=head
 	-aperturecolor
 	-aperturewidth
 	-shape
 	-zoom
 	-shrink
=cut
 	$cut->{_aperturecolor} = (defined($args->{-aperturecolor}))	?
 		delete($args->{-aperturecolor})	:	"#00FF00";
 	$cut->{_aperturewidth} = (defined($args->{-aperturewidth}))	?
 		delete($args->{-aperturewidth})	:	4;
 	$cut->{_shape} = (defined($args->{-shape}))			?
 		delete($args->{-shape})		:	"rectangle";
 	$cut->{_zoom_out} = (defined($args->{-zoom}))			?
 		delete($args->{-zoom})		:		1;
 	$cut->{_shrink_out} = (defined($args->{-shrink}))			?
 		delete($args->{-shrink})		:		1;
 	$cut->SUPER::Populate($args);
#-------------------------------------------------
 	$cut->{button_select_image} = $cut->Button(
 		-text		=> "Select Image",
 		-command	=> [\&SelectImage, $cut],
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{label_shape} = $cut->Label(
 		-text		=> "Shape ->",
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{bentry_shape} = $cut->BrowseEntry(
 		-variable		=> \$cut->{_shape},
 		-browsecmd	=> [\&SetShape, $cut]
 		)->grid(
 		@grid,
 		);
 	$cut->{bentry_shape}->insert("end", "rectangle", "oval", "circle");
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{button_color} = $cut->Button(
 		-text		=> "Select Color",
 		-command	=> [\&SelectColor, $cut],
 		-state		=> "disabled"
 		)->grid(
 		@grid
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{label_width_out} = $cut->Label(
 		-text		=> "Width ->",
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{entry_width_out} = $cut->Entry(
 		-textvariable	=> \$cut->{_new_image_width},
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{label_height_out} = $cut->Label(
 		-text		=> "Height ->",
 		)->grid(
 		@grid,
 		);
#------------------------------------------------
 	$grid[1]++;
 	$cut->{entry_height_out} = $cut->Entry(
 		-textvariable	=> \$cut->{_new_image_height},
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{button_increase} = $cut->Button(
 		-text		=> '+',
 		-command	=> [\&ImageIncrease, $cut]
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{button_reduce} = $cut->Button(
 		-text		=> '-',
 		-command	=> [\&ImageReduce, $cut],
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{label_name_out} = $cut->Label(
 		-text		=> "New Image Name ->",
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{entry_name_out} = $cut->Entry(
 		-textvariable	=> \$cut->{_new_image_name},
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{button_cut} = $cut->Button(
 		-text		=> "Cut",
 		-command	=> [\&ImageCut, $cut],
 		)->grid(
 		@grid,
 		);
#-------------------------------------------------
 	$grid[1]++;
 	$cut->{canvas} = $cut->Scrolled(
 		"Canvas",
 		)->grid(
 		-column		=> 0,
 		-row		=> 1,
 		-columnspan	=> $grid[1],
 		-sticky		=> "nswe",
 		);
#-------------------------------------------------
 	$cut->{childs} = {
 		"ButtonSelectImage"		=> $cut->{button_select_image},
 		"LabelShape"			=> $cut->{label_shape},
 		"bEntryShape"			=> $cut->{bentry_shape},
 		"ButtonColor"			=> $cut->{button_color},
 		"LabelWidthOut"			=> $cut->{label_width_out},
 		"EntryWidthOut"			=> $cut->{entry_width_out},
 		"LabelHeightOut"		=> $cut->{label_height_out},
 		"EntryHeightOut"		=> $cut->{entry_height_out},
 		"ButtonIncrease"			=> $cut->{button_increase},
 		"ButtonReduce"			=> $cut->{button_reduce},
 		"LabelNameOut"			=> $cut->{label_name_out},
 		"EntryNameOut"			=> $cut->{entry_name_out},
 		"ButtonCut"			=> $cut->{button_cut},
 		"Canvas"			=> $cut->{canvas},
 		};
 	$cut->Advertise($_, $cut->{childs}{$_}) for(keys(%{$cut->{childs}}));
 	$cut->Delegates(DEFAULT	=> $cut->{canvas});
 	$cut->ConfigSpecs(DEFAULT	=> ["ADVERTISED"]);
 	}
#-------------------------------------------------
 sub SelectImage
 	{
 	my ($self) = @_;
 	$self->{_zoom_out} = 1;
 	$self->{_shrink_out} = 1;
 	if($self->{file_in} = $self->FileSelect()->Show())
 		{
 		 $self->{canvas}->delete("all");
# GIF, XBM, XPM, BMP, JPEG, PNG, PPM, PGM
 		if($self->{file_in} =~ m/.+?\.(?:jpg|jpeg)$/i)
 			{
 			$self->{image_format} = "JPEG";
 			}
 		elsif($self->{file_in} =~ m/.+?\.([a-zA-Z]{3})$/)
 			{
 			$self->{image_format} = uc($1);
 			}
 		else
 			{
 			print("error in extracting image format at Tk::Image::Cut::SelectImage()\n");
 			$self->{canvas}->createText(10, 10,
 				-text	=> "error in extracting image format",
 				-anchor	=> "nw",
 				);
 			return;
 			} 
 		$self->{image_in} = $self->Photo(
 			-file		=> $self->{file_in},
 			-format		=> $self->{image_format},
 			);
 		$self->{image_in_width} = $self->{image_in}->width();
 		$self->{image_in_height} = $self->{image_in}->height();
 		$self->{canvas}->configure(
 			-scrollregion	=> [0, 0, $self->{image_in_width}, $self->{image_in_height}],
 			); 
 		$self->{canvas}->createImage(0, 0,
 			-image		=> $self->{image_in},
 			-anchor		=> "nw",
 			-tags		=> "image"
 			);
 		if(($self->{canvas}->width() < $self->{image_in_width}) or
 		($self->{canvas}->height() < $self->{image_in_height}))
 			{
 			$self->{canvas}->bind("image", "<Leave>", [\&Scroll, $self, Ev('x'), Ev('y')]);
 			}
 		else
 			{
 			$self->{canvas}->bind("image", "<Leave>", sub { });
 			}
 		$self->CreateAperture();
 		}
 	return 1;
 	}
#-------------------------------------------------
 sub ImageIncrease
 	{
 	my ($self) = @_;
 	if($self->{_shrink_out} > 1) { $self->{_shrink_out}--; }
 	else { $self->{_zoom_out}++; }
 	$self->SetImageOutWidth();
 	$self->SetImageOutHeight();
 	$self->SetImageOutName();
 	return 1;
 	}
#-------------------------------------------------
 sub ImageReduce
 	{
 	my ($self) = @_;
 	if($self->{_zoom_out} > 1) { $self->{_zoom_out}--; }
 	else { $self->{_shrink_out}++; }
 	$self->SetImageOutWidth();
 	$self->SetImageOutHeight();
 	$self->SetImageOutName();
 	return 1;
 	}
#-------------------------------------------------
 sub ImageCut
 	{
 	my ($self) = @_;
 	$self->{image_out} = $self->Photo(
 		-format	=> $self->{image_format},
 		-width	=> $self->{_new_image_width},
 		-height	=> $self->{_new_image_height},
 		);
 	$self->{image_out}->copy($self->{image_in},
 		-zoom	=> $self->{_zoom_out},
 		-subsample => $self->{_shrink_out},
 		-from	=> $self->{aperture_x1}, $self->{aperture_y1}, $self->{aperture_x2}, $self->{aperture_y2},
 		-to	=> 0, 0, $self->{_new_image_width}, $self->{_new_image_height},
 		);
 	my $ref_p_out;
 	if($self->{_shape} eq "oval")
 		{
		($ref_p_out) = $self->{_cal}->GetPointsOutOval(0, 0, 
 			--$self->{_new_image_width}, 
 			--$self->{_new_image_height}
 			);
 		}
 	elsif($self->{_shape} eq "circle")
 		{
 		($ref_p_out) = $self->{_cal}->GetPointsOutCircle(0, 0,
 			--$self->{_new_image_width},
 			--$self->{_new_image_height}
 			);
 		}	
 	if(defined($self->{_color}))
 		{
 		$self->{image_out}->put($self->{_color}, -to => $_->[0], $_->[1]) for(@{$ref_p_out});
 		}
 	else
 		{
 		$self->{image_out}->transparencySet($_->[0], $_->[1], 1) for(@{$ref_p_out});
 		}	
 	$self->{image_out}->write(
 		$self->{_new_image_name},
 		-format	=> $self->{image_format},
 		);
 	return 1;
 	}
#-------------------------------------------------
 sub CreateAperture
 	{
 	my ($self) = @_;
 	return if(!(defined($self->{image_in})));
 	$self->DeleteBindings();
 	SWITCH:
 		{
#-------------------------------------------------
 ($self->{_shape}eq "rectangle")	&& do
 	{
 	$self->{aperture_x1} = int($self->{image_in_width} / 5);
 	$self->{aperture_y1} = int($self->{image_in_height} / 5);
 	$self->{aperture_x2} = int($self->{image_in_width} * 0.8);
 	$self->{aperture_y2} = int($self->{image_in_height} * 0.8);
 	$self->{canvas}->delete("aperture");
 	$self->{canvas}->delete("points_out");
 	$self->{aperture} = $self->{canvas}->createRectangle(
 		$self->{aperture_x1},
 		$self->{aperture_y1},
 		$self->{aperture_x2},
 		$self->{aperture_y2},
 		-outline		=> $self->{_aperturecolor},
 		-width		=> $self->{_aperturewidth},
 		-tags		=> "aperture",
 		);
 	$self->SetImageOutWidth();
 	$self->SetImageOutHeight();
 	$self->SetImageOutName();
 	$self->{canvas}->bind("aperture", "<Motion>", [\&ShowCursor, $self, Ev('x'), Ev('y')]);
 	$self->{canvas}->bind(
 		"aperture", 
 		"<Enter>",
 		sub {  
 		$self->{canvas}->itemconfigure(
 			"aperture",
 			-outline	=> "#FF0000",
 			);
 		}
 		); 
 	$self->{canvas}->bind(
 		"aperture",
 		"<Leave>",
 		sub { $self->{canvas}->itemconfigure(
 			"aperture",
 			-outline	=> $self->{_aperturecolor},
 			);
 		$self->{canvas}->configure( 
 			-cursor		=> "arrow",
 			);
 		});
 	$self->{canvas}->bind("aperture", "<ButtonPress>", [\&StartMove, $self, Ev('x'), Ev('y')]);
 	$self->{canvas}->bind("aperture", "<ButtonRelease>", [\&EndMove, $self]);
 	last(SWITCH);
 	};
#-------------------------------------------------
 ($self->{_shape} eq "oval")		&& do
 	{
 	$self->{canvas}->bind("image", "<ButtonPress>", [\&DrawOval, $self, Ev('x'), Ev('y')]);
 	$self->{canvas}->bind("points_out", "<ButtonPress>", [\&DrawOval, $self, Ev('x'), Ev('y')]);
 	last(SWITCH);
 	};
#-------------------------------------------------
 ($self->{_shape} eq "circle")	&& do
 	{
 	$self->{canvas}->bind("image", "<ButtonPress>", [\&DrawCircle, $self, Ev('x'), Ev('y')]);
 	$self->{canvas}->bind("points_out", "<ButtonPress>", [\&DrawCircle, $self, Ev('x'), Ev('y')]); 
 	last(SWITCH);
 	};
#-------------------------------------------------
 	}
 	return 1;
 	}
#-------------------------------------------------
 sub DeleteBindings
 	{
 	my ($self) = @_;
 	$self->{canvas}->bind("aperture", "<Motion>", sub { });
 	$self->{canvas}->bind("aperture", "<ButtonPress>", sub { });
 	$self->{canvas}->bind("aperture", "<ButtonRelease>", sub { });
 	$self->{canvas}->bind("image", "<Motion>", sub { });
 	$self->{canvas}->bind("image", "<ButtonPress>", sub { });
 	$self->{canvas}->bind("image", "<ButtonRelease>", sub { });
 	$self->{canvas}->bind("points_out", "<ButtonPress>", sub { });
 	$self->{canvas}->bind("points_out", "<ButtonRelease>", sub { });
 	return 1;
 	}
#-------------------------------------------------
 sub StartDraw
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$x = $canvas->canvasx($x);
 	$y = $canvas->canvasy($y);
 	$self->{canvas}->delete("aperture");
 	$self->{canvas}->delete("points_out");
 	$canvas->createOval(
 		$x, $y, $x, $y,
 		-outline		=> $self->{_aperturecolor},
 		-width		=> $self->{_aperturewidth},
 		-tags		=> "aperture"
 		);
 	$self->{start_x} = $self->{aperture_x1} = $x;
 	$self->{start_y} = $self->{aperture_y1} = $y;
 	return 1;
 	}
#-------------------------------------------------
 sub DrawCircle
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	StartDraw(@_);
 	$canvas->bind("image", "<Motion>", [\&MoveCircle, $self, Ev('x'), Ev('y')]);
 	$canvas->bind("image", "<ButtonRelease>", [\&EndDrawCircle, $self, Ev('x'), Ev('y')]);
 	$canvas->bind("points_out", "<ButtonRelease>", [\&EndDrawCircle, $self, Ev('x'), Ev('y')]);
 	return 1;
 	}
#-------------------------------------------------
 sub MoveCircle
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$x = $canvas->canvasx($x);
 	$y = $canvas->canvasy($y);
 	my $diff_x = ($x - $self->{start_x});
 	my $diff_y = ($y - $self->{start_y});
 	$self->{aperture_x2} = ($diff_x < $diff_y) ? ($self->{start_x} + $diff_y) : ($self->{start_x} + $diff_x);
 	$self->{aperture_y2} = ($diff_x < $diff_y) ? ($self->{start_y} + $diff_y) : ($self->{start_y} + $diff_x);
 	$canvas->coords(
 		"aperture",
 		$self->{start_x},
 		$self->{start_y},
 		$self->{aperture_x2},
 		$self->{aperture_y2},
 		);
 	$self->SetImageOutHeight();
 	$self->SetImageOutWidth();
 	return 1;
 	}
#-------------------------------------------------
 sub EndDrawCircle
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	MoveCircle(@_);
 	$self->SetImageOutName();
 	my ($ref_l_out) = $self->{_cal}->GetLinesOutCircle(
 		$self->{aperture_x1},
 		$self->{aperture_y1},
 		$self->{aperture_x2},
 		$self->{aperture_y2}
 		);
 	for(@{$ref_l_out})
 		{
 		$canvas->createLine(
 			$_->[0], $_->[1], $_->[2], $_->[3],
 			-width		=> 1,
 			-fill		=> $self->{_color} || "#FFFFFF",
 			-tags		=> "points_out"
 			);
 		}
 	$self->CreateAperture();
 	return 1;
 	}
#-------------------------------------------------
 sub DrawOval
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	StartDraw(@_);
 	$canvas->bind("image", "<Motion>", [\&MoveOval, $self, Ev('x'), Ev('y')]);
 	$canvas->bind("image", "<ButtonRelease>", [\&EndDrawOval, $self, Ev('x'), Ev('y')]);
 	$canvas->bind("points_out", "<ButtonRelease>", [\&EndDrawOval, $self, Ev('x'), Ev('y')]);
 	return 1;
 	}
#-------------------------------------------------
 sub MoveOval
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$x = $self->{aperture_x2} = $canvas->canvasx($x);
 	$y = $self->{aperture_y2} = $canvas->canvasy($y);
 	$canvas->coords(
 		"aperture",
 		$self->{start_x},
 		$self->{start_y},
 		$x,
 		$y
 		);
 	$self->SetImageOutHeight();
 	$self->SetImageOutWidth();
 	return 1;
 	} 
#-------------------------------------------------
 sub EndDrawOval
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	MoveOval(@_);
 	$self->SetImageOutName();
 	my ($ref_l_out) = $self->{_cal}->GetLinesOutOval(
 		$self->{aperture_x1},
 		$self->{aperture_y1},
 		$self->{aperture_x2},
 		$self->{aperture_y2}
 		);
 	for(@{$ref_l_out})
 		{
 		$canvas->createLine(
 			$_->[0], $_->[1], $_->[2], $_->[3],
 			-width		=> 1,
 			-fill		=> $self->{_color} || "#FFFFFF",
 			-tags		=> "points_out"
 			);
 		}
 	$self->CreateAperture();
 	return 1;
 	}
#-------------------------------------------------
 sub Scroll
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$x = $canvas->canvasx($x);
 	$y = $canvas->canvasy($y);
 	my ($part_x1, $part_x2) = $canvas->xview();
 	my ($part_y1, $part_y2) = $canvas->yview();
 	my $pos_x1 = ($self->{image_in_width} * $part_x1);
 	my $pos_x2 = ($self->{image_in_width} * $part_x2);
 	my $pos_y1 = ($self->{image_in_height} * $part_y1);
 	my $pos_y2 = ($self->{image_in_height} * $part_y2);
 	SWITCH:
 		{
 		(($x > $pos_x2) && ($y < $pos_y2))		&& do
 			{ 
 			$canvas->xviewScroll(1, "units");
 			last(SWITCH);
 			};
 		(($x < $pos_x1) && ($y < $pos_y2))		&& do
 			{
 			$canvas->xviewScroll(-1, "units");
 			last(SWITCH);
 			};
 		(($y > $pos_y2) && ($x < $pos_x2))		&& do
 			{
 			$canvas->yviewScroll(1, "units");
 			last(SWITCH);
 			};
 		(($y < $pos_y1) && ($x < $pos_x2))		&& do
 			{
 			$canvas->yviewScroll(-1, "units");
 			last(SWITCH);
 			};
 		}
 	return 1;
 	}
#-------------------------------------------------
 sub ShowCursor
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$x = $canvas->canvasx($x);
 	$y = $canvas->canvasy($y);
 	SWITCH:
 	{
 	(($x > ($self->{aperture_x1} + 10))	&& 
 	($x < ($self->{aperture_x2} - 10))	&&
 	($y > ($self->{aperture_y1} - 4))	&&
 	($y < ($self->{aperture_y1} + 4)))	&& do
 		{
 		$self->{cursor_style} = "top_side";
 		last SWITCH;
 		};
 	(($x > ($self->{aperture_x1} + 10))	&&
 	($x < ($self->{aperture_x2} - 10))	&&
 	($y > ($self->{aperture_y2} - 4))	&&
 	($y < ($self->{aperture_y2} + 4)))	&& do
 		{
 		$self->{cursor_style} = "bottom_side",
 		last SWITCH;
 		};
 	(($y > ($self->{aperture_y1} + 10))	&&
 	($y < ($self->{aperture_y2} - 10))	&&
 	($x > ($self->{aperture_x1} - 4))	&&
 	($x < ($self->{aperture_x1} +4)))	&& do
 		{
 		$self->{cursor_style} = "left_side";
 		last SWITCH;
 		};
 	(($y > ($self->{aperture_y1} + 10))	&&
 	($y < ($self->{aperture_y2} - 10))	&&
 	($x > ($self->{aperture_x2} - 4))	&&
 	($x < ($self->{aperture_x2} + 4)))	&& do
 		{
 		$self->{cursor_style} = "right_side";
 		last SWITCH;
 		};
 	((($x >= $self->{aperture_x1})	&&
 	($x <= ($self->{aperture_x1} + 10))	&&
 	($y >= ($self->{aperture_y1} - 4))	&&
 	($y <= ($self->{aperture_y1} + 4)))	||
 	(($y >= $self->{aperture_y1})	&&
 	($y <= ($self->{aperture_y1} + 10))	&&
 	($x >= ($self->{aperture_x1} - 4))	&&
 	($x <= ($self->{aperture_x1} + 4))))	&& do
 		{
 		$self->{cursor_style} = "top_left_corner";
 		last SWITCH;
 		};
 	((($x <= $self->{aperture_x2})	&&
 	($x >= ($self->{aperture_x2} - 10))	&&
 	($y <= ($self->{aperture_y1} + 4))	&&
 	($y >= ($self->{aperture_y1} - 4)))	||
 	(($y >= $self->{aperture_y1})	&&
 	($y <= ($self->{aperture_y1} + 10))	&&
 	($x <= ($self->{aperture_x2} + 4))	&&
 	($x >= ($self->{aperture_x2} - 4))))	&& do
 		{
 		$self->{cursor_style} = "top_right_corner";
 		last SWITCH;
 		};
 	((($y >= ($self->{aperture_y2} - 10))	&&
 	($y <= $self->{aperture_y2})	&&
 	($x <= ($self->{aperture_x1} + 4))	&&
 	($x >= ($self->{aperture_x1} - 4)))	||
 	(($x >= $self->{aperture_x1})	&&
 	($x <= ($self->{aperture_x1} + 10))	&&
 	($y <= ($self->{aperture_y2} + 4))	&&
 	($y >= ($self->{aperture_y2} - 4))))	&& do
 		{
 		$self->{cursor_style} = "bottom_left_corner";
 		last SWITCH;
 		};
 	((($x <= $self->{aperture_x2})	&&
 	($x >= ($self->{aperture_x2} - 10))	&&
 	($y <= ($self->{aperture_y2} + 4))	&&
 	($y >= ($self->{aperture_y2} - 4)))	||
 	(($y <= $self->{aperture_y2})	&&
 	($y >= ($self->{aperture_y2} - 10))	&&
 	($x <= ($self->{aperture_x2} + 4))	&&
 	($x >= ($self->{aperture_x2} - 4))))	&& do
 		{
 		$self->{cursor_style} = "bottom_right_corner";
 		last SWITCH;
 		};
 	$self->{cursor_style} = "arrow";
 	}
 	$self->{canvas}->configure(
 		-cursor		=> $self->{cursor_style},
 		);
 	return 1;
 	}
#-------------------------------------------------
 sub StartMove
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$x = $canvas->canvasx($x);
 	$y = $canvas->canvasy($y);
 	SWITCH:
 	{
 	($self->{cursor_style} eq "top_side")		&& do
 		{
 		$canvas->bind("aperture", "<Motion>", [\&MoveUpperLine, $self, Ev('y')]);
 		last SWITCH;
 		};
 	($self->{cursor_style} eq "bottom_side")		&& do
 		{
 		$canvas->bind("aperture", "<Motion>", [\&MoveUnderLine, $self, Ev('y')]);
 		last SWITCH;
 		};
 	($self->{cursor_style} eq "left_side")			&& do
 		{
 		$canvas->bind("aperture", "<Motion>", [\&MoveLeftLine, $self, Ev('x')]);
 		last SWITCH;
 		};
 	($self->{cursor_style} eq "right_side")		&& do
 		{
 		$canvas->bind("aperture", "<Motion>", [\&MoveRightLine, $self, Ev('x')]);
 		last SWITCH;
 		};
 	($self->{cursor_style} eq "top_left_corner")		&& do
 		{
 		$canvas->bind("aperture", "<Motion>", [\&MoveUpperLeftCorner, $self, Ev('x'), Ev('y')]);
 		last SWITCH;
 		};
 	($self->{cursor_style} eq "top_right_corner")		&& do
 		{
 		$canvas->bind("aperture", "<Motion>", [\&MoveUpperRightCorner, $self, Ev('x'), Ev('y')]);
 		last SWITCH;
 		};
 	($self->{cursor_style} eq "bottom_left_corner")	&& do
 		{
 		$canvas->bind("aperture", "<Motion>", [\&MoveUnderLeftCorner, $self, Ev('x'), Ev('y')]);
 		last SWITCH;
 		};
 	($self->{cursor_style} eq "bottom_right_corner")	&& do
 		{
 		$canvas->bind("aperture", "<Motion>", [\&MoveUnderRightCorner, $self, Ev('x'), Ev('y')]);
 		last SWITCH;
 		};
 	$canvas->bind("aperture", "<Motion>", sub { });
 	}
 	return 1;
 	}
#-------------------------------------------------
 sub EndMove
 	{
 	my ($canvas, $self) = @_;
 	$canvas->bind("aperture", "<Motion>", [\&ShowCursor, $self, Ev('x'), Ev('y')]);
 	$self->SetImageOutName();
 	return 1;
 	}
#-------------------------------------------------
 sub MoveUpperLine
 	{
 	my ($canvas, $self, $y) = @_;
 	$self->{aperture_y1} = $canvas->canvasy($y);
 	$self->SetImageOutHeight();
 	$self->Move();
 	return 1;
 	}
#-------------------------------------------------
 sub MoveUnderLine
 	{
 	my ($canvas, $self, $y) = @_;
 	$self->{aperture_y2} = $canvas->canvasy($y);
 	$self->SetImageOutHeight();
 	$self->Move();
 	return 1;
 	}
#-------------------------------------------------
 sub MoveLeftLine
 	{
 	my($canvas, $self, $x) = @_;
 	$self->{aperture_x1} = $canvas->canvasx($x);
 	$self->SetImageOutWidth();
 	$self->Move();
 	return 1;
 	}
#-------------------------------------------------
 sub MoveRightLine
 	{
 	my ($canvas, $self, $x) = @_;
 	$self->{aperture_x2} = $canvas->canvasx($x);
 	$self->SetImageOutWidth();
 	$self->Move();
 	return 1;
 	}
#-------------------------------------------------
 sub MoveUpperLeftCorner
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$self->{aperture_x1} = $canvas->canvasx($x);
 	$self->{aperture_y1} = $canvas->canvasy($y);
 	$self->SetImageOutWidth();
 	$self->SetImageOutHeight();
 	$self->Move();
 	return 1;
 	}
#-------------------------------------------------
 sub MoveUpperRightCorner
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$self->{aperture_x2} = $canvas->canvasx($x);
 	$self->{aperture_y1} = $canvas->canvasy($y);
 	$self->SetImageOutWidth();
 	$self->SetImageOutHeight();
 	$self->Move();
 	return 1;
 	}
#--------------------------------------------------
 sub MoveUnderLeftCorner
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$self->{aperture_x1} = $canvas->canvasx($x);
 	$self->{aperture_y2} = $canvas->canvasy($y);
 	$self->SetImageOutWidth();
 	$self->SetImageOutHeight(); 
 	$self->Move();
 	return 1;
 	}
#-------------------------------------------------
 sub MoveUnderRightCorner
 	{
 	my ($canvas, $self, $x, $y) = @_;
 	$self->{aperture_x2} = $canvas->canvasx($x);
 	$self->{aperture_y2} = $canvas->canvasy($y);
 	$self->SetImageOutWidth();
 	$self->SetImageOutHeight();
 	$self->Move();
 	return 1;
 	}
#-------------------------------------------------
 sub Move
 	{
 	my ($self) = @_;
 	 $self->{canvas}->coords(
 		"aperture", 
		$self->{aperture_x1},
 		$self->{aperture_y1},
 		$self->{aperture_x2},
 		$self->{aperture_y2},
 		);
 	return 1;
 	}
#-------------------------------------------------
 sub SetImageOutWidth
 	{
 	my ($self) = @_;
 	$self->{_new_image_width} = 
 		int(abs(
 		($self->{aperture_x2} - $self->{aperture_x1}) *
 		($self->{_zoom_out} / $self->{_shrink_out})
 		));
 	return 1;
 	}
#-------------------------------------------------
 sub SetImageOutHeight
 	{
 	my ($self) = @_;
 	$self->{_new_image_height} =
 		int(abs(
 		($self->{aperture_y2} - $self->{aperture_y1}) *
 		($self->{_zoom_out} / $self->{_shrink_out})
 		));
 	return 1;
 	}
#-------------------------------------------------
 sub SetImageOutName
 	{
 	my ($self) = @_;
 	$self->{file_in} =~ m/(.+?)(\.\w{3,4})$/;
 	$self->{_new_image_name} = $1 . '_' . $self->{_new_image_width} . 'X' . $self->{_new_image_height} . $2; 
 	return 1;
 	}
#-------------------------------------------------
 sub SetShape
 	{
 	my ($self) = @_;
 	SWITCH:
 		{
 		($self->{_shape} eq "rectangle")	&& do
 			{
 			$self->{button_color}->configure(
 				-state		=> "disabled"
 				);
 			$self->CreateAperture();
 			last(SWITCH);
 			};
 		(($self->{_shape} eq "oval") or
 		($self->{_shape} eq "circle"))	&& do
 			{
 			$self->{canvas}->delete("aperture");
 			$self->{canvas}->delete("points_out");
 			$self->{button_color}->configure(
 				-state		=> "normal"
 				);
 			$self->CreateAperture();
 			last(SWITCH);
 			};
 		}
 	return 1;
 	}
#-------------------------------------------------
 sub SelectColor
 	{
 	my ($self) = @_;
 	$self->{_color} = undef;
 	$self->{_color} = $self->chooseColor();
 	$self->{canvas}->itemconfigure(
 		"points_out",
 		-fill		=> $self->{_color} || "#FFFFFF"
 		);
 	return 1;
 	}
#-------------------------------------------------
1;
#-------------------------------------------------
__END__

=head1 NAME

Tk::Image::Cut - Perl extension for a graphic user interface to cut pictures.

=for category Derived Widgets

=head1 SYNOPSIS

 use Tk::Image::Cut;
 my $mw = MainWindow->new();
 $mw->title("Picture-Cutter");
 $mw->geometry("+5+5");
 my $cut = $mw->Cut()->grid();
 $mw->Button(
 	-text		=> "Exit",
 	-command	=> sub { exit(); },
 	)->grid();
 for(qw/
 	ButtonSelectImage
 	LabelShape
 	bEntryShape
 	ButtonColor
 	LabelWidthOut
 	EntryWidthOut
 	LabelHeightOut
 	EntryHeightOut
 	ButtonIncrease
 	ButtonReduce
 	LabelNameOut
 	EntryNameOut
 	ButtonCut
 	/)
 	{
 	$cut->Subwidget($_)->configure(
 		-font		=> "{Times New Roman} 10 {bold}",
 		);
 	}
 for(qw/
 	bEntryShape
 	EntryWidthOut
 	EntryHeightOut
 	EntryNameOut
 	Canvas
 	/)
 	{
 	$cut->Subwidget($_)->configure(
 		-background	=> "#FFFFFF",
 		);
 	}
 for(qw/
 	bEntryShape
 	EntryWidthOut
 	EntryHeightOut
 	/)
 	{
 	$cut->Subwidget($_)->configure(
 		-width		=> 6,
 		);
 	}
 $cut->Subwidget("EntryNameOut")->configure(
 		-width		=> 40,
 		);
 $cut->Subwidget("Canvas")->configure(
 	-width		=> 1000,
 	-height		=> 800,
 	);
 MainLoop();

=head1 DESCRIPTION

 Perl extension for a graphic user interface to cut pictures.
 The module is a mixed widget from Buttons, Labels, BrowseEntry, Entrys and Canvas widgets.
 I hope the graphic user interface is simple enough to be understood without great declarations.
 It can be used as an independent application or just like how any other widget. 
 Try out the test.pl program.You can select between three cutting forms.
 "Rectangle", "Oval" or "Circle"
 In order to cut out pictures in circular form or ovally click
 with the mouse onto the upper left corner and hold the
 Button pressed while the mouse is moved.

 You can use all standard widget options.

=head1 CONSTRUCTOR AND INITIALIZATION

 use Tk;
 use Tk::Image::Cut;
 my $mw = MainWidow->new();
 my $cut = $mw->Cut(
 	-aperturewidth	=> 2,
 	-aperturecolor	=> "#0000FF",
 	-shape		=> "oval",
 	-zoom		=> 2,
 	-shrink		=> 1
 	)->pack();
 $cut->Subwidget("Canvas")->configure(
 	-width		=> 1000,
 	-height		=> 800,
 	);
 MainLoop();

=head1 WIDGET SPECIFIC OPTINOS

=item	-aperturecolor

The margin color of the aperture. default: "#00FF00" (green)

=item 	-aperturewidth

The border of the aperture. default: 4

=item 	-shape

The shape of the aperture "rectangle", "oval". default: "rectangle"

=item	-zoom

default: 1

=item 	-shrink

default: 1

=head1 INSERTED WIDGETS

=item <ButtonSelectImage>

Selecting the picture to be worked on.

=item <LabelShape>

=item <bEntryShape>

You can select between three cutting forms.
 "Rectangle", "Oval" or "Circle" default: "Rectangle"

=item <ButtonColor>

Define the background color for the picture.
Is no color indicated then transparent is used.

=item <LabelWidthOut>

=item <EntryWidthOut>

Shows the width of the new picture.

=item <LabelHeightOut>

=item <EntryHeightOut>

Shows the height of the new picture.

=item <ButtonIncrease>

Extend the new picture.

=item <ButtonReduce>

Reduce the new picture.

=item <LabelNameOut>

=item <EntryNameOut>

Shows the name of the new picture.
Of course this can be changed any.

=item <ButtonCut>

Creates the new picture.

=item <Canvas>

Shows the picture.
	
=head2 EXPORT

None by default.

=head1 SEE ALSO

 Tk::Image
 Tk::Photo
 http://www.planet-interkom.de/t.knorr/index.html

=head1 KEYWORDS

image, photo, cut, picture, widget

=head1 	BUGS

 Maybe you'll find some. Please let me know.

=head1 AUTHOR

Torsten Knorr, E<lt>knorrcpan@tiscali.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Torsten Knorr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.9.2 or,
at your option, any later version of Perl 5 you may have available.

=cut


