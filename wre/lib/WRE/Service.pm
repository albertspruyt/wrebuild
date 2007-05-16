package WRE::Service;

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
use Carp qw(croak);
use Class::Std::Utils;

{ # begin inside out object


#-------------------------------------------------------------------

=head2 new ( )

Constructor.

=cut

sub new {
    my $class = shift;
    bless \do{my $scalar}, $class;
}

#-------------------------------------------------------------------

=head2 ping ( )

Returns a 1 if spectre is running, or a 0 if it is not. Must be overridden by all subclasses.

=cut

sub ping {
    croak "Subclass didn't override as directed.";
}

#-------------------------------------------------------------------

=head2 restart ( )

Returns a 1 if the restart was successful, or a 0 if it was not. Shouldn't need to be overriden or extended in most
circumstances.

=cut

sub restart {
    my $self = shift;
    if ($self->stop) {
        return $self->start;
    }
    return 0;
}

#-------------------------------------------------------------------

=head2 start ( )

Returns a 1 if the start was successful, or a 0 if it was not. Must be overridden by all subclasses.

=cut

sub start {
    croak "Subclass didn't override as directed.";
}

#-------------------------------------------------------------------

=head2 stop ( )

Returns a 1 if the stop was successful, or a 0 if it was not. Must be overriden by all subclasses.

=cut

sub stop {
    croak "Subclass didn't override as directed.";
}



} # end inside out object

1;
