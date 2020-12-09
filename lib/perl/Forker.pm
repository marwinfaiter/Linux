package Forker;

use Moose;
use namespace::autoclean;

use Data::Dumper;
use Storable ();
use File::Spec;
use POSIX ":sys_wait_h";

has 'kids'        => ( is => 'rw', isa => 'ArrayRef', default => sub {[]} );
has 'threads'     => ( is => 'rw', isa => 'Int' );
has 'file_handle' => ( is => 'rw', isa => 'FileHandle' );
has 'wait_print'  => ( is => 'rw', isa => 'Bool' );
has 'no_print'    => ( is => 'rw', isa => 'Bool' );
has 'parent_pid'  => ( is => 'rw', isa => 'Int', default => sub {$$});

=head2 add_fork

    Adds a fork

    If we're going over the allowed limit for the number of threads
    we will sleep until the thread can be added.

    Then attempts to print any finished threads but in order.

    Then we add the fork.

    If a subroutine is given as the $code parameter
    we will execute it and then exit the child

=cut

sub add_fork {
    my ($self, $fork_id, $code, @args) = @_;

    if ( $self->threads && $self->running >= $self->threads) {
        waitpid -1, 0;
    }

    $self->_print_fork();

    $fork_id ||= scalar @{$self->kids};
    push @{$self->kids}, { fork_id => $fork_id };

    my $pid = open $self->kids->[-1]->{output}, "-|";

    if (!defined $pid) {
        $self->logger->log(fatal => "Failed to fork");
        shift @{$self->kids};
    }

    if ($pid) {
        $self->kids->[-1]->{pid} = $pid;
        return $pid;
    }

    if (ref $code eq "CODE") {
        my $data = $code->(@args);

        $self->exit_child($data);
    }
}

=head2 exit_child

    Exits the child and stores the return data
    Input: Object (ArrayRef, HashRef, StringRef, String)
    returns: Will exit the child here with a normal exit

=cut

sub exit_child {
    my ($self, $return_data) = @_;

    $self->_store($return_data);

    exit;
}

=head2 finish

    Waits for all children to finish and returns arrayref with the child data
    Input:
    Returns ArrayRef

=cut

sub finish {
    my $self = shift;

    foreach my $kid (@{$self->kids}) {
        waitpid $kid->{pid}, 0;

        $self->_print($kid);
    }

    if (scalar @{$self->kids} == 1) {
        return $self->kids->[0];
    }
    else {
        return $self->kids;
    }
}

=head2 running

    Checks number of running children
    Input:
    Returns: wantarray

=cut

sub running {
    my $self = shift;

    my @running = grep { waitpid($_->{pid}, WNOHANG) == 0 } @{$self->kids};

    return wantarray ? @running : scalar @running;
}

# Store returned data returned from child.
# Will later be picked up by $self->_retrieve
sub _store {
    my ($self, $return_data) = @_;

    return unless $return_data;

    my $storable_tempfile = File::Spec->catfile('/tmp', 'Features-Forker-' . $self->{parent_pid} . '-' . $$ . '.txt');
    my $stored = eval { return Storable::store($return_data, $storable_tempfile); };

    # handle Storables errors, IE logcarp or carp returning undef, or die (via logcroak or croak)
    if (not $stored or $@) {
        warn(qq|The storable module was unable to store the child's data structure to the temp file "$storable_tempfile":  | . join(', ', $@));
    }
}

# Retrieve data returned from the child
sub _retrieve {
    my ($self, $kid) = @_;

    return unless $kid;

    my $retrieved = undef;

    my $storable_tempfile = File::Spec->catfile('/tmp', 'Features-Forker-' . $self->{parent_pid} . '-' . $kid . '.txt');

    if (-e $storable_tempfile) {  # child has option of not storing anything, so we need to see if it did or not
        $retrieved = eval { Storable::retrieve($storable_tempfile) };

        # handle Storables errors
        if (not $retrieved or $@) {
            warn(qq|The storable module was unable to retrieve the child's data structure from the temporary file "$storable_tempfile":  | . join(', ', $@));
        }

        # clean up after ourselves
        unlink $storable_tempfile;
    }

    return $retrieved;
}

# Checks if any children have finished and sends them to $self->_print
sub _print_fork {
    my $self = shift;

    return if $self->wait_print;

    foreach my $kid (@{$self->kids}) {
        last if waitpid($kid->{pid}, WNOHANG) == 0;

        $self->_print($kid);
    }
}

# Actually prints the output GLOB and retrievs returned data from child.
sub _print {
    my ($self, $kid) = @_;

    return if (ref $kid->{output}) ne "GLOB";

    my $output = $kid->{output};
    $kid->{output} =  join("", <$output>);

    $kid->{data} = $self->_retrieve($kid->{pid});

    if (!$self->no_print) {
        print { $self->file_handle || *STDOUT } $kid->{output};
    }
}

__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

    Marwinfaiter

=cut

1;
