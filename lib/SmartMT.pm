package SmartMT;
use strict;
use warnings;
our $VERSION = '0.01';
use Plack::Request;
use File::Spec;
use Encode;
use Router::Simple;
use Text::Xslate;

sub new {
    my ( $class, %opt ) = @_;
    my $mt_home = $opt{mt_home} or die 'Set mt_home parameter of $ENV{MT_HOME}';
    $ENV{MT_HOME} = $mt_home;
    push @INC, File::Spec->catdir( $mt_home, 'lib' );
    push @INC, File::Spec->catdir( $mt_home, 'extlib' );
    require MT;
    my $mt =
      MT->new( Config => File::Spec->catfile( $mt_home, "mt-config.cgi" ) )
      or die MT->errstr;
    my $blog = MT::Blog->load( $opt{blog_id} || 1 );
    my $view = Text::Xslate->new(
        syntax => 'TTerse',
        path   => ['./root'],
        header => ['header.tt2'],
        footer => ['footer.tt2'],
    );
    my $self = bless { blog => $blog, view => $view }, $class;
    $self;
}

sub to_app {
    my $self = shift;
    return sub {
        my $env = shift;
        my $req = Plack::Request->new($env);

        # '/entry/{id}'
        if ( my ($entry_id) = $req->path_info =~ m!/entry/(\d+)! ) {
            my $entry = $self->entry( $entry_id );
            my $html    = $self->render_html(
                'entry.tt2',
                {
                    blog    => $self->{blog},
                    entry => $entry,
                    body => Text::Xslate::mark_raw( $entry->text . $entry->text_more ),
                    title => $entry->title,
                    base    => $req->base
                }
            );
            return [ 200, [ 'Content-Type' => 'text/html; charset=utf-8' ],
                [$html] ];
        }

        # '/'
        if ( $req->path_info eq '/' ) {
            my $entries = $self->recent_entries();
            my $html    = $self->render_html(
                'index.tt2',
                {
                    blog    => $self->{blog},
                    entries => $entries,
                    base    => $req->base
                }
            );
            return [ 200, [ 'Content-Type' => 'text/html; charset=utf-8' ],
                [$html] ];
        }
      }
}

sub render_html {
    my ( $self, $tmpl, $param ) = @_;
    my $html = $self->{view}->render($tmpl, $param);
    $html = encode_utf8($html);
    return $html;
}

sub recent_entries {
    my ( $self, $page ) = @_;
    require MT::Entry;
    my @entries = MT::Entry->load(
        { blog_id => $self->{blog}->id },
        { limit   => 20, sort => 'created_on', direction => "descend" }
    );
    return \@entries;
}

sub entry {
    my ( $self, $id ) = @_;
    require MT::Entry;
    my $entry = MT::Entry->load(
        { blog_id => $self->{blog}->id, id => $id },
    );
    return $entry;
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
