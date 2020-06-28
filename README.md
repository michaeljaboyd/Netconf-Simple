# Netconf-Simple
A simple perl class to connect and send XML to NETCONF (RFC 6241) devices


# Motovation
I wanted a perl option to send/recieve raw XML to a netconf enabled device. This code has been tested on Cisco csr1000v 17.01.01

# Usage
Install required packages for dependancies 
apt get instal libnet-ssh2-perl libxml-libxml-perl libmojolicious-perl

# Methods

## new
COnnect to host, create a NETCONF:Simple object, and return the referance 
  ```
  my $conn = NETCONF::Simple->new(
		host => "192.168.1.241",
		username => "cisco",
		password => "cisco",
	); 
  ```
  
### Supported values
#### host
The IP or hostname of the netconf device (required)
#### username
The username (required). Only username and password supported at this time
#### password
The password (required). Only username and password supported at this time
#### port
TCP Port for the connection (optional). Defaults to 830 if unspecified 
#### timeout
ssh timeout (optional).  Defaults to 10s if unspecified 
#### subsystem
ssh subsystem (optional). Defaults to "netconf" if unspecified 
#### terminator
EOF terminator for communactions (optional). Defaults to ']]>]]>' if unspecified 
#### message_id
message id start number


## send
send XML to host. XML in string format
```
$conn->send( $xml_to_send );
```
## recieve
recieve XML stream from node
```
my $res = $conn->recieve();
```
## ppxml
format xml into pretty format. use for debugging. Be careful sending xml to netconf device when in pretty format. New lines and whitespace and cause issues for values.  
```
print "###RECIEVED##\n" . $conn->ppxml($res);
```
## xml_from_mt_template
use Mojo::Template file to create XML. messageid passed as $message_id to template. data can be passed as a data structer useing $data. 
```
my $xml_to_send = $conn->xml_from_mt_template('templates/hello.mt');
```
```
my $data = { 
	interface => "2.300",
	encapsulation => "300",
};

$xml_to_send = $conn->xml_from_mt_template('templates/test2.mt' , $data );
```
## disconnect
gracefully disconnect from netconf node
```
$conn->disconnect();
```
## dump_xml_to_file
dump xml to file formatted in pretty format
```
$conn->dump_xml_to_file( "out.xml" , $xml );
```
## capabilities
returns a list of capabilities supported by netconf node
```
my @cpas = $conn->capabilities();
for my $cap (@caps)
{
print "$cap\n";
}
```
## get_message_id
returns the message_id and increments the value ready for the next retrevial. 
```
my $num = $conn->get_message_id( );
```
