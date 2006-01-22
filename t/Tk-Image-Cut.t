# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Tk-Image-Cut.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

 use Test::More tests => 77;
# use Test::More "no_plan";
BEGIN { use_ok('Tk::Image::Cut') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
 use_ok("Tk");
 ok(my $mw = MainWindow->new());
 isa_ok($mw, "MainWindow");
 can_ok($mw, "title");
 $mw->title("Picture-Cutter");
 can_ok($mw, "geometry");
 $mw->geometry("+5+5");
 can_ok($mw, "Cut");
 ok(my $cut = $mw->Cut());
 isa_ok($cut, "Tk::Image::Cut");
 can_ok($cut, "grid");
 ok($cut->grid());
 can_ok($cut, "SelectImage");
# ok($cut->SelectImage());
 ok(my $test_image = $cut->Photo(
 	-file	=> "test.jpg",
 	-format	=> "JPEG",
 	));
 ok($cut->Subwidget("Canvas")->createImage(0, 0,
 	-image	=> $test_image,
 	-anchor	=> "nw",
 	));
 can_ok($cut, "ImageIncrease");
# ok($cut->ImageIncrease());
 can_ok($cut, "ImageReduce"); 
# ok($cut->ImageReduce());
 can_ok($cut, "ImageCut");
# ok($cut->ImageCut());
 can_ok($cut, "CreateAperture");
# ok($cut->CreateAperture());
 can_ok($cut, "MoveAperture");
# ok($cut->MoveAperture());
 can_ok($cut, "MoveUpperLine");
 can_ok($cut, "MoveUnderLine");
 can_ok($cut, "MoveRightLine");
 can_ok($cut, "MoveLeftLine");
 can_ok($cut, "MoveUpperLeftCorner");
 can_ok($cut, "MoveUnderLeftCorner");
 can_ok($cut, "MoveUpperRightCorner");
 can_ok($cut, "MoveUnderLeftCorner");
 can_ok($cut, "Move");
 can_ok($cut, "ShowCursor");
 can_ok($cut, "SetImageOutWidth");
 can_ok($cut, "SetImageOutHeight");
 can_ok($cut, "SetImageOutName");
 can_ok($cut, "Subwidget");
 for(qw/
 	ButtonSelectImage
 	LabelShape
 	bEntryShape
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
 	ok(my $subwidget = $cut->Subwidget($_));
 	can_ok($subwidget, "configure");
 	$subwidget->configure(
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
 	ok(my $subwidget = $cut->Subwidget($_));
 	can_ok($subwidget, "configure");
 	$subwidget->configure(
 		-background	=> "#FFFFFF",
 		);
 	}
 for(qw/
 	bEntryShape
 	EntryWidthOut
 	EntryHeightOut
 	/)
 	{
 	ok(my $subwidget = $cut->Subwidget($_));
 	can_ok($subwidget, "configure");
 	$subwidget->configure(
 		-width		=> 10,
 		);
 	}
 $cut->Subwidget("EntryNameOut")->configure(
 		-width		=> 40,
 		);
 $cut->Subwidget("Canvas")->configure(
 	-width		=> 800,
 	-height		=> 600,
 	);
 ok($mw->Button(
 	-text		=> "Exit",
 	-command	=> sub { exit(); },
 	)->grid());
 can_ok($mw, "after");
 can_ok($mw, "destroy");
 ok($mw->after(2000, sub { $mw->destroy(); }));
 MainLoop();
#-------------------------------------------------





