package Bot::Cobalt::Plugin::YouTube;
our $VERSION = '0.001';

use Bot::Cobalt;
use Bot::Cobalt::Common;

use strictures 1;

use HTML::TokeParser;

use HTTP::Request;

use URI::Escape;

sub REGEX { 0 }

sub new { 
  bless [
    qr{youtube\.com/(\S+)},  ## ->[REGEX]
  ], shift
}

sub Cobalt_register {
  my ($self, $core) = @_;

  register( $self, 'SERVER', qw/
    public_msg
    youtube_plug_resp_recv
  / );

  logger->info("YouTube plugin registered ($VERSION)");
  
  PLUGIN_EAT_NONE
}

sub Cobalt_unregister {
  my ($self, $core) = @_;

  logger->info("YouTube plugin unregistered.");
  
  PLUGIN_EAT_NONE
}

sub Bot_public_msg {
  my ($self, $core) = splice @_, 0, 2;
  my $msg = ${ $_[0] };

  if (my ($id) = $msg->stripped =~ $self->[REGEX]) {
    my $req_url = "http://www.youtube.com/" . uri_escape($id) ;

    logger->debug("dispatching request to $req_url");

    my $request = HTTP::Request->new(
      GET => $req_url,
    );
    
    broadcast( 'www_request',
      HTTP::Request->new( GET => $req_url ),
      'youtube_plug_resp_recv',
      [ $req_url, $msg ],
    );
  }

  PLUGIN_EAT_NONE  
}

sub Bot_youtube_plug_resp_recv {
  my ($self, $core) = splice @_, 0, 2;

  my $response = ${ $_[1] };
  my $args     = ${ $_[2] };
  my ($req_url, $msg) = @$args;

  logger->debug("youtube_plug_resp_recv for $req_url");

  return PLUGIN_EAT_ALL unless $response->is_success;

  my $content = $response->decoded_content;

  my $html = HTML::TokeParser->new( \$content );

  my ($title, $short_url);

  while (my $tok = $html->get_tag('meta', 'link') ) {
    my $args = ref $tok->[1] eq 'HASH' ? $tok->[1] : next ;
    
    if (defined $args->{name} && $args->{name} eq 'title') {
      $title = $args->{content}
    }
    
    if (defined $args->{rel} && $args->{rel} eq 'shortlink') {
      $short_url = $args->{href}
    }
  }

  if (defined $title && $short_url) {
    my $irc_resp = 
      color('bold', 'YouTube:')
      . " $title ( $short_url )" ;

    broadcast( 'message',
      $msg->context,
      $msg->channel,
      $irc_resp
    );
  } else {
    logger->warn("Failed YouTube info retrieval for $req_url");
  }

  PLUGIN_EAT_ALL
}

1

=pod

=head1 NAME

Bot::Cobalt::Plugin::YouTube - YouTube plugin for Bot::Cobalt

=head1 SYNOPSIS

  !plugin load YT Bot::Cobalt::Plugin::YouTube

=head1 DESCRIPTION

A L<Bot::Cobalt> plugin.

Retrieves YouTube links pasted to an IRC channel and reports titles 
(as well as shorter urls) to IRC.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut
