package WRE::Config;

#-------------------------------------------------------------------
# WRE is Copyright 2005-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com	            		info@plainblack.com
#-------------------------------------------------------------------

use strict;
use base 'Config::JSON';
use Class::Std::Utils;
use File::Copy qw(cp);

{ # begin inside out object

=head1 ISA

This package ineherits most of it's functionality from Config::JSON.

=head1 METHODS

The following methods are available from this package.

=cut

#-------------------------------------------------------------------

=head2 create (  )

An alias of new().

=cut

sub create {
    my $class = shift;
    $class->new(@_);
}

#-------------------------------------------------------------------

=head2 getRoot ( [ path ] )

Returns the root path of the WRE.

=head3 path

A path to add on to the root. Using this will automatically detect whether there is a preceeding / and add it if
necessary.

=cut

sub getRoot {
    my $class = shift;
    my $root = "/data/wre";
    my $path = shift;
    if (defined $path) {
        unless ($path =~ m{^/}) {
            $path = "/".$path;
        }       
        return $root.$path;
    }
    return $root;
}

#-------------------------------------------------------------------

=head2 getDomainRoot ( [ path ] )

Returns the root path of the Domains folder.

=head3 path

A path to add on to the root. Using this will automatically detect whether there is a preceeding / and add it if
necessary.

=cut

sub getDomainRoot {
    my $self = shift;
    my $root = $self->get("domainRoot");
    my $path = shift;
    if (defined $path) {
        unless ($path =~ m{^/}) {
            $path = "/".$path;
        }       
        return $root.$path;
    }
    return $root;
}

#-------------------------------------------------------------------

=head2 getWebguiRoot ( [ path ] )

Returns the root path of WebGUI.

=head3 path

A path to add on to the root. Using this will automatically detect whether there is a preceeding / and add it if
necessary.

=cut

sub getWebguiRoot {
    my $self = shift;
    my $root = $self->get("webgui")->{root};
    my $path = shift;
    if (defined $path) {
        unless ($path =~ m{^/}) {
            $path = "/".$path;
        }       
        return $root.$path;
    }
    return $root;
}

#-------------------------------------------------------------------

=head2 new (  )

Constructor.

=cut

sub new {
    my $class = shift;
    unless (-f $class->getRoot("/etc/wre.conf")) {
        cp($class->getRoot("/var/setupfiles/wre.conf"), $class->getRoot("/etc/wre.conf"));        
    }
    my $object = Config::JSON->new($class->getRoot("/etc/wre.conf"));
    bless $object, $class;
}


} # end inside out object

1;