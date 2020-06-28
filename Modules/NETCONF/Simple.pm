package NETCONF::Simple;

use strict;
use warnings;

use English;
use Net::SSH2;
use Carp;
use XML::LibXML;    			## to validate XML
use XML::LibXML::PrettyPrint;
use Mojo::DOM;
use Mojo::Util qw(trim);
use Mojo::Template;

our $VERSION = '0.01';

my $DEFAULT_TERMINATOR = ']]>]]>';
my $DEFAULT_PORT = 830;
my $DEFAULT_TIMEOUT = 10_000;
my $DEFAULT_SUBSYSTEM = 'netconf';
my $DEFAULT_MESSAGE_ID = 100;

my %XML_OPTS = (
	OUTPUT => 'self', 
	DATA_MODE => 1, 
	DATA_INDENT => 2, 
	);
# Object Varables 
# 	host 
# 	username
# 	password 
# 	port
# 	timeout
# 	subsystem 
# 	connection 
# 	channel 
# 	capabilities 


sub new 
{
	my ( $class , %hash ) = @_;
	my $self = {};
    for my $key (keys %hash) 
    {
        $self->{$key} = $hash{$key};
    }
    croak "Please supply host\n" unless defined $self->{"host"};
    croak "Please supply username\n" unless defined $self->{"username"};
    croak "Please supply password\n" unless defined $self->{"password"};
    $self->{"port"} = $DEFAULT_PORT unless defined $self->{"port"};
    $self->{"timeout"} = $DEFAULT_TIMEOUT unless defined $self->{"timeout"};
    $self->{"subsystem"} = $DEFAULT_SUBSYSTEM unless defined $self->{"subsystem"};
    $self->{"terminator"} = $DEFAULT_TERMINATOR unless defined $self->{"terminator"};
    $self->{"message_id"} = $DEFAULT_MESSAGE_ID unless defined $self->{"message_id"};
    $self->{"capabilities"} = undef;
    $self->{'connection'}  = undef;
    $self->{'channel'}  = undef;
    bless $self , $class;

    $self->connect();
    my $res = $self->recieve();
	$self->{"capabilities"} = $self->process_server_capabilities( $res );
	croak "unable to communcate with ".$self->{"host"}." using netconf\n" unless ref( $self->{"capabilities"} );
	return $self;
}

sub connect
{
	my ($self ) = @_;
	my $ssh2 = Net::SSH2->new( timeout => $self->{"timeout"} );
		croak "Failed to create a new Net::SSH2 object" unless(ref $ssh2);
	$ssh2->connect( $self->{"host"} , $self->{"port"} );
		croak "SSH connection failed: " . $ssh2->error() if($ssh2->error());
	$ssh2->auth(
		username => $self->{"username"}, 
		password => $self->{"password"},
		);
		croak "SSH authentication failed" if(!$ssh2->auth_ok() or $ssh2->error());

	my $chan = $ssh2->channel();
		croak "Failed to create SSH channel" if(!ref $chan or $ssh2->error());
	my $con_subsystem = $chan->subsystem( $self->{"subsystem"} );
	if(!$con_subsystem) 
	{
	$chan->exec( $self->{"subsystem"} )
	    or croak "Failed to exec ". $self->{"subsystem"};
		$chan->flush();
	} 

	( $self->{"connection"}, $self->{"channel"}) =  ( $ssh2 , $chan );   ## Net::SSH2 and Net::SSH2::Channel objects
	return 1;
}
sub disconnect
{
	my ($self ) = @_;
	$self->{'connection'}->disconnect();
}
sub send
{
	my ($self , $xml ) = @_;
	croak unless ref( $self->{"channel"} );
	XML::LibXML->load_xml(string => $xml);

	#$channel->blocking(1);
	$self->{"channel"}->write( $xml .  $self->{"terminator"}  );
	return 1;
}
sub recieve
{
	my ($self ) = @_;
	my $TERMINATOR = $self->{"terminator"};
	croak unless ref($self->{"channel"});
	my ($resp, $buf);
	my $end_time = time() + 15;
	do {
		my $nbytes = $self->{"channel"}->read($buf, 65536);
		 
		if (!defined $nbytes or time() > $end_time) 
		{
		    croak "Failed to read data from SSH channel!";
		}
		if($nbytes > 0)
		{
		    $end_time = time() + 15;
		}
		$resp .= $buf;
	} until($resp =~ s/$TERMINATOR$//);
	return $resp;
}
sub ppxml
{
	my ( $self, $xml ) = @_;
	my $dom = XML::LibXML->load_xml(
    	string => $xml,
    );
	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
	$pp->pretty_print($dom); # modified in-place
	return $dom->toString;
}
sub dump_xml_to_file
{
	my ($filename , $xml) = @_ ;
	open(my $fh , ">" , $filename ) or croak "$!";
	my $dom = XML::LibXML->load_xml(
    	string => $xml,
    );
	my $pp = XML::LibXML::PrettyPrint->new(indent_string => "  ");
	$pp->pretty_print($dom); # modified in-place
	print $fh $dom->toString;
	close($fh);
}
sub process_server_capabilities
{
	my ( $self , $xml ) = @_;
	my @capabilities;   ## retun vars
	my $dom = Mojo::DOM->new($xml);
	for my $child ( $dom->at('hello > capabilities')->child_nodes->each )
	{
		my $val = $dom->parse($child)->at('capability');
		if( defined $val )
		{
			push @capabilities, trim( $val->text );
		}
	}
	return \@capabilities;
}
sub xml_from_mt_template
{
	my ( $self, $file , $var ) = @_;
	my $mt = Mojo::Template->new(vars => 1);
	my $xml = $mt->render_file($file , { 
		message_id => $self->get_message_id(),
		data => $var,
		} );
	eval 
	{
		XML::LibXML->load_xml(string => $xml);
	};
	if ($EVAL_ERROR) 
	{
		croak "#########\nError in xml\n#########\n$xml\n\n####XML ERROR######\n$EVAL_ERROR\n";
	}
	return $xml;
}
sub get_message_id
{
	my ( $self ) = @_;
	return $self->{"message_id"}++;
}
sub capabilities
{
	my ( $self ) = @_;
	return @{ $self->{"capabilities"} };
}


=head1 NAME

NETCONF::Simple - A simple class to connect and send XML to NETCONF (RFC 6241) devices

=head1 DESCRIPTION

This is a stub module, see F<script/foo> for details of the app.

=head1 AUTHOR

Michael Boyd

=head1 LICENSE

FreeBSD

=cut

1;