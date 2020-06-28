#!/usr//bin/perl
#This package requires
###  libnet-ssh2-perl
###  libxml-libxml-perl 
###  libxml-writer-perl  ## no longer used
###  libmojolicious-perl

use strict;
use warnings;
use English;

use lib './Modules/';
use NETCONF::Simple;

my $conn = NETCONF::Simple->new(
		host => "192.168.1.241",
		username => "cisco",
		password => "cisco",
	);


print "connection established\n";


my $xml_to_send = $conn->xml_from_mt_template('templates/hello.mt');
print "$xml_to_send\n";
$conn->send( $xml_to_send );

$xml_to_send = $conn->xml_from_mt_template('templates/lock_running.mt');
print "##SENDING##\n$xml_to_send\n";
$conn->send( $xml_to_send );

my $res = $conn->recieve();
print "###RECIEVED##\n" . $conn->ppxml($res);

my $data = { 
	interface => "2.300",
	encapsulation => "300",
};

$xml_to_send = $conn->xml_from_mt_template('templates/test2.mt' , $data );
#$xml_to_send = $conn->xml_from_mt_template('templates/test.mt' , $tempate_data );
print "##SENDING##\n$xml_to_send\n";
$conn->send( $xml_to_send );

print "data written\n";

$res = $conn->recieve();
print "###RECIEVED##\n" . $conn->ppxml($res);

$xml_to_send = $conn->xml_from_mt_template('templates/unlock_running.mt');
print "##SENDING##\n$xml_to_send\n";
$conn->send( $xml_to_send );
$res = $conn->recieve();
print "###RECIEVED##\n" . $conn->ppxml($res);

print "closing session\n"; 
$conn->disconnect();

