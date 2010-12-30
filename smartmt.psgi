use strict;
use warnings;
use SmartMT;

my $mt_home = $ENV{MT_HOME};
my $smart_mt = SmartMT->new( mt_home => $mt_home, blog_id => 1 );
$smart_mt->to_app();
