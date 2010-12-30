package SmartMT;
use strict;
use warnings;
our $VERSION = '0.01';
use Plack::Request;
use File::Spec;
use Encode;

sub new {
    my ( $class, %opt ) = @_;
    my $mt_home = $opt{mt_home};
    $ENV{MT_HOME} = $mt_home;
    push @INC, File::Spec->catdir( $mt_home, 'lib' );
    push @INC, File::Spec->catdir( $mt_home, 'extlib' );
    require MT;
    my $mt =
      MT->new( Config => File::Spec->catfile( $mt_home, "mt-config.cgi" ) )
      or die MT->errstr;
    my $blog = MT::Blog->load( $opt{blog_id} || 1 );
    my $self = bless { blog => $blog }, $class;
    $self;
}

sub to_app {
    my $self = shift;
    return sub {
        my $env = shift;
        my $req = Plack::Request->new( $env );
        my $blog_name = encode_utf8($self->{blog}->name);
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ $blog_name ] ];
    }
}

1;
__END__

=head1 NAME

SmartMT -

=head1 SYNOPSIS

  use SmartMT;

=head1 DESCRIPTION

SmartMT is

=head1 AUTHOR

Yusuke Wada E<lt>yusuke at kamawada.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
