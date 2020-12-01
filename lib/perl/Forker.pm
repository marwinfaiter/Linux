package Forker;

use Moose;
use namespace::autoclean;

use Data::Dumper;
use Storable ();
use File::Spec;

has 'kids'        => ( is => 'rw', isa => 'ArrayRef', default => sub {[]} );
has 'threads'     => ( is => 'rw', isa => 'Int' );
has 'file_handle' => ( is => 'rw' );
has 'wait_print'   => ( is => 'rw', isa => 'Bool', default => 0 );
has 'no_print'   => ( is => 'rw', isa => 'Bool', default => 0 );
has 'parent_pid'  => ( is => 'rw', isa => 'Int', default => sub {$$});

$SIG{CHLD} = 'IGNORE';

sub add_fork {
    my ($self, $fork_id, $code, @args) = @_;

    if ( $self->threads ) {
        while ( $self->running >= $self->threads ) {
            select undef, undef, undef, 0.5;
        }
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

sub exit_child {
    my ($self, $return_data) = @_;

    $self->_store($return_data);

    exit;
}

sub finish {
    my $self = shift;

    foreach my $kid (@{$self->kids}) {
        waitpid $kid->{pid}, 0;

        $self->_print($kid);

        delete $kid->{printed};
    }

    if (scalar @{$self->kids} == 1) {
        return $self->kids->[0];
    }
    else {
        return $self->kids;
    }
}

sub running {
    my $self = shift;

    my @running = grep { kill(0, $_->{pid}) } @{$self->kids};

    return wantarray ? @running : scalar @running;
}

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

sub _retrieve {
    my ($self, $kid) = @_;

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

sub _print_fork {
    my $self = shift;

    return if $self->wait_print;

    foreach my $kid (@{$self->kids}) {
        last if kill(0, $kid->{pid});

        $self->_print($kid);
    }
}

sub _print {
    my ($self, $kid) = @_;

    return if (ref $kid->{output}) ne "GLOB";

    my $output = $kid->{output};
    $kid->{output} =  join("", <$output>);

    my $return_data = $self->_retrieve($kid->{pid});
    $kid->{data} = $return_data;

    if (!$self->no_print) {
        print { $self->file_handle || *STDOUT } $kid->{output};
    }
}

__PACKAGE__->meta->make_immutable;

1;
