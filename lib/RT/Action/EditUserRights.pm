
use strict;
use warnings;

package RT::Action::EditUserRights;
use base qw/RT::Action::EditRights/;
use RT::View::Form::Field::SelectUser;
use Scalar::Defer;

sub arguments {
    my $self = shift;
    return {} unless $self->object;
    my $args = $self->SUPER::arguments( @_ );

    my $privileged =
      RT::Model::Group->new( current_user => Jifty->web->current_user );
    $privileged->load_system_internal('privileged');
    my $users = $privileged->members;

    while ( my $user = $users->next ) {
        my $group =
          RT::Model::Group->new( current_user => Jifty->web->current_user );
        $group->load_acl_equivalence( $user->member );

        my $name = 'rights_' . $group->principal_id;
        $args->{$name} = {
            default_value => defer {
                $self->default_value( $group->principal_id );
            },
            available_values => defer { $self->available_values },
            render_as        => 'Checkboxes',
            multiple         => 1,
            label => RT::View::Form::Field::SelectUser->_render_user(
                $user->member->object
            ),
        };
    }
    return $args;
}

1;

